import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../property_details/domain/entities/property_review_entity.dart';
import '../../domain/entities/review_submission_request.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_remote_data_source.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remoteDataSource;

  ReviewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PropertyReviewEntity>>> getPropertyReviews(String listingId) async {
    try {
      final reviews = await remoteDataSource.getPropertyReviews(listingId);
      return Right(reviews);
    } catch (_) {
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, String>> submitReview(ReviewSubmissionRequest request) async {
    try {
      final message = await remoteDataSource.submitReview(request);
      return Right(message);
    } catch (_) {
      return Left(NetworkFailure());
    }
  }
}
