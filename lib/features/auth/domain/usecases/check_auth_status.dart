import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

class AuthStatus {
  final bool isAuthenticated;
  final UserRole? role;

  const AuthStatus({required this.isAuthenticated, this.role});
}

class CheckAuthStatus implements UseCase<AuthStatus, NoParams> {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  @override
  Future<Either<Failure, AuthStatus>> call(NoParams params) async {
    final result = await repository.getStoredToken();

    return result.fold(
      (failure) => Left(failure),
      (token) async {
        if (token == null) {
          return const Right(AuthStatus(isAuthenticated: false));
        }

        if (!token.isExpired) {
          return Right(AuthStatus(isAuthenticated: true, role: token.role));
        }

        // Access token expired — try refresh
        final refreshResult = await repository.refreshToken(token.refreshToken);
        return refreshResult.fold(
          (_) => const Right(AuthStatus(isAuthenticated: false)),
          (newToken) => Right(
            AuthStatus(isAuthenticated: true, role: newToken.role),
          ),
        );
      },
    );
  }
}
