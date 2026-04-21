import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/saved_listing_entity.dart';
import '../../domain/repositories/saved_listings_repository.dart';
import '../datasources/saved_listings_local_data_source.dart';
import '../datasources/saved_listings_remote_data_source.dart';

class SavedListingsRepositoryImpl implements SavedListingsRepository {
  final SavedListingsRemoteDataSource remoteDataSource;
  final SavedListingsLocalDataSource localDataSource;

  SavedListingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<SavedListingEntity>>> getSavedListings() async {
    try {
      final listings = await remoteDataSource.getSavedListings();
      return Right(listings);
    } catch (_) {
      try {
        final listings = await localDataSource.getSavedListings();
        return Right(listings);
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, void>> removeSavedListing(String listingId) async {
    try {
      await remoteDataSource.removeSavedListing(listingId);
    } catch (_) {
      // Best-effort: keep the demo flow usable if the backend placeholder is unavailable.
    }

    try {
      await localDataSource.removeSavedListing(listingId);
    } catch (_) {
      return Left(CacheFailure());
    }

    return const Right(null);
  }
}
