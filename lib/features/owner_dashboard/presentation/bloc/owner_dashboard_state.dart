part of 'owner_dashboard_bloc.dart';

enum OwnerDashboardStatus { initial, loading, loaded, failure }

const _unset = Object();

class OwnerDashboardState extends Equatable {
  final OwnerDashboardStatus status;
  final List<OwnerListingEntity> listings;
  final List<OwnerBuyerInterestEntity> interests;
  final OwnerAnalyticsEntity? analytics;
  final OwnerListingStatus? selectedStatus;
  final Set<String> boostingListingIds;
  final String? message;

  const OwnerDashboardState({
    required this.status,
    required this.listings,
    required this.interests,
    required this.analytics,
    required this.selectedStatus,
    required this.boostingListingIds,
    required this.message,
  });

  const OwnerDashboardState.initial()
      : status = OwnerDashboardStatus.initial,
        listings = const [],
        interests = const [],
        analytics = null,
        selectedStatus = null,
        boostingListingIds = const {},
        message = null;

  bool get isLoading => status == OwnerDashboardStatus.loading;

  bool get hasData =>
      listings.isNotEmpty || interests.isNotEmpty || analytics != null;

  List<OwnerListingEntity> get filteredListings {
    if (selectedStatus == null) return listings;
    return listings.where((listing) => listing.status == selectedStatus).toList(growable: false);
  }

  OwnerDashboardState copyWith({
    OwnerDashboardStatus? status,
    List<OwnerListingEntity>? listings,
    List<OwnerBuyerInterestEntity>? interests,
    Object? analytics = _unset,
    Object? selectedStatus = _unset,
    Set<String>? boostingListingIds,
    Object? message = _unset,
  }) {
    return OwnerDashboardState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      interests: interests ?? this.interests,
      analytics: analytics == _unset ? this.analytics : analytics as OwnerAnalyticsEntity?,
      selectedStatus: selectedStatus == _unset ? this.selectedStatus : selectedStatus as OwnerListingStatus?,
      boostingListingIds: boostingListingIds ?? this.boostingListingIds,
      message: message == _unset ? this.message : message as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        listings,
        interests,
        analytics,
        selectedStatus,
        boostingListingIds,
        message,
      ];
}
