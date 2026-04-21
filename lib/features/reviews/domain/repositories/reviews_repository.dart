import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../property_details/domain/entities/property_review_entity.dart';
import '../entities/review_submission_request.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, List<PropertyReviewEntity>>> getPropertyReviews(String listingId);
  Future<Either<Failure, String>> submitReview(ReviewSubmissionRequest request);
}
