import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/owner_analytics_entity.dart';
import '../../domain/entities/owner_buyer_interest_entity.dart';
import '../../domain/entities/owner_listing_entity.dart';
import '../../domain/entities/owner_listing_status.dart';
import '../../domain/usecases/boost_owner_listing.dart';
import '../../domain/usecases/get_owner_analytics.dart';
import '../../domain/usecases/get_owner_interests.dart';
import '../../domain/usecases/get_owner_listings.dart';

part 'owner_dashboard_event.dart';
part 'owner_dashboard_state.dart';

class OwnerDashboardBloc extends Bloc<OwnerDashboardEvent, OwnerDashboardState> {
  final GetOwnerListings getOwnerListings;
  final GetOwnerInterests getOwnerInterests;
  final GetOwnerAnalytics getOwnerAnalytics;
  final BoostOwnerListing boostOwnerListing;

  OwnerDashboardBloc({
    required this.getOwnerListings,
    required this.getOwnerInterests,
    required this.getOwnerAnalytics,
    required this.boostOwnerListing,
  }) : super(const OwnerDashboardState.initial()) {
    on<OwnerDashboardStarted>(_onStarted);
    on<OwnerDashboardRefreshed>(_onRefreshed);
    on<OwnerDashboardStatusFilterChanged>(_onFilterChanged);
    on<OwnerDashboardBoostRequested>(_onBoostRequested);
    on<OwnerDashboardMessageCleared>(_onMessageCleared);
  }

  Future<void> _onStarted(
    OwnerDashboardStarted event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    await _loadAll(emit, markLoading: true);
  }

  Future<void> _onRefreshed(
    OwnerDashboardRefreshed event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    await _loadAll(emit, markLoading: false);
  }

  void _onFilterChanged(
    OwnerDashboardStatusFilterChanged event,
    Emitter<OwnerDashboardState> emit,
  ) {
    emit(state.copyWith(selectedStatus: event.status));
  }

  Future<void> _onBoostRequested(
    OwnerDashboardBoostRequested event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(
      boostingListingIds: {...state.boostingListingIds, event.listingId},
      message: null,
    ));

    final result = await boostOwnerListing(event.listingId);
    await result.fold(
      (_) async {
        emit(state.copyWith(
          boostingListingIds: {...state.boostingListingIds}..remove(event.listingId),
          status: OwnerDashboardStatus.failure,
          message: 'Unable to boost the listing right now.',
        ));
      },
      (_) async {
        emit(state.copyWith(
          boostingListingIds: {...state.boostingListingIds}..remove(event.listingId),
          message: 'Listing boost request sent.',
        ));
        await _loadAll(emit, markLoading: false, keepMessage: true);
      },
    );
  }

  void _onMessageCleared(
    OwnerDashboardMessageCleared event,
    Emitter<OwnerDashboardState> emit,
  ) {
    emit(state.copyWith(message: null));
  }

  Future<void> _loadAll(
    Emitter<OwnerDashboardState> emit, {
    required bool markLoading,
    bool keepMessage = false,
  }) async {
    if (markLoading) {
      emit(state.copyWith(status: OwnerDashboardStatus.loading, message: null));
    }

    final listingsResult = await getOwnerListings(const NoParams());
    final interestsResult = await getOwnerInterests(const NoParams());
    final analyticsResult = await getOwnerAnalytics(const NoParams());

    final failures = [
      listingsResult.isLeft(),
      interestsResult.isLeft(),
      analyticsResult.isLeft(),
    ].where((failed) => failed).length;

    final updatedState = state.copyWith(
      status: failures == 0 ? OwnerDashboardStatus.loaded : OwnerDashboardStatus.failure,
      listings: listingsResult.getOrElse(() => const []),
      interests: interestsResult.getOrElse(() => const []),
      analytics: analyticsResult.fold((_) => null, (value) => value),
      message: keepMessage
          ? state.message
          : failures == 0
              ? 'Owner dashboard refreshed'
              : 'Some owner dashboard data could not be loaded.',
    );
    emit(updatedState);
  }
}
