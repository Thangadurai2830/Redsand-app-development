import 'package:equatable/equatable.dart';

class OwnerBuyerInterestEntity extends Equatable {
  final String id;
  final String buyerName;
  final String listingId;
  final String listingTitle;
  final String phone;
  final String email;
  final String budget;
  final String note;
  final DateTime? requestedAt;

  const OwnerBuyerInterestEntity({
    required this.id,
    required this.buyerName,
    required this.listingId,
    required this.listingTitle,
    required this.phone,
    required this.email,
    required this.budget,
    required this.note,
    this.requestedAt,
  });

  @override
  List<Object?> get props => [
        id,
        buyerName,
        listingId,
        listingTitle,
        phone,
        email,
        budget,
        note,
        requestedAt,
      ];
}

