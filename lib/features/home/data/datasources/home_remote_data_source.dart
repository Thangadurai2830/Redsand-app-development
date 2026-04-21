import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/search_params.dart';
import '../models/home_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<ListingModel>> getFeaturedListings(String listingFor);
  Future<List<ListingModel>> getRecommendedListings(String listingFor);
  Future<List<ListingModel>> searchListings(SearchParams params);
  Future<List<SearchSuggestionModel>> getSearchSuggestions(String query);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;
  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ListingModel>> getFeaturedListings(String listingFor) async {
    try {
      final response = await dio.get(
        '/api/listings/featured',
        queryParameters: {'listing_for': listingFor},
      );
      final List data = response.data as List;
      return data.map((e) => ListingModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException {
      throw NetworkFailure();
    }
  }

  @override
  Future<List<ListingModel>> getRecommendedListings(String listingFor) async {
    try {
      final response = await dio.get(
        '/api/listings/recommended',
        queryParameters: {'listing_for': listingFor},
      );
      final List data = response.data as List;
      return data.map((e) => ListingModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      throw NetworkFailure();
    }
  }

  @override
  Future<List<ListingModel>> searchListings(SearchParams params) async {
    try {
      final response = await dio.get(
        '/api/search',
        queryParameters: _buildQueryParams(params),
      );
      final List data = response.data as List;
      return data.map((e) => ListingModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      throw NetworkFailure();
    }
  }

  @override
  Future<List<SearchSuggestionModel>> getSearchSuggestions(String query) async {
    try {
      final response = await dio.get(
        '/api/search/suggestions',
        queryParameters: {'q': query},
      );
      final List data = response.data as List;
      return data.map((e) => SearchSuggestionModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      throw NetworkFailure();
    }
  }

  Map<String, dynamic> _buildQueryParams(SearchParams params) {
    final filter = params.filter;
    return {
      'q': params.query,
      ...filter.toQueryParameters(),
    };
  }
}
