part of 'owner_dashboard_bloc.dart';

abstract class OwnerDashboardEvent extends Equatable {
  const OwnerDashboardEvent();

  @override
  List<Object?> get props => [];
}

class OwnerDashboardStarted extends OwnerDashboardEvent {
  const OwnerDashboardStarted();
}

class OwnerDashboardRefreshed extends OwnerDashboardEvent {
  const OwnerDashboardRefreshed();
}

class OwnerDashboardStatusFilterChanged extends OwnerDashboardEvent {
  final OwnerListingStatus? status;

  const OwnerDashboardStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class OwnerDashboardBoostRequested extends OwnerDashboardEvent {
  final String listingId;

  const OwnerDashboardBoostRequested(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

class OwnerDashboardMessageCleared extends OwnerDashboardEvent {
  const OwnerDashboardMessageCleared();
}

