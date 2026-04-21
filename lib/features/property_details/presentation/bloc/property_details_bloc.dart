import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/property_details_repository.dart';
import 'property_details_event.dart';
import 'property_details_state.dart';

class PropertyDetailsBloc extends Bloc<PropertyDetailsEvent, PropertyDetailsState> {
  final PropertyDetailsRepository repository;

  PropertyDetailsBloc({required this.repository}) : super(const PropertyDetailsState.initial()) {
    on<PropertyDetailsLoaded>(_onLoaded);
    on<PropertyDetailsSaveRequested>(_onSaveRequested);
    on<PropertyDetailsContactRevealRequested>(_onRevealRequested);
  }

  Future<void> _onLoaded(
    PropertyDetailsLoaded event,
    Emitter<PropertyDetailsState> emit,
  ) async {
    emit(state.copyWith(status: PropertyDetailsStatus.loading, message: null));
    final result = await repository.getPropertyDetails(event.listing);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PropertyDetailsStatus.failure,
        message: _messageForFailure(failure),
      )),
      (details) => emit(state.copyWith(
        status: PropertyDetailsStatus.loaded,
        details: details,
        message: null,
      )),
    );
  }

  Future<void> _onSaveRequested(
    PropertyDetailsSaveRequested event,
    Emitter<PropertyDetailsState> emit,
  ) async {
    final details = state.details;
    if (details == null || state.isSaved) return;
    emit(state.copyWith(status: PropertyDetailsStatus.saving, message: null));
    final result = await repository.saveListing(details.listing.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PropertyDetailsStatus.loaded,
        message: _messageForFailure(failure),
      )),
      (_) => emit(state.copyWith(
        status: PropertyDetailsStatus.loaded,
        isSaved: true,
        message: 'Listing saved to your account',
      )),
    );
  }

  Future<void> _onRevealRequested(
    PropertyDetailsContactRevealRequested event,
    Emitter<PropertyDetailsState> emit,
  ) async {
    final details = state.details;
    if (details == null || state.contactUnlocked) return;
    emit(state.copyWith(status: PropertyDetailsStatus.revealing, message: null));
    final result = await repository.revealContact(details.listing.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PropertyDetailsStatus.loaded,
        message: _messageForFailure(failure),
      )),
      (_) => emit(state.copyWith(
        status: PropertyDetailsStatus.loaded,
        contactUnlocked: true,
        message: 'Contact details unlocked',
      )),
    );
  }

  String _messageForFailure(Failure failure) {
    if (failure is CacheFailure) return 'Unable to load saved property data';
    return 'Something went wrong. Please try again.';
  }
}
