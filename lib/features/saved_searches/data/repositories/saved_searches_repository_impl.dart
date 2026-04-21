import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/saved_search_alert.dart';
import '../../domain/repositories/saved_searches_repository.dart';
import '../datasources/saved_searches_local_data_source.dart';
import '../datasources/saved_searches_remote_data_source.dart';
import '../models/saved_search_alert_model.dart';

class SavedSearchesRepositoryImpl implements SavedSearchesRepository {
  final SavedSearchesRemoteDataSource remoteDataSource;
  final SavedSearchesLocalDataSource localDataSource;

  SavedSearchesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<SavedSearchAlert>>> getSavedSearches() async {
    try {
      final searches = await remoteDataSource.getSavedSearches();
      return Right(searches);
    } catch (_) {
      try {
        final searches = await localDataSource.getSavedSearches();
        return Right(searches);
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, SavedSearchAlert>> saveSavedSearch(SavedSearchAlert search) async {
    try {
      final saved = await remoteDataSource.saveSavedSearch(
        SavedSearchAlertModel(
          id: search.id,
          query: search.query,
          filter: search.filter,
          notifyByPush: search.notifyByPush,
          notifyInApp: search.notifyInApp,
          priceDropAlert: search.priceDropAlert,
          savedAt: search.savedAt,
          newMatchCount: search.newMatchCount,
          lastMatchedAt: search.lastMatchedAt,
        ),
      );
      try {
        await localDataSource.saveSavedSearch(saved);
      } catch (_) {
        // Local persistence is best effort so the main API flow still wins.
      }
      return Right(saved);
    } catch (_) {
      try {
        final saved = await localDataSource.saveSavedSearch(
          SavedSearchAlertModel(
            id: search.id,
            query: search.query,
            filter: search.filter,
            notifyByPush: search.notifyByPush,
            notifyInApp: search.notifyInApp,
            priceDropAlert: search.priceDropAlert,
            savedAt: search.savedAt,
            newMatchCount: search.newMatchCount,
            lastMatchedAt: search.lastMatchedAt,
          ),
        );
        return Right(saved);
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, void>> removeSavedSearch(String id) async {
    try {
      await remoteDataSource.removeSavedSearch(id);
    } catch (_) {
      // Best-effort remote sync.
    }

    try {
      await localDataSource.removeSavedSearch(id);
    } catch (_) {
      return Left(CacheFailure());
    }

    return const Right(null);
  }
}
