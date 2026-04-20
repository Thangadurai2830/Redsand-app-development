import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/auth_token.dart';
import '../entities/otp_verification.dart';

abstract class OtpRepository {
  Future<Either<Failure, AuthToken>> verifyOtp(OtpVerification verification);
  Future<Either<Failure, bool>> resendOtp(String email);
}
