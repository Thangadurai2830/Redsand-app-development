import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/search_params.dart';
import '../../domain/entities/search_suggestion_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ListingEntity>>> getFeaturedListings(String listingFor) async {
    try {
      final results = await remoteDataSource.getFeaturedListings(listingFor);
      return Right(results);
    } on NetworkFailure {
      try {
        final results = await localDataSource.getFeaturedListings(listingFor);
        return Right(results);
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getRecommendedListings(String listingFor) async {
    try {
      final results = await remoteDataSource.getRecommendedListings(listingFor);
      return Right(results);
    } on NetworkFailure {
      try {
        final results = await localDataSource.getRecommendedListings(listingFor);
        return Right(results);
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> searchListings(SearchParams params) async {
    try {
      final results = await remoteDataSource.searchListings(params);
      return Right(results);
    } on NetworkFailure {
      try {
        final results = await localDataSource.searchListings(
          params.query,
          params.listingFor,
        );
        return Right(results);
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<SearchSuggestionEntity>>> getSearchSuggestions(String query) async {
    try {
      final results = await remoteDataSource.getSearchSuggestions(query);
      return Right(results);
    } on NetworkFailure {
      try {
        final results = await localDataSource.getSearchSuggestions(query);
        return Right(results);
      } catch (_) {
        return const Right([]);
      }
    }
  }
}
