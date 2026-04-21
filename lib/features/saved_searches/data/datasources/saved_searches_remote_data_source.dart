import 'package:dio/dio.dart';

import '../models/saved_search_alert_model.dart';

abstract class SavedSearchesRemoteDataSource {
  Future<List<SavedSearchAlertModel>> getSavedSearches();
  Future<SavedSearchAlertModel> saveSavedSearch(SavedSearchAlertModel search);
  Future<void> removeSavedSearch(String id);
}

class SavedSearchesRemoteDataSourceImpl implements SavedSearchesRemoteDataSource {
  final Dio dio;

  SavedSearchesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SavedSearchAlertModel>> getSavedSearches() async {
    final response = await dio.get('/api/user/saved-searches');
    final data = _extractCollection(response.data);
    return data.map(SavedSearchAlertModel.fromJson).toList();
  }

  @override
  Future<SavedSearchAlertModel> saveSavedSearch(SavedSearchAlertModel search) async {
    final response = await dio.post(
      '/api/user/saved-searches',
      data: search.toRequestJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return SavedSearchAlertModel.fromJson(data);
    }
    return search;
  }

  @override
  Future<void> removeSavedSearch(String id) async {
    await dio.delete('/api/user/saved-searches/$id');
  }

  List<Map<String, dynamic>> _extractCollection(Object? payload) {
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final candidate = payload['data'] ?? payload['saved_searches'] ?? payload['items'];
      if (candidate is List) {
        return candidate.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}
