import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/search_suggestion_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ListingEntity> featuredListings;
  final List<ListingEntity> recommendedListings;
  final String listingFor;

  const HomeLoaded({
    required this.featuredListings,
    required this.recommendedListings,
    required this.listingFor,
  });

  HomeLoaded copyWith({
    List<ListingEntity>? featuredListings,
    List<ListingEntity>? recommendedListings,
    String? listingFor,
  }) {
    return HomeLoaded(
      featuredListings: featuredListings ?? this.featuredListings,
      recommendedListings: recommendedListings ?? this.recommendedListings,
      listingFor: listingFor ?? this.listingFor,
    );
  }

  @override
  List<Object?> get props => [featuredListings, recommendedListings, listingFor];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeSearchSuggestionsLoaded extends HomeState {
  final List<SearchSuggestionEntity> suggestions;
  const HomeSearchSuggestionsLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

class HomeSearchResultsLoaded extends HomeState {
  final List<ListingEntity> results;
  final String query;
  const HomeSearchResultsLoaded({required this.results, required this.query});

  @override
  List<Object?> get props => [results, query];
}
