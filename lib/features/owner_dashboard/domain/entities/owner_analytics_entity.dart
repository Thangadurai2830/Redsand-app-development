import 'package:equatable/equatable.dart';

import 'owner_listing_status.dart';

class OwnerAnalyticsEntity extends Equatable {
  final int totalListings;
  final int totalInterestedBuyers;
  final int totalViews;
  final int totalLeads;
  final double leadConversionRate;
  final int boostedListings;
  final int averageResponseMinutes;
  final Map<OwnerListingStatus, int> statusBreakdown;

  const OwnerAnalyticsEntity({
    required this.totalListings,
    required this.totalInterestedBuyers,
    required this.totalViews,
    required this.totalLeads,
    required this.leadConversionRate,
    required this.boostedListings,
    required this.averageResponseMinutes,
    required this.statusBreakdown,
  });

  int get approvedCount => statusBreakdown[OwnerListingStatus.approved] ?? 0;
  int get draftCount => statusBreakdown[OwnerListingStatus.draft] ?? 0;
  int get pendingCount => statusBreakdown[OwnerListingStatus.pending] ?? 0;
  int get flaggedCount => statusBreakdown[OwnerListingStatus.flagged] ?? 0;
  int get rentedCount => statusBreakdown[OwnerListingStatus.rented] ?? 0;
  double get displayLeadConversionRate =>
      leadConversionRate <= 1 ? leadConversionRate * 100 : leadConversionRate;

  @override
  List<Object?> get props => [
        totalListings,
        totalInterestedBuyers,
        totalViews,
        totalLeads,
        leadConversionRate,
        boostedListings,
        averageResponseMinutes,
        statusBreakdown,
      ];
}
