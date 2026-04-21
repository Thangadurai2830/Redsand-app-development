import '../../domain/entities/maintenance_ticket.dart';
import 'maintenance_request_model.dart';

class MaintenanceTicketModel extends MaintenanceTicket {
  const MaintenanceTicketModel({
    required super.id,
    required super.issueType,
    required super.description,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.photoUrl,
    super.propertyName,
    super.propertyAddress,
  });

  factory MaintenanceTicketModel.fromJson(Map<String, dynamic> json) {
    final payload = _extractPayload(json);
    final createdAt = _dateValue(payload, const ['created_at', 'createdAt', 'raised_at', 'reported_at']) ?? DateTime.now();
    final updatedAt = _dateValue(payload, const ['updated_at', 'updatedAt', 'modified_at', 'resolved_at']) ?? createdAt;

    return MaintenanceTicketModel(
      id: _stringValue(payload, const ['id', 'ticket_id', 'maintenance_id'], fallback: DateTime.now().millisecondsSinceEpoch.toString()),
      issueType: _stringValue(payload, const ['issue_type', 'issueType', 'category', 'type'], fallback: 'other'),
      description: _stringValue(payload, const ['description', 'details', 'issue_description', 'notes'], fallback: ''),
      status: _normalizeStatus(_stringValue(payload, const ['status', 'ticket_status', 'request_status'], fallback: 'open')),
      createdAt: createdAt,
      updatedAt: updatedAt,
      photoUrl: _nullableStringValue(payload, const ['photo_url', 'photoUrl', 'image_url', 'image', 'photo', 'photo_reference']),
      propertyName: _nullableStringValue(payload, const ['property_name', 'propertyName', 'listing_name', 'property_title']),
      propertyAddress: _nullableStringValue(payload, const ['property_address', 'propertyAddress', 'address', 'location']),
    );
  }

  factory MaintenanceTicketModel.fromRequest({
    required MaintenanceRequestModel request,
    String? id,
    String? photoUrl,
  }) {
    final now = DateTime.now();
    return MaintenanceTicketModel(
      id: id ?? now.millisecondsSinceEpoch.toString(),
      issueType: request.issueType,
      description: request.description,
      status: 'open',
      createdAt: now,
      updatedAt: now,
      photoUrl: photoUrl ?? request.photoPath,
    );
  }

  static Map<String, dynamic> _extractPayload(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
  }

  static String _stringValue(
    Map<String, dynamic> json,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  static String? _nullableStringValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
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

  static String _normalizeStatus(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('_', '-');
    if (normalized == 'in progress' || normalized == 'progressing') {
      return 'in-progress';
    }
    if (normalized == 'resolved' || normalized == 'closed' || normalized == 'done') {
      return 'resolved';
    }
    if (normalized == 'open' || normalized == 'new' || normalized == 'raised') {
      return 'open';
    }
    return normalized.isEmpty ? 'open' : normalized;
  }
}
