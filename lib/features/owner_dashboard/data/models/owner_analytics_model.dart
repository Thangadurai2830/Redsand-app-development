import '../../domain/entities/owner_analytics_entity.dart';
import '../../domain/entities/owner_listing_status.dart';
import 'owner_dashboard_json.dart';

class OwnerAnalyticsModel extends OwnerAnalyticsEntity {
  const OwnerAnalyticsModel({
    required super.totalListings,
    required super.totalInterestedBuyers,
    required super.totalViews,
    required super.totalLeads,
    required super.leadConversionRate,
    required super.boostedListings,
    required super.averageResponseMinutes,
    required super.statusBreakdown,
  });

  factory OwnerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final analytics = unwrapObject(json);
    final breakdownSource = normalizeMap(analytics['status_breakdown'] ?? analytics['breakdown'] ?? analytics['listings_by_status']);

    Map<OwnerListingStatus, int> statusCounts = {
      for (final status in OwnerListingStatus.values) status: 0,
    };

    for (final status in OwnerListingStatus.values) {
      final raw = breakdownSource[status.name] ?? analytics['${status.name}_count'];
      final parsed = _parseInt(raw);
      if (parsed != null) {
        statusCounts[status] = parsed;
      }
    }

    return OwnerAnalyticsModel(
      totalListings: intValue(analytics, const ['total_listings', 'listings_count', 'properties_count']),
      totalInterestedBuyers: intValue(analytics, const ['total_interested_buyers', 'interested_buyers', 'leads_count']),
      totalViews: intValue(analytics, const ['total_views', 'views', 'monthly_views']),
      totalLeads: intValue(analytics, const ['total_leads', 'leads', 'inquiries']),
      leadConversionRate: doubleValue(
        analytics,
        const ['lead_conversion_rate', 'conversion_rate', 'lead_rate'],
      ),
      boostedListings: intValue(analytics, const ['boosted_listings', 'boosted_count']),
      averageResponseMinutes: intValue(
        analytics,
        const ['average_response_minutes', 'avg_response_minutes', 'response_minutes'],
      ),
      statusBreakdown: statusCounts,
    );
  }

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }
}

