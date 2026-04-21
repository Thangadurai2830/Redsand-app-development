import '../../../home/domain/entities/listing_entity.dart';
import '../models/saved_listing_model.dart';

abstract class SavedListingsLocalDataSource {
  Future<List<SavedListingModel>> getSavedListings();
  Future<void> removeSavedListing(String listingId);
}

const _savedListing1 = ListingEntity(
  id: '1',
  title: 'Spacious 3BHK in Whitefield',
  locality: 'Whitefield',
  city: 'Bangalore',
  price: 35000,
  type: 'apartment',
  listingFor: 'rent',
  imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80',
  isPremium: true,
  isBoosted: false,
  bedrooms: 3,
  areaSqft: 1450,
  amenities: ['Clubhouse', 'Power Backup', 'Covered Parking'],
);

const _savedListing2 = ListingEntity(
  id: '5',
  title: '4BHK Independent Villa for Sale',
  locality: 'Sarjapur',
  city: 'Bangalore',
  price: 8500000,
  type: 'villa',
  listingFor: 'buy',
  imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=80',
  isPremium: true,
  isBoosted: true,
  bedrooms: 4,
  areaSqft: 2800,
  amenities: ['Clubhouse', 'Garden', 'Gym'],
);

const _savedListing3 = ListingEntity(
  id: '6',
  title: 'Ready to Move 2BHK Flat',
  locality: 'Electronic City',
  city: 'Bangalore',
  price: 4200000,
  type: 'apartment',
  listingFor: 'buy',
  imageUrl: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&q=80',
  isPremium: false,
  isBoosted: false,
  bedrooms: 2,
  areaSqft: 1100,
  amenities: ['Lift', 'Power Backup', 'Children Play Area'],
);

class SavedListingsLocalDataSourceImpl implements SavedListingsLocalDataSource {
  final List<SavedListingModel> _savedListings = [
    SavedListingModel(
      id: 'saved-1',
      listing: _savedListing1,
      savedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SavedListingModel(
      id: 'saved-2',
      listing: _savedListing2,
      savedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SavedListingModel(
      id: 'saved-3',
      listing: _savedListing3,
      savedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  @override
  Future<List<SavedListingModel>> getSavedListings() async {
    return List<SavedListingModel>.unmodifiable(_savedListings);
  }

  @override
  Future<void> removeSavedListing(String listingId) async {
    _savedListings.removeWhere((entry) => entry.listing.id == listingId || entry.id == listingId);
  }
}
