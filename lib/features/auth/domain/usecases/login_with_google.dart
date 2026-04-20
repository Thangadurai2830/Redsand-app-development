import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle implements UseCase<AuthToken, String> {
  final AuthRepository repository;
  LoginWithGoogle(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(String idToken) =>
      repository.loginWithGoogle(idToken);
}
