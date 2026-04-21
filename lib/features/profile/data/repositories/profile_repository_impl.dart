import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/kyc_submission_request.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/entities/site_visit_record.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      return Right(await remoteDataSource.fetchProfile());
    } on DioException {
      try {
        return Right(await localDataSource.fetchProfile());
      } catch (_) {
        return Left(CacheFailure());
      }
    } catch (_) {
      try {
        return Right(await localDataSource.fetchProfile());
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(ProfileUpdateRequest request) async {
    try {
      return Right(await remoteDataSource.updateProfile(request));
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> submitKycDocuments(KycSubmissionRequest request) async {
    try {
      return Right(await remoteDataSource.submitKycDocuments(request));
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<SiteVisitRecord>>> getSiteVisits() async {
    try {
      return Right(await remoteDataSource.fetchSiteVisits());
    } on DioException {
      try {
        return Right(await localDataSource.fetchSiteVisits());
      } catch (_) {
        return Left(CacheFailure());
      }
    } catch (_) {
      try {
        return Right(await localDataSource.fetchSiteVisits());
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }
}
