import 'package:equatable/equatable.dart';

import 'owner_listing_status.dart';

class OwnerListingEntity extends Equatable {
  final String id;
  final String title;
  final String locality;
  final String city;
  final double price;
  final String imageUrl;
  final int bedrooms;
  final double areaSqft;
  final int interestedBuyersCount;
  final bool isBoosted;
  final OwnerListingStatus status;
  final DateTime? updatedAt;

  const OwnerListingEntity({
    required this.id,
    required this.title,
    required this.locality,
    required this.city,
    required this.price,
    required this.imageUrl,
    required this.bedrooms,
    required this.areaSqft,
    required this.interestedBuyersCount,
    required this.isBoosted,
    required this.status,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        locality,
        city,
        price,
        imageUrl,
        bedrooms,
        areaSqft,
        interestedBuyersCount,
        isBoosted,
        status,
        updatedAt,
      ];
}

