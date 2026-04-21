import 'package:equatable/equatable.dart';

class SiteVisitRequest extends Equatable {
  final String listingId;
  final DateTime visitDate;
  final String visitTime;
  final String message;

  const SiteVisitRequest({
    required this.listingId,
    required this.visitDate,
    required this.visitTime,
    required this.message,
  });

  @override
  List<Object?> get props => [listingId, visitDate, visitTime, message];
}
