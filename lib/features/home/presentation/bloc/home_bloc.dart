import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_home_data.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetFeaturedListings getFeaturedListings;
  final GetRecommendedListings getRecommendedListings;
  final SearchListings searchListings;
  final GetSearchSuggestions getSearchSuggestions;

  HomeBloc({
    required this.getFeaturedListings,
    required this.getRecommendedListings,
    required this.searchListings,
    required this.getSearchSuggestions,
  }) : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<ToggleListingFor>(_onToggleListingFor);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SubmitSearch>(_onSubmitSearch);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    final featuredResult = await getFeaturedListings(ListingParams(listingFor: event.listingFor));
    final recommendedResult = await getRecommendedListings(ListingParams(listingFor: event.listingFor));

    featuredResult.fold(
      (failure) => emit(const HomeError('Failed to load listings')),
      (featured) {
        recommendedResult.fold(
          (failure) => emit(const HomeError('Failed to load listings')),
          (recommended) => emit(HomeLoaded(
            featuredListings: featured,
            recommendedListings: recommended,
            listingFor: event.listingFor,
          )),
        );
      },
    );
  }

  Future<void> _onToggleListingFor(ToggleListingFor event, Emitter<HomeState> emit) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(const HomeLoading());
      final featuredResult = await getFeaturedListings(ListingParams(listingFor: event.listingFor));
      final recommendedResult = await getRecommendedListings(ListingParams(listingFor: event.listingFor));

      featuredResult.fold(
        (failure) => emit(const HomeError('Failed to load listings')),
        (featured) {
          recommendedResult.fold(
            (failure) => emit(const HomeError('Failed to load listings')),
            (recommended) => emit(HomeLoaded(
              featuredListings: featured,
              recommendedListings: recommended,
              listingFor: event.listingFor,
            )),
          );
        },
      );
    }
  }

  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<HomeState> emit) async {
    if (event.query.isEmpty) {
      add(const ClearSearch());
      return;
    }
    final result = await getSearchSuggestions(SuggestionParams(query: event.query));
    result.fold(
      (_) {},
      (suggestions) => emit(HomeSearchSuggestionsLoaded(suggestions)),
    );
  }

  Future<void> _onSubmitSearch(SubmitSearch event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    final listingFor = (state is HomeLoaded) ? (state as HomeLoaded).listingFor : 'rent';
    final result = await searchListings(SearchParams(query: event.query, listingFor: listingFor));
    result.fold(
      (failure) => emit(const HomeError('Search failed')),
      (results) => emit(HomeSearchResultsLoaded(results: results, query: event.query)),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<HomeState> emit) {
    add(const LoadHomeData());
  }
}
