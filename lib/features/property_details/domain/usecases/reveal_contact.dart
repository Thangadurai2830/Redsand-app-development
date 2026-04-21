import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/property_details_repository.dart';

class RevealContact implements UseCase<void, String> {
  final PropertyDetailsRepository repository;

  RevealContact(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.revealContact(params);
  }
}
