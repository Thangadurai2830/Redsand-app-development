import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_saved_listings.dart';
import '../../domain/usecases/remove_saved_listing.dart';
import 'saved_listings_event.dart';
import 'saved_listings_state.dart';

class SavedListingsBloc extends Bloc<SavedListingsEvent, SavedListingsState> {
  final GetSavedListings getSavedListings;
  final RemoveSavedListing removeSavedListing;

  SavedListingsBloc({
    required this.getSavedListings,
    required this.removeSavedListing,
  }) : super(const SavedListingsState.initial()) {
    on<SavedListingsLoadRequested>(_onLoad);
    on<SavedListingsRefreshRequested>(_onRefresh);
    on<SavedListingsToggleSelectionRequested>(_onToggleSelection);
    on<SavedListingsRemoveRequested>(_onRemove);
    on<SavedListingsClearMessageRequested>(_onClearMessage);
    on<SavedListingsClearSelectionRequested>(_onClearSelection);
  }

  Future<void> _onLoad(
    SavedListingsLoadRequested event,
    Emitter<SavedListingsState> emit,
  ) async {
    emit(state.copyWith(status: SavedListingsStatus.loading, message: null));
    final result = await getSavedListings();
    result.fold(
      (failure) => emit(state.copyWith(
        status: SavedListingsStatus.failure,
        message: _messageForFailure(failure),
      )),
      (listings) => emit(state.copyWith(
        status: SavedListingsStatus.loaded,
        listings: listings,
        selectedIds: state.selectedIds.intersection(listings.map((e) => e.listing.id).toSet()),
        removingIds: const {},
        message: null,
      )),
    );
  }

  Future<void> _onRefresh(
    SavedListingsRefreshRequested event,
    Emitter<SavedListingsState> emit,
  ) async {
    final result = await getSavedListings();
    result.fold(
      (failure) => emit(state.copyWith(
        status: SavedListingsStatus.failure,
        message: _messageForFailure(failure),
      )),
      (listings) => emit(state.copyWith(
        status: SavedListingsStatus.loaded,
        listings: listings,
        selectedIds: state.selectedIds.intersection(listings.map((e) => e.listing.id).toSet()),
        removingIds: const {},
        message: 'Saved listings refreshed',
      )),
    );
  }

  void _onToggleSelection(
    SavedListingsToggleSelectionRequested event,
    Emitter<SavedListingsState> emit,
  ) {
    final current = state;
    if (current.status == SavedListingsStatus.initial) return;

    final selected = Set<String>.from(current.selectedIds);
    if (selected.contains(event.listingId)) {
      selected.remove(event.listingId);
      emit(current.copyWith(
        selectedIds: selected,
        message: null,
      ));
      return;
    }

    if (selected.length >= 3) {
      emit(current.copyWith(message: 'You can compare up to 3 listings'));
      return;
    }

    selected.add(event.listingId);
    emit(current.copyWith(
      selectedIds: selected,
      message: null,
    ));
  }

  Future<void> _onRemove(
    SavedListingsRemoveRequested event,
    Emitter<SavedListingsState> emit,
  ) async {
    final current = state;
    if (current.removingIds.contains(event.listingId)) return;

    emit(current.copyWith(
      removingIds: {...current.removingIds, event.listingId},
      message: null,
    ));

    final result = await removeSavedListing(event.listingId);
    result.fold(
      (failure) => emit(state.copyWith(
        removingIds: state.removingIds.where((id) => id != event.listingId).toSet(),
        message: _messageForFailure(failure),
      )),
      (_) {
        final updatedListings = state.listings
            .where((entry) => entry.listing.id != event.listingId && entry.id != event.listingId)
            .toList();
        emit(state.copyWith(
          status: updatedListings.isEmpty ? SavedListingsStatus.loaded : SavedListingsStatus.loaded,
          listings: updatedListings,
          selectedIds: state.selectedIds.where((id) => id != event.listingId).toSet(),
          removingIds: state.removingIds.where((id) => id != event.listingId).toSet(),
          message: 'Removed from saved listings',
        ));
      },
    );
  }

  void _onClearMessage(
    SavedListingsClearMessageRequested event,
    Emitter<SavedListingsState> emit,
  ) {
    emit(state.copyWith(message: null));
  }

  void _onClearSelection(
    SavedListingsClearSelectionRequested event,
    Emitter<SavedListingsState> emit,
  ) {
    emit(state.copyWith(
      selectedIds: const {},
      message: null,
    ));
  }

  String _messageForFailure(Failure failure) {
    if (failure is CacheFailure) return 'Unable to load saved listings right now';
    return 'Something went wrong. Please try again.';
  }
}
