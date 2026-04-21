import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../entities/property_details_entity.dart';
import '../repositories/property_details_repository.dart';

class GetPropertyDetails implements UseCase<PropertyDetailsEntity, ListingEntity> {
  final PropertyDetailsRepository repository;

  GetPropertyDetails(this.repository);

  @override
  Future<Either<Failure, PropertyDetailsEntity>> call(ListingEntity params) {
    return repository.getPropertyDetails(params);
  }
}
