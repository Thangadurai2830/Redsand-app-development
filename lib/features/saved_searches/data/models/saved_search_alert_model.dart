import '../../../filter/domain/entities/filter_entity.dart';
import '../../domain/entities/saved_search_alert.dart';

class SavedSearchAlertModel extends SavedSearchAlert {
  const SavedSearchAlertModel({
    required super.id,
    required super.query,
    required super.filter,
    required super.savedAt,
    super.notifyByPush,
    super.notifyInApp,
    super.priceDropAlert,
    super.newMatchCount,
    super.lastMatchedAt,
  });

  factory SavedSearchAlertModel.fromJson(Map<String, dynamic> json) {
    final payload = _extractPayload(json);
    final filterPayload = payload['filter'] is Map<String, dynamic>
        ? payload['filter'] as Map<String, dynamic>
        : payload;

    return SavedSearchAlertModel(
      id: _stringValue(payload, const ['id', 'search_id', 'saved_search_id'], fallback: ''),
      query: _stringValue(payload, const ['query', 'q', 'keyword', 'search_query'], fallback: ''),
      filter: _filterFromJson(filterPayload),
      notifyByPush: _boolValue(payload, const ['notify_push', 'push_enabled', 'push_notification'], fallback: true),
      notifyInApp: _boolValue(payload, const ['notify_in_app', 'in_app_enabled', 'in_app_notification'], fallback: true),
      priceDropAlert: _boolValue(payload, const ['price_drop_alert', 'notify_price_drop'], fallback: false),
      savedAt: _dateValue(payload, const ['saved_at', 'created_at', 'createdAt']) ?? DateTime.now(),
      newMatchCount: _intValue(payload, const ['new_match_count', 'unread_count', 'match_count']),
      lastMatchedAt: _dateValue(payload, const ['last_matched_at', 'lastMatchedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'filter': filter.toQueryParameters(),
      'notify_push': notifyByPush,
      'notify_in_app': notifyInApp,
      'price_drop_alert': priceDropAlert,
      'saved_at': savedAt.toIso8601String(),
      'new_match_count': newMatchCount,
      if (lastMatchedAt != null) 'last_matched_at': lastMatchedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'query': query,
      'filter': filter.toQueryParameters(),
      'notify_push': notifyByPush,
      'notify_in_app': notifyInApp,
      'price_drop_alert': priceDropAlert,
    };
  }

  static Map<String, dynamic> _extractPayload(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
  }

  static FilterEntity _filterFromJson(Map<String, dynamic> json) {
    final listingFor = _stringValue(json, const ['listing_for', 'listingFor'], fallback: 'rent');
    final propertyType = _nullableStringValue(json, const ['property_type', 'propertyType']);
    final furnishing = _nullableStringValue(json, const ['furnishing']);
    final amenities = _listValue(json, const ['amenities']);
    final city = _nullableStringValue(json, const ['city']);
    final locality = _nullableStringValue(json, const ['locality']);
    final minPrice = _doubleValue(json, const ['budget_min', 'min_price', 'minPrice']);
    final maxPrice = _doubleValue(json, const ['budget_max', 'max_price', 'maxPrice']);
    final minBedrooms = _intValue(json, const ['bhk', 'min_bedrooms', 'minBedrooms']);
    final minAreaSqft = _doubleValue(json, const ['area_min_sqft', 'min_area_sqft', 'minAreaSqft']);
    final sortBy = _stringValue(json, const ['sort_by', 'sortBy'], fallback: 'newest');

    return FilterEntity(
      listingFor: listingFor,
      propertyType: propertyType,
      furnishing: furnishing,
      amenities: amenities,
      city: city,
      locality: locality,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minBedrooms: minBedrooms,
      minAreaSqft: minAreaSqft,
      sortBy: sortBy,
    );
  }

  static String _stringValue(Map<String, dynamic> json, List<String> keys, {required String fallback}) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }

  static String? _nullableStringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static bool _boolValue(Map<String, dynamic> json, List<String> keys, {required bool fallback}) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == 'yes' || normalized == '1') return true;
        if (normalized == 'false' || normalized == 'no' || normalized == '0') return false;
      }
    }
    return fallback;
  }

  static DateTime? _dateValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return DateTime.tryParse(value.trim());
      }
    }
    return null;
  }

  static int _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  static double? _doubleValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static List<String> _listValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) {
        return value.whereType<String>().map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
      }
      if (value is String && value.trim().isNotEmpty) {
        return value
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
    }
    return const [];
  }
}
