import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/register_user.dart';
import '../repositories/register_repository.dart';

class RegisterUserUsecase implements UseCase<String, RegisterUser> {
  final RegisterRepository repository;

  RegisterUserUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(RegisterUser params) {
    return repository.register(params);
  }
}
