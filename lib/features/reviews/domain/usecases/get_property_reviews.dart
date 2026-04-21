import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../property_details/domain/entities/property_review_entity.dart';
import '../repositories/reviews_repository.dart';

class GetPropertyReviews implements UseCase<List<PropertyReviewEntity>, String> {
  final ReviewsRepository repository;

  GetPropertyReviews(this.repository);

  @override
  Future<Either<Failure, List<PropertyReviewEntity>>> call(String params) {
    return repository.getPropertyReviews(params);
  }
}
