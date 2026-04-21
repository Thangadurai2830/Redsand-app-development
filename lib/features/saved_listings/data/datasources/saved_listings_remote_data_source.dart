import 'package:dio/dio.dart';

import '../../domain/entities/saved_listing_entity.dart';
import '../models/saved_listing_model.dart';

abstract class SavedListingsRemoteDataSource {
  Future<List<SavedListingEntity>> getSavedListings();
  Future<void> removeSavedListing(String listingId);
}

class SavedListingsRemoteDataSourceImpl implements SavedListingsRemoteDataSource {
  final Dio dio;

  SavedListingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SavedListingEntity>> getSavedListings() async {
    final response = await dio.get('/api/user/saved-listings');
    final data = _extractCollection(response.data);
    return data.map((item) => SavedListingModel.fromJson(item)).toList();
  }

  @override
  Future<void> removeSavedListing(String listingId) async {
    await dio.delete(
      '/api/user/saved-listings',
      data: {'listing_id': listingId},
    );
  }

  List<Map<String, dynamic>> _extractCollection(Object? payload) {
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final candidate = payload['data'] ?? payload['saved_listings'] ?? payload['items'];
      if (candidate is List) {
        return candidate.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}
