import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/listing_entity.dart';
import 'nearby_place_entity.dart';
import 'price_history_point_entity.dart';
import 'property_owner_entity.dart';
import 'property_review_entity.dart';

class PropertyDetailsEntity extends Equatable {
  final ListingEntity listing;
  final PropertyOwnerEntity owner;
  final List<String> galleryImages;
  final List<String> floorPlanSections;
  final List<NearbyPlaceEntity> nearbyPlaces;
  final List<PropertyReviewEntity> reviews;
  final List<ListingEntity> similarListings;
  final List<PriceHistoryPointEntity> priceHistory;

  const PropertyDetailsEntity({
    required this.listing,
    required this.owner,
    required this.galleryImages,
    required this.floorPlanSections,
    required this.nearbyPlaces,
    required this.reviews,
    required this.similarListings,
    required this.priceHistory,
  });

  @override
  List<Object?> get props => [
        listing,
        owner,
        galleryImages,
        floorPlanSections,
        nearbyPlaces,
        reviews,
        similarListings,
        priceHistory,
      ];
}
