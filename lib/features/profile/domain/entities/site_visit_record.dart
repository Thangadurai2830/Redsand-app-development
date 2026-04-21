import 'package:equatable/equatable.dart';

class SiteVisitRecord extends Equatable {
  final String id;
  final String propertyName;
  final String propertyAddress;
  final String visitDate;
  final String visitTime;
  final String status;
  final String? receiptUrl;
  final String notes;

  const SiteVisitRecord({
    required this.id,
    required this.propertyName,
    required this.propertyAddress,
    required this.visitDate,
    required this.visitTime,
    required this.status,
    required this.receiptUrl,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        propertyName,
        propertyAddress,
        visitDate,
        visitTime,
        status,
        receiptUrl,
        notes,
      ];
}
