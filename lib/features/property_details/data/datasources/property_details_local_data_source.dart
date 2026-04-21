import '../../../home/domain/entities/listing_entity.dart';
import '../../domain/entities/nearby_place_entity.dart';
import '../../domain/entities/price_history_point_entity.dart';
import '../../domain/entities/property_details_entity.dart';
import '../../domain/entities/property_owner_entity.dart';
import '../../domain/entities/property_review_entity.dart';

abstract class PropertyDetailsLocalDataSource {
  PropertyDetailsEntity getPropertyDetails(ListingEntity listing);
}

class PropertyDetailsLocalDataSourceImpl implements PropertyDetailsLocalDataSource {
  @override
  PropertyDetailsEntity getPropertyDetails(ListingEntity listing) {
    return PropertyDetailsEntity(
      listing: listing,
      owner: const PropertyOwnerEntity(
        name: 'Aarav Mehta',
        company: 'Mehta Realty',
        phoneNumber: '+91 98765 43210',
        whatsappNumber: '+91 98765 43210',
        isVerified: true,
        rating: 4.8,
        responseTime: 'Replies within 15 mins',
      ),
      galleryImages: const [
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',
        'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
        'https://images.unsplash.com/photo-1567767292278-a4f21aa2d36e?w=800&q=80',
      ],
      floorPlanSections: const [
        'Living Room',
        'Master Bedroom',
        'Kitchen',
        'Dining',
        'Balcony',
      ],
      nearbyPlaces: const [
        NearbyPlaceEntity(name: 'Metro Station', category: 'Transit', distanceKm: 1.2, travelTimeMins: 6),
        NearbyPlaceEntity(name: 'City Hospital', category: 'Healthcare', distanceKm: 2.1, travelTimeMins: 8),
        NearbyPlaceEntity(name: 'Greenwood School', category: 'Education', distanceKm: 1.6, travelTimeMins: 7),
        NearbyPlaceEntity(name: 'Central Mall', category: 'Shopping', distanceKm: 2.7, travelTimeMins: 11),
      ],
      reviews: const [
        PropertyReviewEntity(
          reviewerName: 'Nivedita S.',
          rating: 4.9,
          dateLabel: '2 weeks ago',
          comment: 'Great location, well maintained, and the owner responded quickly.',
        ),
        PropertyReviewEntity(
          reviewerName: 'Karan P.',
          rating: 4.7,
          dateLabel: '1 month ago',
          comment: 'Spacious rooms and the floor plan is genuinely practical.',
        ),
        PropertyReviewEntity(
          reviewerName: 'Priya R.',
          rating: 4.8,
          dateLabel: '2 months ago',
          comment: 'The listing matched the photos and the visit was smooth.',
        ),
      ],
      similarListings: const [
        ListingEntity(
          id: 'sim-1',
          title: 'Skyline 3BHK with Balcony',
          locality: 'Whitefield',
          city: 'Bangalore',
          price: 36000,
          type: 'apartment',
        listingFor: 'rent',
        imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80',
        isPremium: true,
        isBoosted: false,
        bedrooms: 3,
        areaSqft: 1520,
        amenities: ['Clubhouse', 'Power Backup', 'Covered Parking'],
      ),
        ListingEntity(
          id: 'sim-2',
          title: 'Elegant 4BHK Family Villa',
          locality: 'Koramangala',
          city: 'Bangalore',
          price: 125000,
          type: 'villa',
        listingFor: 'rent',
        imageUrl: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=80',
        isPremium: false,
        isBoosted: true,
        bedrooms: 4,
        areaSqft: 3050,
        amenities: ['Private Pool', 'Garden', 'Security'],
      ),
        ListingEntity(
          id: 'sim-3',
          title: 'Premium 2BHK for Sale',
          locality: 'Indiranagar',
          city: 'Bangalore',
          price: 4600000,
          type: 'apartment',
        listingFor: 'buy',
        imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
        isPremium: true,
        isBoosted: false,
        bedrooms: 2,
        areaSqft: 1080,
        amenities: ['Lift', 'Power Backup', 'Park'],
      ),
      ],
      priceHistory: const [
        PriceHistoryPointEntity(label: 'Jan', price: 32000),
        PriceHistoryPointEntity(label: 'Feb', price: 32500),
        PriceHistoryPointEntity(label: 'Mar', price: 33500),
        PriceHistoryPointEntity(label: 'Apr', price: 35000),
      ],
    );
  }
}
