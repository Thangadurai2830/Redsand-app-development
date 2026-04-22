import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/home/data/models/home_model.dart';

void main() {
  test('parses listing JSON with amenity list and defaults', () {
    final model = ListingModel.fromJson(const {
      'id': 'listing-1',
      'title': 'Spacious 2BHK',
      'locality': 'Indiranagar',
      'city': 'Bengaluru',
      'price': 25000,
      'type': 'apartment',
      'listing_for': 'rent',
      'image_url': 'https://example.com/listing.png',
      'is_premium': true,
      'is_boosted': false,
      'bedrooms': 2,
      'area_sqft': 1250,
      'amenities': ['lift', 'gym', 123],
    });

    expect(model.amenities, ['lift', 'gym']);
    expect(model.isPremium, isTrue);
    expect(model.areaSqft, 1250);
    expect(model.toJson()['title'], 'Spacious 2BHK');
  });

  test('parses listing amenities from comma separated strings', () {
    final model = ListingModel.fromJson(const {
      'id': 'listing-2',
      'title': 'Studio',
      'locality': 'Whitefield',
      'city': 'Bengaluru',
      'price': 18000,
      'type': 'studio',
      'listing_for': 'rent',
      'image_url': 'https://example.com/studio.png',
      'amenities': 'pool, gym, , security',
    });

    expect(model.amenities, ['pool', 'gym', 'security']);
  });
}

