import 'dart:convert';

import 'package:flutter_app/features/filter/domain/entities/filter_entity.dart';
import 'package:flutter_app/features/saved_searches/data/datasources/saved_searches_local_data_source.dart';
import 'package:flutter_app/features/saved_searches/data/models/saved_search_alert_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'saved_search_alerts';

SavedSearchAlertModel _model({
  String id = 'id-1',
  String query = '2BHK Whitefield',
}) =>
    SavedSearchAlertModel(
      id: id,
      query: query,
      filter: const FilterEntity(
        listingFor: 'rent',
        city: 'Bangalore',
        sortBy: 'newest',
      ),
      notifyByPush: true,
      notifyInApp: true,
      savedAt: DateTime.utc(2024, 1, 1),
    );

SavedSearchesLocalDataSourceImpl _source(SharedPreferences prefs) =>
    SavedSearchesLocalDataSourceImpl(sharedPreferences: prefs);

void main() {
  group('SavedSearchesLocalDataSourceImpl – getSavedSearches', () {
    test('returns seeded data when preferences key is absent', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final result = await _source(prefs).getSavedSearches();

      expect(result, isNotEmpty);
      expect(result.first, isA<SavedSearchAlertModel>());
    });

    test('returns persisted data when key exists', () async {
      final model = _model();
      final encoded = jsonEncode([model.toJson()]);
      SharedPreferences.setMockInitialValues({_key: encoded});
      final prefs = await SharedPreferences.getInstance();

      final result = await _source(prefs).getSavedSearches();

      expect(result.length, 1);
      expect(result.first.id, 'id-1');
      expect(result.first.query, '2BHK Whitefield');
    });

    test('returns seeded data when stored value is invalid JSON list', () async {
      SharedPreferences.setMockInitialValues({_key: '"not-a-list"'});
      final prefs = await SharedPreferences.getInstance();

      final result = await _source(prefs).getSavedSearches();

      expect(result, isNotEmpty);
    });
  });

  group('SavedSearchesLocalDataSourceImpl – saveSavedSearch', () {
    test('assigns a generated id when id is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final model = _model(id: '');

      final result = await _source(prefs).saveSavedSearch(model);

      expect(result.id, isNotEmpty);
      expect(result.id, isNot(''));
    });

    test('keeps provided id when non-empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final model = _model(id: 'my-id');

      final result = await _source(prefs).saveSavedSearch(model);

      expect(result.id, 'my-id');
    });

    test('prepends new search at position 0', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final src = _source(prefs);

      await src.saveSavedSearch(_model(id: 'first'));
      await src.saveSavedSearch(_model(id: 'second'));

      final list = await src.getSavedSearches();
      expect(list.first.id, 'second');
    });

    test('replaces existing entry with same id (upsert)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final src = _source(prefs);

      await src.saveSavedSearch(_model(id: 'dup', query: 'old'));
      await src.saveSavedSearch(_model(id: 'dup', query: 'new'));

      final list = await src.getSavedSearches();
      final matches = list.where((s) => s.id == 'dup').toList();
      expect(matches.length, 1);
      expect(matches.first.query, 'new');
    });

    test('persists across separate source instances (same prefs)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await _source(prefs).saveSavedSearch(_model(id: 'persist-1'));

      final result = await _source(prefs).getSavedSearches();
      expect(result.any((s) => s.id == 'persist-1'), isTrue);
    });
  });

  group('SavedSearchesLocalDataSourceImpl – removeSavedSearch', () {
    test('removes entry with matching id', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final src = _source(prefs);

      await src.saveSavedSearch(_model(id: 'rem-1'));
      await src.saveSavedSearch(_model(id: 'rem-2'));
      await src.removeSavedSearch('rem-1');

      final list = await src.getSavedSearches();
      expect(list.any((s) => s.id == 'rem-1'), isFalse);
      expect(list.any((s) => s.id == 'rem-2'), isTrue);
    });

    test('does not throw when id not found', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await expectLater(
        _source(prefs).removeSavedSearch('non-existent'),
        completes,
      );
    });
  });
}
