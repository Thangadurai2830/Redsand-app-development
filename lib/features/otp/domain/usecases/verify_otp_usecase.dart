import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/auth_token.dart';
import '../entities/otp_verification.dart';
import '../repositories/otp_repository.dart';

class VerifyOtpUsecase implements UseCase<AuthToken, OtpVerification> {
  final OtpRepository repository;

  VerifyOtpUsecase(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(OtpVerification params) {
    return repository.verifyOtp(params);
  }
}
