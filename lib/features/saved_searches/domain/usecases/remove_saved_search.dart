import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/saved_searches_repository.dart';

class RemoveSavedSearch {
  final SavedSearchesRepository repository;

  RemoveSavedSearch(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.removeSavedSearch(id);
  }
}
