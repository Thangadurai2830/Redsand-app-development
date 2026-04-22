import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/owner_analytics_entity.dart';
import '../../domain/entities/owner_buyer_interest_entity.dart';
import '../../domain/entities/owner_listing_entity.dart';
import '../../domain/repositories/owner_dashboard_repository.dart';
import '../datasources/owner_dashboard_remote_data_source.dart';

class OwnerDashboardRepositoryImpl implements OwnerDashboardRepository {
  final OwnerDashboardRemoteDataSource remoteDataSource;

  OwnerDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OwnerListingEntity>>> getListings() async {
    try {
      return Right(await remoteDataSource.getListings());
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<OwnerBuyerInterestEntity>>> getInterests() async {
    try {
      return Right(await remoteDataSource.getInterests());
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, OwnerAnalyticsEntity>> getAnalytics() async {
    try {
      return Right(await remoteDataSource.getAnalytics());
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> boostListing(String listingId) async {
    try {
      await remoteDataSource.boostListing(listingId);
      return const Right<Failure, void>(null);
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }
}
