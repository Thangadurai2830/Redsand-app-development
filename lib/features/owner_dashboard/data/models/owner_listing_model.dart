import '../../domain/entities/owner_listing_entity.dart';
import '../../domain/entities/owner_listing_status.dart';
import 'owner_dashboard_json.dart';

class OwnerListingModel extends OwnerListingEntity {
  const OwnerListingModel({
    required super.id,
    required super.title,
    required super.locality,
    required super.city,
    required super.price,
    required super.imageUrl,
    required super.bedrooms,
    required super.areaSqft,
    required super.interestedBuyersCount,
    required super.isBoosted,
    required super.status,
    super.updatedAt,
  });

  factory OwnerListingModel.fromJson(Map<String, dynamic> json) {
    final listing = unwrapObject(json);
    return OwnerListingModel(
      id: stringValue(listing, const ['id', 'listing_id'], fallback: 'unknown-listing'),
      title: stringValue(listing, const ['title', 'listing_title', 'name'], fallback: 'Untitled listing'),
      locality: stringValue(listing, const ['locality', 'area', 'neighborhood'], fallback: 'Unknown locality'),
      city: stringValue(listing, const ['city', 'location_city'], fallback: 'Unknown city'),
      price: doubleValue(listing, const ['price', 'amount', 'rent', 'monthly_rent']),
      imageUrl: stringValue(
        listing,
        const ['image_url', 'thumbnail_url', 'cover_url', 'photo_url'],
        fallback: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=80',
      ),
      bedrooms: intValue(listing, const ['bedrooms', 'bedroom_count', 'rooms']),
      areaSqft: doubleValue(listing, const ['area_sqft', 'area', 'size_sqft']),
      interestedBuyersCount: intValue(
        listing,
        const ['interested_buyers_count', 'interested_count', 'interest_count', 'leads_count'],
      ),
      isBoosted: boolValue(listing, const ['is_boosted', 'boosted', 'boosted_listing']),
      status: ownerListingStatusFromApiValue(
        stringValue(listing, const ['status', 'listing_status'], fallback: 'pending'),
      ),
      updatedAt: dateTimeValue(listing, const ['updated_at', 'updatedAt', 'modified_at']),
    );
  }
}
