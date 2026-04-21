import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/property_details_repository.dart';

class SaveListing implements UseCase<void, String> {
  final PropertyDetailsRepository repository;

  SaveListing(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.saveListing(params);
  }
}
