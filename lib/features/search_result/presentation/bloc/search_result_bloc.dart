import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/search_params.dart';
import '../../../home/domain/usecases/get_home_data.dart';
import 'search_result_event.dart';
import 'search_result_state.dart';

class SearchResultBloc extends Bloc<SearchResultEvent, SearchResultState> {
  final SearchListings searchListings;

  SearchResultBloc({required this.searchListings})
      : super(const SearchResultInitial()) {
    on<SearchResultLoad>(_onLoad);
    on<SearchResultFilterChanged>(_onFilterChanged);
    on<SearchResultSortChanged>(_onSortChanged);
    on<SearchResultToggleSaved>(_onToggleSaved);
  }

  Future<void> _onLoad(SearchResultLoad event, Emitter<SearchResultState> emit) async {
    emit(const SearchResultLoading());
    final result = await searchListings(
      SearchParams(
        query: event.query,
        listingFor: event.filter.listingFor,
        filter: event.filter,
      ),
    );
    result.fold(
      (_) => emit(const SearchResultError('Failed to load results')),
      (listings) => emit(SearchResultLoaded(
        listings: listings,
        query: event.query,
        filter: event.filter,
      )),
    );
  }

  void _onFilterChanged(SearchResultFilterChanged event, Emitter<SearchResultState> emit) {
    final current = state;
    if (current is SearchResultLoaded) {
      add(SearchResultLoad(query: current.query, filter: event.filter));
    }
  }

  void _onSortChanged(SearchResultSortChanged event, Emitter<SearchResultState> emit) {
    final current = state;
    if (current is SearchResultLoaded) {
      final updatedFilter = current.filter.copyWith(sortBy: event.sortBy);
      emit(current.copyWith(filter: updatedFilter));
    }
  }

  void _onToggleSaved(SearchResultToggleSaved event, Emitter<SearchResultState> emit) {
    final current = state;
    if (current is SearchResultLoaded) {
      final updated = Set<String>.from(current.savedIds);
      if (updated.contains(event.listingId)) {
        updated.remove(event.listingId);
      } else {
        updated.add(event.listingId);
      }
      emit(current.copyWith(savedIds: updated));
    }
  }
}
