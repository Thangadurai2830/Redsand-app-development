import 'package:dartz/dartz.dart';
import 'package:flutter_app/core/error/failures.dart';
import 'package:flutter_app/features/filter/domain/entities/filter_entity.dart';
import 'package:flutter_app/features/saved_searches/data/datasources/saved_searches_local_data_source.dart';
import 'package:flutter_app/features/saved_searches/data/datasources/saved_searches_remote_data_source.dart';
import 'package:flutter_app/features/saved_searches/data/models/saved_search_alert_model.dart';
import 'package:flutter_app/features/saved_searches/data/repositories/saved_searches_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fake data sources ────────────────────────────────────────────────────────

class _FakeRemote implements SavedSearchesRemoteDataSource {
  List<SavedSearchAlertModel>? searches;
  bool throwOnGet = false;
  bool throwOnSave = false;
  bool throwOnRemove = false;
  SavedSearchAlertModel? savedResult;

  @override
  Future<List<SavedSearchAlertModel>> getSavedSearches() async {
    if (throwOnGet) throw Exception('remote error');
    return searches ?? [];
  }

  @override
  Future<SavedSearchAlertModel> saveSavedSearch(SavedSearchAlertModel s) async {
    if (throwOnSave) throw Exception('remote error');
    return savedResult ?? s;
  }

  @override
  Future<void> removeSavedSearch(String id) async {
    if (throwOnRemove) throw Exception('remote error');
    searches?.removeWhere((e) => e.id == id);
  }
}

class _FakeLocal implements SavedSearchesLocalDataSource {
  List<SavedSearchAlertModel> searches = [];
  bool throwOnGet = false;
  bool throwOnSave = false;
  bool throwOnRemove = false;
  SavedSearchAlertModel? savedResult;

  @override
  Future<List<SavedSearchAlertModel>> getSavedSearches() async {
    if (throwOnGet) throw Exception('cache error');
    return List.from(searches);
  }

  @override
  Future<SavedSearchAlertModel> saveSavedSearch(SavedSearchAlertModel s) async {
    if (throwOnSave) throw Exception('cache error');
    searches.add(savedResult ?? s);
    return savedResult ?? s;
  }

  @override
  Future<void> removeSavedSearch(String id) async {
    if (throwOnRemove) throw Exception('cache error');
    searches.removeWhere((e) => e.id == id);
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

SavedSearchAlertModel _model({String id = 'id-1', String query = '2BHK'}) =>
    SavedSearchAlertModel(
      id: id,
      query: query,
      filter: const FilterEntity(listingFor: 'rent'),
      savedAt: DateTime(2024),
    );

SavedSearchesRepositoryImpl _repo(_FakeRemote remote, _FakeLocal local) =>
    SavedSearchesRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('getSavedSearches', () {
    test('returns remote data when remote succeeds', () async {
      final model = _model();
      final remote = _FakeRemote()..searches = [model];
      final local = _FakeLocal();

      final result = await _repo(remote, local).getSavedSearches();

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (list) => expect(list, [model]));
    });

    test('falls back to local cache when remote throws', () async {
      final model = _model();
      final remote = _FakeRemote()..throwOnGet = true;
      final local = _FakeLocal()..searches = [model];

      final result = await _repo(remote, local).getSavedSearches();

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (list) => expect(list, [model]));
    });

    test('returns CacheFailure when both remote and local throw', () async {
      final remote = _FakeRemote()..throwOnGet = true;
      final local = _FakeLocal()..throwOnGet = true;

      final result = await _repo(remote, local).getSavedSearches();

      expect(result, isA<Left>());
      expect((result as Left).value, isA<CacheFailure>());
    });
  });

  group('saveSavedSearch', () {
    test('saves via remote and also persists locally', () async {
      final model = _model();
      final remote = _FakeRemote()..savedResult = model;
      final local = _FakeLocal();

      final result = await _repo(remote, local).saveSavedSearch(model);

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (saved) => expect(saved.id, model.id));
      expect(local.searches, contains(model));
    });

    test('falls back to local save when remote throws', () async {
      final model = _model(id: 'local-save');
      final remote = _FakeRemote()..throwOnSave = true;
      final local = _FakeLocal()..savedResult = model;

      final result = await _repo(remote, local).saveSavedSearch(model);

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (saved) => expect(saved.id, 'local-save'));
    });

    test('returns CacheFailure when both remote and local throw on save', () async {
      final model = _model();
      final remote = _FakeRemote()..throwOnSave = true;
      final local = _FakeLocal()..throwOnSave = true;

      final result = await _repo(remote, local).saveSavedSearch(model);

      expect(result, isA<Left>());
      expect((result as Left).value, isA<CacheFailure>());
    });

    test('succeeds even when local persistence throws after remote success', () async {
      final model = _model();
      final remote = _FakeRemote()..savedResult = model;
      final local = _FakeLocal()..throwOnSave = true;

      final result = await _repo(remote, local).saveSavedSearch(model);

      // Remote succeeded — local failure is best-effort and should not fail
      expect(result.isRight(), isTrue);
    });
  });

  group('removeSavedSearch', () {
    test('removes from local and returns Right when local succeeds', () async {
      final model = _model(id: 'del-1');
      final remote = _FakeRemote()..searches = [model];
      final local = _FakeLocal()..searches = [model];

      final result = await _repo(remote, local).removeSavedSearch('del-1');

      expect(result.isRight(), isTrue);
      expect(local.searches.any((s) => s.id == 'del-1'), isFalse);
    });

    test('returns CacheFailure when local remove throws', () async {
      final remote = _FakeRemote();
      final local = _FakeLocal()..throwOnRemove = true;

      final result = await _repo(remote, local).removeSavedSearch('any-id');

      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) {});
    });

    test('still removes locally even when remote throws', () async {
      final model = _model(id: 'rem-2');
      final remote = _FakeRemote()..throwOnRemove = true;
      final local = _FakeLocal()..searches = [model];

      final result = await _repo(remote, local).removeSavedSearch('rem-2');

      expect(result.isRight(), isTrue);
      expect(local.searches, isEmpty);
    });
  });
}
