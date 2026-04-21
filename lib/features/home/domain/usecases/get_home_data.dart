import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing_entity.dart';
import '../entities/search_params.dart';
import '../entities/search_suggestion_entity.dart';
import '../repositories/home_repository.dart';

class GetFeaturedListings implements UseCase<List<ListingEntity>, ListingParams> {
  final HomeRepository repository;
  GetFeaturedListings(this.repository);

  @override
  Future<Either<Failure, List<ListingEntity>>> call(ListingParams params) {
    return repository.getFeaturedListings(params.listingFor);
  }
}

class GetRecommendedListings implements UseCase<List<ListingEntity>, ListingParams> {
  final HomeRepository repository;
  GetRecommendedListings(this.repository);

  @override
  Future<Either<Failure, List<ListingEntity>>> call(ListingParams params) {
    return repository.getRecommendedListings(params.listingFor);
  }
}

class SearchListings implements UseCase<List<ListingEntity>, SearchParams> {
  final HomeRepository repository;
  SearchListings(this.repository);

  @override
  Future<Either<Failure, List<ListingEntity>>> call(SearchParams params) {
    return repository.searchListings(params);
  }
}

class GetSearchSuggestions implements UseCase<List<SearchSuggestionEntity>, SuggestionParams> {
  final HomeRepository repository;
  GetSearchSuggestions(this.repository);

  @override
  Future<Either<Failure, List<SearchSuggestionEntity>>> call(SuggestionParams params) {
    return repository.getSearchSuggestions(params.query);
  }
}

class ListingParams extends Equatable {
  final String listingFor;
  const ListingParams({required this.listingFor});

  @override
  List<Object?> get props => [listingFor];
}


class SuggestionParams extends Equatable {
  final String query;
  const SuggestionParams({required this.query});

  @override
  List<Object?> get props => [query];
}
