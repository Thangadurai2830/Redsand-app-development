import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/otp_repository.dart';

class ResendOtpUsecase implements UseCase<bool, String> {
  final OtpRepository repository;

  ResendOtpUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String email) {
    return repository.resendOtp(email);
  }
}
