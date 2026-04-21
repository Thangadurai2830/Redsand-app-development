import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/saved_search_alert.dart';

abstract class SavedSearchesRepository {
  Future<Either<Failure, List<SavedSearchAlert>>> getSavedSearches();
  Future<Either<Failure, SavedSearchAlert>> saveSavedSearch(SavedSearchAlert search);
  Future<Either<Failure, void>> removeSavedSearch(String id);
}
