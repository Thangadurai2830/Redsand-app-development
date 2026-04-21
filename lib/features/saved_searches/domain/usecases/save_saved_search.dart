import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/saved_search_alert.dart';
import '../repositories/saved_searches_repository.dart';

class SaveSavedSearch {
  final SavedSearchesRepository repository;

  SaveSavedSearch(this.repository);

  Future<Either<Failure, SavedSearchAlert>> call(SavedSearchAlert search) {
    return repository.saveSavedSearch(search);
  }
}
