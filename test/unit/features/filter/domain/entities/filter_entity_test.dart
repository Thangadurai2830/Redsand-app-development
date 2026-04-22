import 'package:flutter_app/features/filter/domain/entities/filter_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FilterEntity – hasActiveFilters', () {
    test('returns false for default entity', () {
      const f = FilterEntity();
      expect(f.hasActiveFilters, isFalse);
    });

    test('returns true when propertyType set', () {
      const f = FilterEntity(propertyType: 'apartment');
      expect(f.hasActiveFilters, isTrue);
    });

    test('returns true when furnishing set', () {
      const f = FilterEntity(furnishing: 'furnished');
      expect(f.hasActiveFilters, isTrue);
    });

    test('returns true when amenities non-empty', () {
      const f = FilterEntity(amenities: ['gym']);
      expect(f.hasActiveFilters, isTrue);
    });

    test('returns true when city set', () {
      const f = FilterEntity(city: 'Chennai');
      expect(f.hasActiveFilters, isTrue);
    });

    test('returns true when locality set', () {
      const f = FilterEntity(locality: 'Anna Nagar');
      expect(f.hasActiveFilters, isTrue);
    });

    test('returns true when minPrice set', () {
      const f = FilterEntity(minPrice: 10000);
      expect(f.hasActiveFilters, isTrue);
    });

    test('returns true when maxPrice set', () {
      const f = FilterEntity(maxPrice: 50000);
      expect(f.hasActiveFilters, isTrue);
    });

    test('returns true when minBedrooms set', () {
      const f = FilterEntity(minBedrooms: 2);
      expect(f.hasActiveFilters, isTrue);
    });

    test('returns true when minAreaSqft set', () {
      const f = FilterEntity(minAreaSqft: 800);
      expect(f.hasActiveFilters, isTrue);
    });
  });

  group('FilterEntity – copyWith', () {
    const base = FilterEntity(
      listingFor: 'rent',
      propertyType: 'apartment',
      city: 'Bangalore',
      minBedrooms: 2,
    );

    test('copies with updated field', () {
      final copy = base.copyWith(listingFor: 'buy');
      expect(copy.listingFor, 'buy');
      expect(copy.city, 'Bangalore');
    });

    test('clearPropertyType sets propertyType to null', () {
      final copy = base.copyWith(clearPropertyType: true);
      expect(copy.propertyType, isNull);
      expect(copy.city, 'Bangalore');
    });

    test('clearCity sets city to null', () {
      final copy = base.copyWith(clearCity: true);
      expect(copy.city, isNull);
    });

    test('clearAmenities resets to empty list', () {
      const withAmenities = FilterEntity(amenities: ['gym', 'pool']);
      final copy = withAmenities.copyWith(clearAmenities: true);
      expect(copy.amenities, isEmpty);
    });

    test('clearMinPrice sets minPrice to null', () {
      const f = FilterEntity(minPrice: 20000);
      final copy = f.copyWith(clearMinPrice: true);
      expect(copy.minPrice, isNull);
    });

    test('clearMaxPrice sets maxPrice to null', () {
      const f = FilterEntity(maxPrice: 80000);
      final copy = f.copyWith(clearMaxPrice: true);
      expect(copy.maxPrice, isNull);
    });

    test('clearMinBedrooms sets minBedrooms to null', () {
      final copy = base.copyWith(clearMinBedrooms: true);
      expect(copy.minBedrooms, isNull);
    });

    test('clearMinAreaSqft sets minAreaSqft to null', () {
      const f = FilterEntity(minAreaSqft: 500);
      final copy = f.copyWith(clearMinAreaSqft: true);
      expect(copy.minAreaSqft, isNull);
    });

    test('does not mutate original', () {
      base.copyWith(listingFor: 'buy');
      expect(base.listingFor, 'rent');
    });
  });

  group('FilterEntity – toQueryParameters', () {
    test('always includes listing_for and sort_by', () {
      const f = FilterEntity();
      final params = f.toQueryParameters();
      expect(params['listing_for'], 'rent');
      expect(params['sort_by'], 'newest');
    });

    test('omits null optional fields', () {
      const f = FilterEntity();
      final params = f.toQueryParameters();
      expect(params.containsKey('property_type'), isFalse);
      expect(params.containsKey('furnishing'), isFalse);
      expect(params.containsKey('city'), isFalse);
      expect(params.containsKey('budget_min'), isFalse);
    });

    test('includes non-null optional fields', () {
      const f = FilterEntity(
        listingFor: 'buy',
        propertyType: 'villa',
        furnishing: 'furnished',
        city: 'Hyderabad',
        locality: 'Banjara Hills',
        minPrice: 5000000,
        maxPrice: 10000000,
        minBedrooms: 3,
        minAreaSqft: 1200,
        sortBy: 'price_desc',
      );
      final params = f.toQueryParameters();

      expect(params['listing_for'], 'buy');
      expect(params['property_type'], 'villa');
      expect(params['furnishing'], 'furnished');
      expect(params['city'], 'Hyderabad');
      expect(params['locality'], 'Banjara Hills');
      expect(params['budget_min'], 5000000);
      expect(params['budget_max'], 10000000);
      expect(params['bhk'], 3);
      expect(params['area_min_sqft'], 1200);
      expect(params['sort_by'], 'price_desc');
    });

    test('joins amenities with comma', () {
      const f = FilterEntity(amenities: ['gym', 'pool', 'parking']);
      final params = f.toQueryParameters();
      expect(params['amenities'], 'gym,pool,parking');
    });

    test('omits amenities key when list is empty', () {
      const f = FilterEntity();
      final params = f.toQueryParameters();
      expect(params.containsKey('amenities'), isFalse);
    });

    test('trims whitespace from city and locality', () {
      const f = FilterEntity(city: '  Mumbai  ', locality: '  Bandra  ');
      final params = f.toQueryParameters();
      expect(params['city'], 'Mumbai');
      expect(params['locality'], 'Bandra');
    });

    test('omits city when blank string', () {
      const f = FilterEntity(city: '   ');
      final params = f.toQueryParameters();
      expect(params.containsKey('city'), isFalse);
    });
  });

  group('FilterEntity – equality', () {
    test('two identical entities are equal', () {
      const a = FilterEntity(listingFor: 'rent', city: 'Pune');
      const b = FilterEntity(listingFor: 'rent', city: 'Pune');
      expect(a, equals(b));
    });

    test('entities with different fields are not equal', () {
      const a = FilterEntity(listingFor: 'rent');
      const b = FilterEntity(listingFor: 'buy');
      expect(a, isNot(equals(b)));
    });
  });
}
