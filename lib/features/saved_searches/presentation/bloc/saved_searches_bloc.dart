import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/saved_search_alert.dart';
import '../../domain/usecases/get_saved_searches.dart';
import '../../domain/usecases/remove_saved_search.dart';
import '../../domain/usecases/save_saved_search.dart';
import 'saved_searches_event.dart';
import 'saved_searches_state.dart';

class SavedSearchesBloc extends Bloc<SavedSearchesEvent, SavedSearchesState> {
  final GetSavedSearches getSavedSearches;
  final SaveSavedSearch saveSavedSearch;
  final RemoveSavedSearch removeSavedSearch;

  SavedSearchesBloc({
    required this.getSavedSearches,
    required this.saveSavedSearch,
    required this.removeSavedSearch,
  }) : super(const SavedSearchesState.initial()) {
    on<SavedSearchesLoadRequested>(_onLoad);
    on<SavedSearchesRefreshRequested>(_onRefresh);
    on<SavedSearchesSaveRequested>(_onSave);
    on<SavedSearchesRemoveRequested>(_onRemove);
    on<SavedSearchesClearMessageRequested>(_onClearMessage);
  }

  Future<void> _onLoad(
    SavedSearchesLoadRequested event,
    Emitter<SavedSearchesState> emit,
  ) async {
    emit(state.copyWith(status: SavedSearchesStatus.loading, message: null));
    final result = await getSavedSearches();
    result.fold(
      (failure) => emit(state.copyWith(
        status: SavedSearchesStatus.failure,
        message: _messageForFailure(failure),
      )),
      (searches) => emit(state.copyWith(
        status: SavedSearchesStatus.loaded,
        searches: searches,
        removingIds: const {},
        isSaving: false,
        message: null,
      )),
    );
  }

  Future<void> _onRefresh(
    SavedSearchesRefreshRequested event,
    Emitter<SavedSearchesState> emit,
  ) async {
    final result = await getSavedSearches();
    result.fold(
      (failure) => emit(state.copyWith(
        status: SavedSearchesStatus.failure,
        message: _messageForFailure(failure),
      )),
      (searches) => emit(state.copyWith(
        status: SavedSearchesStatus.loaded,
        searches: searches,
        removingIds: const {},
        isSaving: false,
        message: 'Saved searches refreshed',
      )),
    );
  }

  Future<void> _onSave(
    SavedSearchesSaveRequested event,
    Emitter<SavedSearchesState> emit,
  ) async {
    final current = state;
    emit(current.copyWith(isSaving: true, message: null));

    final draft = SavedSearchAlert(
      id: '',
      query: event.query,
      filter: event.filter,
      notifyByPush: event.notifyByPush,
      notifyInApp: event.notifyInApp,
      priceDropAlert: event.priceDropAlert,
      savedAt: DateTime.now(),
    );

    final result = await saveSavedSearch(draft);
    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        message: _messageForFailure(failure),
      )),
      (search) {
        final updatedSearches = _upsertSearch(state.searches, search);
        emit(state.copyWith(
          status: SavedSearchesStatus.loaded,
          searches: updatedSearches,
          isSaving: false,
          message: 'Saved search alert added',
        ));
      },
    );
  }

  Future<void> _onRemove(
    SavedSearchesRemoveRequested event,
    Emitter<SavedSearchesState> emit,
  ) async {
    if (state.removingIds.contains(event.id)) return;

    emit(state.copyWith(
      removingIds: {...state.removingIds, event.id},
      message: null,
    ));

    final result = await removeSavedSearch(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
        removingIds: state.removingIds.where((id) => id != event.id).toSet(),
        message: _messageForFailure(failure),
      )),
      (_) {
        final updated = state.searches.where((search) => search.id != event.id).toList();
        emit(state.copyWith(
          status: SavedSearchesStatus.loaded,
          searches: updated,
          removingIds: state.removingIds.where((id) => id != event.id).toSet(),
          message: 'Saved search removed',
        ));
      },
    );
  }

  void _onClearMessage(
    SavedSearchesClearMessageRequested event,
    Emitter<SavedSearchesState> emit,
  ) {
    emit(state.copyWith(message: null));
  }

  List<SavedSearchAlert> _upsertSearch(List<SavedSearchAlert> searches, SavedSearchAlert updated) {
    final filtered = searches.where((search) => search.id != updated.id).toList();
    filtered.insert(0, updated);
    return filtered;
  }

  String _messageForFailure(Failure failure) {
    if (failure is CacheFailure) return 'Unable to update saved searches right now';
    return 'Something went wrong. Please try again.';
  }
}
