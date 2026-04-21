import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/saved_search_alert.dart';
import '../repositories/saved_searches_repository.dart';

class GetSavedSearches {
  final SavedSearchesRepository repository;

  GetSavedSearches(this.repository);

  Future<Either<Failure, List<SavedSearchAlert>>> call() {
    return repository.getSavedSearches();
  }
}
