import 'package:dartz/dartz.dart';
import 'package:flutter_app/core/error/failures.dart';
import 'package:flutter_app/features/filter/domain/entities/filter_entity.dart';
import 'package:flutter_app/features/saved_searches/domain/entities/saved_search_alert.dart';
import 'package:flutter_app/features/saved_searches/presentation/bloc/saved_searches_bloc.dart';
import 'package:flutter_app/features/saved_searches/presentation/bloc/saved_searches_event.dart';
import 'package:flutter_app/features/saved_searches/presentation/bloc/saved_searches_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_fakes.dart';

const _filter = FilterEntity(listingFor: 'rent');

SavedSearchAlert _alert({String id = 'id-1', String query = '2BHK Koramangala'}) =>
    SavedSearchAlert(
      id: id,
      query: query,
      filter: _filter,
      savedAt: DateTime(2024, 1, 1),
      notifyByPush: true,
      notifyInApp: true,
      priceDropAlert: false,
    );

SavedSearchesBloc _bloc({
  required FakeGetSavedSearches get,
  required FakeSaveSavedSearch save,
  required FakeRemoveSavedSearch remove,
}) =>
    SavedSearchesBloc(
      getSavedSearches: get,
      saveSavedSearch: save,
      removeSavedSearch: remove,
    );

void main() {
  group('SavedSearchesBloc – LoadRequested', () {
    test('emits loading then loaded on success', () async {
      final alert = _alert();
      final bloc = _bloc(
        get: FakeGetSavedSearches(Right([alert])),
        save: FakeSaveSavedSearch(Right(alert)),
        remove: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesLoadRequested());

      final states = await bloc.stream.take(2).toList();
      expect(states[0].status, SavedSearchesStatus.loading);
      expect(states[1].status, SavedSearchesStatus.loaded);
      expect(states[1].searches, [alert]);
      expect(states[1].isSaving, isFalse);
      await bloc.close();
    });

    test('emits loading then failure on network error', () async {
      final bloc = _bloc(
        get: FakeGetSavedSearches(Left(NetworkFailure())),
        save: FakeSaveSavedSearch(Left(NetworkFailure())),
        remove: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesLoadRequested());

      final states = await bloc.stream.take(2).toList();
      expect(states[0].status, SavedSearchesStatus.loading);
      expect(states[1].status, SavedSearchesStatus.failure);
      expect(states[1].message, isNotNull);
      await bloc.close();
    });

    test('emits cache failure message on CacheFailure', () async {
      final bloc = _bloc(
        get: FakeGetSavedSearches(Left(CacheFailure())),
        save: FakeSaveSavedSearch(Left(NetworkFailure())),
        remove: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesLoadRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == SavedSearchesStatus.failure,
      );
      expect(state.message, contains('Unable to update saved searches'));
      await bloc.close();
    });
  });

  group('SavedSearchesBloc – RefreshRequested', () {
    test('emits loaded with refresh message on success', () async {
      final alert = _alert();
      final bloc = _bloc(
        get: FakeGetSavedSearches(Right([alert])),
        save: FakeSaveSavedSearch(Right(alert)),
        remove: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesRefreshRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == SavedSearchesStatus.loaded,
      );
      expect(state.searches, [alert]);
      expect(state.message, 'Saved searches refreshed');
      await bloc.close();
    });

    test('emits failure on network error', () async {
      final bloc = _bloc(
        get: FakeGetSavedSearches(Left(NetworkFailure())),
        save: FakeSaveSavedSearch(Left(NetworkFailure())),
        remove: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesRefreshRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == SavedSearchesStatus.failure,
      );
      expect(state.message, isNotNull);
      await bloc.close();
    });
  });

  group('SavedSearchesBloc – SaveRequested', () {
    test('emits isSaving then loaded with success message', () async {
      final alert = _alert(id: 'new-id');
      final bloc = _bloc(
        get: FakeGetSavedSearches(const Right([])),
        save: FakeSaveSavedSearch(Right(alert)),
        remove: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesSaveRequested(
        query: '2BHK Koramangala',
        filter: _filter,
        notifyByPush: true,
        notifyInApp: true,
        priceDropAlert: false,
      ));

      final states = await bloc.stream.take(2).toList();
      expect(states[0].isSaving, isTrue);
      expect(states[1].status, SavedSearchesStatus.loaded);
      expect(states[1].isSaving, isFalse);
      expect(states[1].message, 'Saved search alert added');
      expect(states[1].searches, contains(alert));
      await bloc.close();
    });

    test('emits failure message on save error', () async {
      final bloc = _bloc(
        get: FakeGetSavedSearches(const Right([])),
        save: FakeSaveSavedSearch(Left(NetworkFailure())),
        remove: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesSaveRequested(
        query: 'test',
        filter: _filter,
        notifyByPush: false,
        notifyInApp: true,
        priceDropAlert: false,
      ));

      final state = await bloc.stream.firstWhere((s) => !s.isSaving);
      expect(state.message, isNotNull);
      await bloc.close();
    });

    test('upserts existing search by id', () async {
      final existing = _alert(id: 'same-id', query: 'old query');
      final updated = _alert(id: 'same-id', query: 'new query');

      final bloc = SavedSearchesBloc(
        getSavedSearches: FakeGetSavedSearches(Right([existing])),
        saveSavedSearch: FakeSaveSavedSearch(Right(updated)),
        removeSavedSearch: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesLoadRequested());
      await bloc.stream.firstWhere((s) => s.status == SavedSearchesStatus.loaded);

      bloc.add(const SavedSearchesSaveRequested(
        query: 'new query',
        filter: _filter,
        notifyByPush: true,
        notifyInApp: true,
        priceDropAlert: false,
      ));

      final state = await bloc.stream.firstWhere(
        (s) => s.message == 'Saved search alert added',
      );
      expect(state.searches.where((s) => s.id == 'same-id').length, 1);
      await bloc.close();
    });
  });

  group('SavedSearchesBloc – RemoveRequested', () {
    test('adds id to removingIds then removes search on success', () async {
      final alert = _alert(id: 'rem-1');

      final bloc = SavedSearchesBloc(
        getSavedSearches: FakeGetSavedSearches(Right([alert])),
        saveSavedSearch: FakeSaveSavedSearch(Right(alert)),
        removeSavedSearch: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesLoadRequested());
      await bloc.stream.firstWhere((s) => s.status == SavedSearchesStatus.loaded);

      bloc.add(const SavedSearchesRemoveRequested('rem-1'));
      final removing = await bloc.stream.first;
      expect(removing.removingIds, contains('rem-1'));

      final done = await bloc.stream.first;
      expect(done.searches, isEmpty);
      expect(done.removingIds, isNot(contains('rem-1')));
      expect(done.message, 'Saved search removed');
      await bloc.close();
    });

    test('second remove while first is in-flight is ignored', () async {
      final alert = _alert(id: 'dup-1');

      final bloc = SavedSearchesBloc(
        getSavedSearches: FakeGetSavedSearches(Right([alert])),
        saveSavedSearch: FakeSaveSavedSearch(Right(alert)),
        removeSavedSearch: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesLoadRequested());
      await bloc.stream.firstWhere((s) => s.status == SavedSearchesStatus.loaded);

      // Add twice — second should be ignored while first is removing
      bloc.add(const SavedSearchesRemoveRequested('dup-1'));
      // Wait for removingIds to contain the id
      await bloc.stream.firstWhere((s) => s.removingIds.contains('dup-1'));
      // Second event after in-flight — BLoC returns early since id already in removingIds
      bloc.add(const SavedSearchesRemoveRequested('dup-1'));

      final done = await bloc.stream.firstWhere((s) => s.message == 'Saved search removed');
      // Item removed exactly once
      expect(done.searches.where((s) => s.id == 'dup-1'), isEmpty);
      await bloc.close();
    });

    test('restores id from removingIds on failure', () async {
      final alert = _alert(id: 'fail-1');

      final bloc = SavedSearchesBloc(
        getSavedSearches: FakeGetSavedSearches(Right([alert])),
        saveSavedSearch: FakeSaveSavedSearch(Right(alert)),
        removeSavedSearch: FakeRemoveSavedSearch(Left(NetworkFailure())),
      );

      bloc.add(const SavedSearchesLoadRequested());
      await bloc.stream.firstWhere((s) => s.status == SavedSearchesStatus.loaded);

      bloc.add(const SavedSearchesRemoveRequested('fail-1'));
      final state = await bloc.stream.firstWhere((s) => s.message != null);
      expect(state.removingIds, isNot(contains('fail-1')));
      expect(state.message, isNotNull);
      await bloc.close();
    });
  });

  group('SavedSearchesBloc – ClearMessage', () {
    test('clears message from state', () async {
      final alert = _alert();
      final bloc = SavedSearchesBloc(
        getSavedSearches: FakeGetSavedSearches(Left(NetworkFailure())),
        saveSavedSearch: FakeSaveSavedSearch(Right(alert)),
        removeSavedSearch: FakeRemoveSavedSearch(const Right(null)),
      );

      bloc.add(const SavedSearchesLoadRequested());
      await bloc.stream.firstWhere((s) => s.message != null);

      bloc.add(const SavedSearchesClearMessageRequested());
      final state = await bloc.stream.first;
      expect(state.message, isNull);
      await bloc.close();
    });
  });

  group('SavedSearchesState computed properties', () {
    test('isEmpty returns true when searches list is empty', () {
      const state = SavedSearchesState.initial();
      expect(state.isEmpty, isTrue);
    });

    test('pushEnabledCount counts correctly', () {
      final a1 = _alert(id: '1');
      final a2 = SavedSearchAlert(
        id: '2',
        query: 'q',
        filter: _filter,
        savedAt: DateTime(2024),
        notifyByPush: false,
      );
      final state = SavedSearchesState(
        status: SavedSearchesStatus.loaded,
        searches: [a1, a2],
        isSaving: false,
        removingIds: const {},
      );
      expect(state.pushEnabledCount, 1);
    });

    test('inAppEnabledCount counts correctly', () {
      final a1 = _alert(id: '1');
      final a2 = SavedSearchAlert(
        id: '2',
        query: 'q',
        filter: _filter,
        savedAt: DateTime(2024),
        notifyInApp: false,
      );
      final state = SavedSearchesState(
        status: SavedSearchesStatus.loaded,
        searches: [a1, a2],
        isSaving: false,
        removingIds: const {},
      );
      expect(state.inAppEnabledCount, 1);
    });

    test('priceDropAlertCount counts correctly', () {
      final a1 = SavedSearchAlert(
        id: '1',
        query: 'q',
        filter: _filter,
        savedAt: DateTime(2024),
        priceDropAlert: true,
      );
      final a2 = _alert(id: '2');
      final state = SavedSearchesState(
        status: SavedSearchesStatus.loaded,
        searches: [a1, a2],
        isSaving: false,
        removingIds: const {},
      );
      expect(state.priceDropAlertCount, 1);
    });
  });
}
