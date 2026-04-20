import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../entities/search_suggestion_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<ListingEntity>>> getFeaturedListings(String listingFor);
  Future<Either<Failure, List<ListingEntity>>> getRecommendedListings(String listingFor);
  Future<Either<Failure, List<ListingEntity>>> searchListings(String query, String listingFor);
  Future<Either<Failure, List<SearchSuggestionEntity>>> getSearchSuggestions(String query);
}
