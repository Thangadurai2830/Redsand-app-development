import 'package:equatable/equatable.dart';

class ListingEntity extends Equatable {
  final String id;
  final String title;
  final String locality;
  final String city;
  final double price;
  final String type; // apartment, villa, pg, commercial
  final String listingFor; // rent, buy
  final String imageUrl;
  final bool isPremium;
  final bool isBoosted;
  final int bedrooms;
  final double areaSqft;

  const ListingEntity({
    required this.id,
    required this.title,
    required this.locality,
    required this.city,
    required this.price,
    required this.type,
    required this.listingFor,
    required this.imageUrl,
    required this.isPremium,
    required this.isBoosted,
    required this.bedrooms,
    required this.areaSqft,
  });

  @override
  List<Object?> get props => [
        id, title, locality, city, price, type,
        listingFor, imageUrl, isPremium, isBoosted, bedrooms, areaSqft,
      ];
}
