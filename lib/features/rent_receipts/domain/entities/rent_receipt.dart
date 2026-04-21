import 'package:equatable/equatable.dart';

class RentReceipt extends Equatable {
  final String id;
  final String title;
  final String periodLabel;
  final String issueDate;
  final String amount;
  final String status;
  final String? referenceNumber;
  final String? notes;

  const RentReceipt({
    required this.id,
    required this.title,
    required this.periodLabel,
    required this.issueDate,
    required this.amount,
    required this.status,
    required this.referenceNumber,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        periodLabel,
        issueDate,
        amount,
        status,
        referenceNumber,
        notes,
      ];
}
