import 'package:flutter_app/features/filter/domain/entities/filter_entity.dart';
import 'package:flutter_app/features/saved_searches/data/models/saved_search_alert_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SavedSearchAlertModel.fromJson', () {
    test('parses standard keys correctly', () {
      final json = {
        'id': 'abc-123',
        'query': '2BHK Whitefield',
        'filter': {
          'listing_for': 'rent',
          'property_type': 'apartment',
          'city': 'Bangalore',
          'locality': 'Whitefield',
          'budget_min': 25000.0,
          'budget_max': 45000.0,
          'bhk': 2,
          'sort_by': 'newest',
        },
        'notify_push': true,
        'notify_in_app': false,
        'price_drop_alert': true,
        'saved_at': '2024-03-15T10:00:00.000Z',
        'new_match_count': 5,
        'last_matched_at': '2024-03-16T08:00:00.000Z',
      };

      final model = SavedSearchAlertModel.fromJson(json);

      expect(model.id, 'abc-123');
      expect(model.query, '2BHK Whitefield');
      expect(model.filter.listingFor, 'rent');
      expect(model.filter.propertyType, 'apartment');
      expect(model.filter.city, 'Bangalore');
      expect(model.filter.locality, 'Whitefield');
      expect(model.filter.minPrice, 25000.0);
      expect(model.filter.maxPrice, 45000.0);
      expect(model.filter.minBedrooms, 2);
      expect(model.notifyByPush, isTrue);
      expect(model.notifyInApp, isFalse);
      expect(model.priceDropAlert, isTrue);
      expect(model.newMatchCount, 5);
      expect(model.lastMatchedAt, isNotNull);
    });

    test('uses fallback values for missing optional fields', () {
      final json = <String, dynamic>{
        'id': 'x',
        'query': 'PG near metro',
      };

      final model = SavedSearchAlertModel.fromJson(json);

      expect(model.notifyByPush, isTrue);
      expect(model.notifyInApp, isTrue);
      expect(model.priceDropAlert, isFalse);
      expect(model.newMatchCount, 0);
      expect(model.lastMatchedAt, isNull);
      expect(model.filter.listingFor, 'rent');
      expect(model.filter.sortBy, 'newest');
    });

    test('accepts alternative key names (aliasing)', () {
      final json = {
        'search_id': 'alt-id',
        'keyword': 'villa buy',
        'push_enabled': false,
        'in_app_enabled': true,
        'notify_price_drop': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'unread_count': 3,
      };

      final model = SavedSearchAlertModel.fromJson(json);

      expect(model.id, 'alt-id');
      expect(model.query, 'villa buy');
      expect(model.notifyByPush, isFalse);
      expect(model.notifyInApp, isTrue);
      expect(model.priceDropAlert, isTrue);
      expect(model.newMatchCount, 3);
    });

    test('unwraps nested data envelope', () {
      final json = {
        'data': {
          'id': 'env-1',
          'query': 'studio rent',
        },
      };

      final model = SavedSearchAlertModel.fromJson(json);
      expect(model.id, 'env-1');
      expect(model.query, 'studio rent');
    });

    test('parses bool-like string values', () {
      final json = {
        'id': 'b',
        'query': 'q',
        'notify_push': 'yes',
        'notify_in_app': 'no',
        'price_drop_alert': '1',
      };

      final model = SavedSearchAlertModel.fromJson(json);
      expect(model.notifyByPush, isTrue);
      expect(model.notifyInApp, isFalse);
      expect(model.priceDropAlert, isTrue);
    });

    test('parses amenities as comma-separated string', () {
      final json = {
        'id': 'c',
        'query': 'q',
        'filter': {'amenities': 'gym,pool,parking'},
      };

      final model = SavedSearchAlertModel.fromJson(json);
      expect(model.filter.amenities, ['gym', 'pool', 'parking']);
    });

    test('parses amenities as List', () {
      final json = {
        'id': 'd',
        'query': 'q',
        'filter': {
          'amenities': ['gym', 'pool'],
        },
      };

      final model = SavedSearchAlertModel.fromJson(json);
      expect(model.filter.amenities, ['gym', 'pool']);
    });
  });

  group('SavedSearchAlertModel.toJson', () {
    test('serializes all fields', () {
      final model = SavedSearchAlertModel(
        id: 'ser-1',
        query: 'apartment rent',
        filter: const FilterEntity(
          listingFor: 'rent',
          propertyType: 'apartment',
          city: 'Chennai',
          sortBy: 'price_asc',
        ),
        notifyByPush: true,
        notifyInApp: false,
        priceDropAlert: true,
        savedAt: DateTime.utc(2024, 6, 1),
        newMatchCount: 2,
        lastMatchedAt: DateTime.utc(2024, 6, 2),
      );

      final json = model.toJson();

      expect(json['id'], 'ser-1');
      expect(json['query'], 'apartment rent');
      expect(json['notify_push'], isTrue);
      expect(json['notify_in_app'], isFalse);
      expect(json['price_drop_alert'], isTrue);
      expect(json['new_match_count'], 2);
      expect(json['last_matched_at'], isNotNull);
      expect(json['filter'], isA<Map>());
    });

    test('omits last_matched_at when null', () {
      final model = SavedSearchAlertModel(
        id: 'no-date',
        query: 'q',
        filter: const FilterEntity(),
        savedAt: DateTime(2024),
      );

      final json = model.toJson();
      expect(json.containsKey('last_matched_at'), isFalse);
    });
  });

  group('SavedSearchAlertModel.toRequestJson', () {
    test('omits id and server-side fields', () {
      final model = SavedSearchAlertModel(
        id: 'should-not-appear',
        query: 'pg rent',
        filter: const FilterEntity(),
        savedAt: DateTime(2024),
      );

      final json = model.toRequestJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('saved_at'), isFalse);
      expect(json.containsKey('new_match_count'), isFalse);
      expect(json['query'], 'pg rent');
    });
  });

  group('SavedSearchAlert entity helpers', () {
    test('searchLabel returns trimmed query when non-empty', () {
      final alert = SavedSearchAlertModel(
        id: '1',
        query: '  villa for sale  ',
        filter: const FilterEntity(),
        savedAt: DateTime(2024),
      );
      expect(alert.searchLabel, 'villa for sale');
    });

    test('searchLabel returns "Filtered search" when query empty but filter active', () {
      final alert = SavedSearchAlertModel(
        id: '2',
        query: '',
        filter: const FilterEntity(city: 'Mumbai'),
        savedAt: DateTime(2024),
      );
      expect(alert.searchLabel, 'Filtered search');
    });

    test('searchLabel returns "Saved search" when query empty and no filters', () {
      final alert = SavedSearchAlertModel(
        id: '3',
        query: '',
        filter: const FilterEntity(),
        savedAt: DateTime(2024),
      );
      expect(alert.searchLabel, 'Saved search');
    });

    test('hasNotificationChannels is true when at least one channel enabled', () {
      final a = SavedSearchAlertModel(
        id: '4',
        query: 'q',
        filter: const FilterEntity(),
        savedAt: DateTime(2024),
        notifyByPush: false,
        notifyInApp: true,
      );
      expect(a.hasNotificationChannels, isTrue);
    });

    test('hasNotificationChannels is false when both disabled', () {
      final a = SavedSearchAlertModel(
        id: '5',
        query: 'q',
        filter: const FilterEntity(),
        savedAt: DateTime(2024),
        notifyByPush: false,
        notifyInApp: false,
      );
      expect(a.hasNotificationChannels, isFalse);
    });
  });
}
