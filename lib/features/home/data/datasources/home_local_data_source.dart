import '../../../filter/domain/entities/filter_entity.dart';
import '../models/home_model.dart';

abstract class HomeLocalDataSource {
  Future<List<ListingModel>> getFeaturedListings(String listingFor);
  Future<List<ListingModel>> getRecommendedListings(String listingFor);
  Future<List<ListingModel>> searchListings(String query, String listingFor, {FilterEntity? filter});
  Future<List<SearchSuggestionModel>> getSearchSuggestions(String query);
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

  @override
  Future<List<ListingModel>> searchListings(String query, String listingFor, {FilterEntity? filter}) async {
    final q = query.trim().toLowerCase();
    return _mockListings.where((l) {
      if (l.listingFor != listingFor) return false;
      if (q.isNotEmpty) {
        final matchesQuery = l.title.toLowerCase().contains(q) ||
            l.locality.toLowerCase().contains(q) ||
            l.city.toLowerCase().contains(q) ||
            l.type.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }
      if (filter != null) {
        if (filter.propertyType != null && l.type != filter.propertyType) return false;
        if (filter.city != null && filter.city!.trim().isNotEmpty &&
            l.city.toLowerCase() != filter.city!.trim().toLowerCase()) return false;
        if (filter.locality != null && filter.locality!.trim().isNotEmpty &&
            !l.locality.toLowerCase().contains(filter.locality!.trim().toLowerCase())) return false;
        if (filter.minPrice != null && l.price < filter.minPrice!) return false;
        if (filter.maxPrice != null && l.price > filter.maxPrice!) return false;
        if (filter.minBedrooms != null && l.bedrooms < filter.minBedrooms!) return false;
        if (filter.minAreaSqft != null && l.areaSqft < filter.minAreaSqft!) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<SearchSuggestionModel>> getSearchSuggestions(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final localities = _mockListings
        .map((l) => l.locality)
        .toSet()
        .where((loc) => loc.toLowerCase().contains(q))
        .map((loc) => SearchSuggestionModel(id: loc, text: loc, type: 'locality'))
        .toList();
    return localities;
  }

  static const _mockListings = [
    ListingModel(
      id: '1', title: 'Spacious 3BHK in Whitefield',
      locality: 'Whitefield', city: 'Bangalore',
      price: 35000, type: 'apartment', listingFor: 'rent',
      imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80',
      isPremium: true, isBoosted: false, bedrooms: 3, areaSqft: 1450,
      amenities: ['Clubhouse', 'Power Backup', 'Covered Parking'],
    ),
    ListingModel(
      id: '2', title: 'Modern Villa with Pool',
      locality: 'Koramangala', city: 'Bangalore',
      price: 120000, type: 'villa', listingFor: 'rent',
      imageUrl: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=80',
      isPremium: false, isBoosted: true, bedrooms: 4, areaSqft: 3200,
      amenities: ['Private Pool', 'Garden', 'Security'],
    ),
    ListingModel(
      id: '3', title: 'Affordable 2BHK Apartment',
      locality: 'Indiranagar', city: 'Bangalore',
      price: 18000, type: 'apartment', listingFor: 'rent',
      imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
      isPremium: false, isBoosted: false, bedrooms: 2, areaSqft: 950,
      amenities: ['Lift', 'Security', 'Park'],
    ),
    ListingModel(
      id: '4', title: 'Premium PG for Working Professionals',
      locality: 'HSR Layout', city: 'Bangalore',
      price: 8000, type: 'pg', listingFor: 'rent',
      imageUrl: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80',
      isPremium: true, isBoosted: false, bedrooms: 1, areaSqft: 200,
      amenities: ['Meals Included', 'Wi-Fi', 'Housekeeping'],
    ),
    ListingModel(
      id: '5', title: '4BHK Independent Villa for Sale',
      locality: 'Sarjapur', city: 'Bangalore',
      price: 8500000, type: 'villa', listingFor: 'buy',
      imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=80',
      isPremium: true, isBoosted: true, bedrooms: 4, areaSqft: 2800,
      amenities: ['Clubhouse', 'Garden', 'Gym'],
    ),
    ListingModel(
      id: '6', title: 'Ready to Move 2BHK Flat',
      locality: 'Electronic City', city: 'Bangalore',
      price: 4200000, type: 'apartment', listingFor: 'buy',
      imageUrl: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&q=80',
      isPremium: false, isBoosted: false, bedrooms: 2, areaSqft: 1100,
      amenities: ['Lift', 'Power Backup', 'Children Play Area'],
    ),
  ];
}
