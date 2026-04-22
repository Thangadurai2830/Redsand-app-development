import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_token.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String username;
  final String password;
  final UserRole? role;
  const LoginParams({required this.username, required this.password, this.role});
}

class Login implements UseCase<AuthToken, LoginParams> {
  final AuthRepository repository;
  Login(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(LoginParams params) =>
      repository.login(params.username, params.password, role: params.role?.name);
}
