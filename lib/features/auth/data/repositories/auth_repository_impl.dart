import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, AuthToken?>> getStoredToken() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token);
    } on CacheFailure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    return Left(NetworkFailure());
  }

  @override
  Future<Either<Failure, void>> clearToken() async {
    try {
      await localDataSource.deleteToken();
      return const Right(null);
    } on CacheFailure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, AuthToken>> login(String email, String password) async {
    try {
      final token = await remoteDataSource.login(email, password);
      await localDataSource.saveToken(token);
      return Right(token);
    } on NetworkFailure catch (f) {
      return Left(f);
    } on CacheFailure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, bool>> sendOtp(String email) async {
    try {
      final success = await remoteDataSource.sendOtp(email);
      return Right(success);
    } on NetworkFailure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, AuthToken>> loginWithGoogle(String idToken) async {
    try {
      final token = await remoteDataSource.loginWithGoogle(idToken);
      await localDataSource.saveToken(token);
      return Right(token);
    } on NetworkFailure catch (f) {
      return Left(f);
    } on CacheFailure catch (f) {
      return Left(f);
    }
  }
}
