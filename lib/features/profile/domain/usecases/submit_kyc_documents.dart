import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kyc_submission_request.dart';
import '../repositories/profile_repository.dart';

class SubmitKycDocuments implements UseCase<String, KycSubmissionRequest> {
  final ProfileRepository repository;

  SubmitKycDocuments(this.repository);

  @override
  Future<Either<Failure, String>> call(KycSubmissionRequest params) {
    return repository.submitKycDocuments(params);
  }
}
