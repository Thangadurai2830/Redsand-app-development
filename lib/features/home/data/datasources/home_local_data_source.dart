import '../models/home_model.dart';

abstract class HomeLocalDataSource {
  Future<List<ListingModel>> getFeaturedListings(String listingFor);
  Future<List<ListingModel>> getRecommendedListings(String listingFor);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<ListingModel>> getFeaturedListings(String listingFor) async {
    return _mockListings.where((l) => l.listingFor == listingFor && (l.isPremium || l.isBoosted)).toList();
  }

  @override
  Future<List<ListingModel>> getRecommendedListings(String listingFor) async {
    return _mockListings.where((l) => l.listingFor == listingFor).toList();
  }

  static const _mockListings = [
    ListingModel(
      id: '1', title: 'Spacious 3BHK in Whitefield',
      locality: 'Whitefield', city: 'Bangalore',
      price: 35000, type: 'apartment', listingFor: 'rent',
      imageUrl: '', isPremium: true, isBoosted: false, bedrooms: 3, areaSqft: 1450,
    ),
    ListingModel(
      id: '2', title: 'Modern Villa with Pool',
      locality: 'Koramangala', city: 'Bangalore',
      price: 120000, type: 'villa', listingFor: 'rent',
      imageUrl: '', isPremium: false, isBoosted: true, bedrooms: 4, areaSqft: 3200,
    ),
    ListingModel(
      id: '3', title: 'Affordable 2BHK Apartment',
      locality: 'Indiranagar', city: 'Bangalore',
      price: 18000, type: 'apartment', listingFor: 'rent',
      imageUrl: '', isPremium: false, isBoosted: false, bedrooms: 2, areaSqft: 950,
    ),
    ListingModel(
      id: '4', title: 'Premium PG for Working Professionals',
      locality: 'HSR Layout', city: 'Bangalore',
      price: 8000, type: 'pg', listingFor: 'rent',
      imageUrl: '', isPremium: true, isBoosted: false, bedrooms: 1, areaSqft: 200,
    ),
    ListingModel(
      id: '5', title: '4BHK Independent Villa for Sale',
      locality: 'Sarjapur', city: 'Bangalore',
      price: 8500000, type: 'villa', listingFor: 'buy',
      imageUrl: '', isPremium: true, isBoosted: true, bedrooms: 4, areaSqft: 2800,
    ),
    ListingModel(
      id: '6', title: 'Ready to Move 2BHK Flat',
      locality: 'Electronic City', city: 'Bangalore',
      price: 4200000, type: 'apartment', listingFor: 'buy',
      imageUrl: '', isPremium: false, isBoosted: false, bedrooms: 2, areaSqft: 1100,
    ),
  ];
}
