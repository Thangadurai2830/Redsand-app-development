import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review_submission_request.dart';
import '../repositories/reviews_repository.dart';

class SubmitReview implements UseCase<String, ReviewSubmissionRequest> {
  final ReviewsRepository repository;

  SubmitReview(this.repository);

  @override
  Future<Either<Failure, String>> call(ReviewSubmissionRequest params) {
    return repository.submitReview(params);
  }
}
