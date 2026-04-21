import '../../domain/entities/site_visit_request.dart';

class SiteVisitRequestModel {
  final String listingId;
  final DateTime visitDate;
  final String visitTime;
  final String message;

  const SiteVisitRequestModel({
    required this.listingId,
    required this.visitDate,
    required this.visitTime,
    required this.message,
  });

  factory SiteVisitRequestModel.fromEntity(SiteVisitRequest request) {
    return SiteVisitRequestModel(
      listingId: request.listingId,
      visitDate: request.visitDate,
      visitTime: request.visitTime,
      message: request.message,
    );
  }

  Map<String, dynamic> toJson() => {
        'listing_id': listingId,
        'visit_date': _formatDate(visitDate),
        'visit_time': visitTime,
        'message': message,
      };

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
