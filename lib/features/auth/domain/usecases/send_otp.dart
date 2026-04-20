import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendOtp implements UseCase<bool, String> {
  final AuthRepository repository;
  SendOtp(this.repository);

  @override
  Future<Either<Failure, bool>> call(String email) =>
      repository.sendOtp(email);
}
