import '../../domain/entities/site_visit_record.dart';

class SiteVisitRecordModel extends SiteVisitRecord {
  const SiteVisitRecordModel({
    required super.id,
    required super.propertyName,
    required super.propertyAddress,
    required super.visitDate,
    required super.visitTime,
    required super.status,
    required super.receiptUrl,
    required super.notes,
  });

  factory SiteVisitRecordModel.fromJson(Map<String, dynamic> json) {
    final visit = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return SiteVisitRecordModel(
      id: _stringValue(visit, const ['id', 'visit_id'], DateTime.now().millisecondsSinceEpoch.toString()),
      propertyName: _stringValue(visit, const ['property_name', 'propertyTitle', 'title', 'property'], 'Site Visit'),
      propertyAddress: _stringValue(visit, const ['property_address', 'address', 'location'], ''),
      visitDate: _stringValue(visit, const ['visit_date', 'date', 'scheduled_date'], ''),
      visitTime: _stringValue(visit, const ['visit_time', 'time', 'scheduled_time'], ''),
      status: _stringValue(visit, const ['status', 'visit_status'], 'scheduled'),
      receiptUrl: _nullableStringValue(visit, const ['receipt_url', 'rent_receipt_url', 'download_url']),
      notes: _stringValue(visit, const ['notes', 'message', 'remarks'], ''),
    );
  }

  static String _stringValue(
    Map<String, dynamic> json,
    List<String> keys,
    String fallback,
  ) {
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
}
