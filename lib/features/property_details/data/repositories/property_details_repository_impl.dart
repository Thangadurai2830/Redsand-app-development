import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../../domain/entities/property_details_entity.dart';
import '../../domain/repositories/property_details_repository.dart';
import '../datasources/property_details_local_data_source.dart';
import '../datasources/property_details_remote_data_source.dart';

class PropertyDetailsRepositoryImpl implements PropertyDetailsRepository {
  final PropertyDetailsLocalDataSource localDataSource;
  final PropertyDetailsRemoteDataSource remoteDataSource;

  PropertyDetailsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, PropertyDetailsEntity>> getPropertyDetails(ListingEntity listing) async {
    try {
      return Right(localDataSource.getPropertyDetails(listing));
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveListing(String listingId) async {
    try {
      await remoteDataSource.saveListing(listingId);
    } catch (_) {
      // Best-effort: keep the demo usable even when the placeholder backend is unavailable.
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> revealContact(String listingId) async {
    try {
      await remoteDataSource.revealContact(listingId);
    } catch (_) {
      // Best-effort: unlock locally even if the contact logging endpoint is not reachable yet.
    }
    return const Right(null);
  }
}
