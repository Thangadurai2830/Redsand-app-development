import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_token.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken?>> getStoredToken();
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> clearToken();
  Future<Either<Failure, AuthToken>> login(String username, String password, {String? role});
  Future<Either<Failure, bool>> sendOtp(String email);
  Future<Either<Failure, AuthToken>> loginWithGoogle(String idToken);
}
