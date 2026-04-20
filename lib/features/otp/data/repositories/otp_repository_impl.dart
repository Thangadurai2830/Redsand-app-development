import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/domain/entities/auth_token.dart';
import '../../domain/entities/otp_verification.dart';
import '../../domain/repositories/otp_repository.dart';
import '../datasources/otp_remote_data_source.dart';

class OtpRepositoryImpl implements OtpRepository {
  final OtpRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  OtpRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthToken>> verifyOtp(OtpVerification verification) async {
    try {
      final tokenModel = await remoteDataSource.verifyOtp(
        email: verification.email,
        otp: verification.otp,
      );
      await localDataSource.saveToken(tokenModel);
      return Right(tokenModel);
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> resendOtp(String email) async {
    try {
      final result = await remoteDataSource.resendOtp(email);
      return Right(result);
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }
}
