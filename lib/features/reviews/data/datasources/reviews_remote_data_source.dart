import 'package:dio/dio.dart';

import '../../domain/entities/review_submission_request.dart';
import '../../../property_details/domain/entities/property_review_entity.dart';
import '../models/property_review_model.dart';
import '../models/review_submission_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<PropertyReviewEntity>> getPropertyReviews(String listingId);
  Future<String> submitReview(ReviewSubmissionRequest request);
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final Dio dio;

  ReviewsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PropertyReviewEntity>> getPropertyReviews(String listingId) async {
    final response = await dio.get('/api/listings/$listingId/reviews');
    final payload = _extractReviewItems(response.data);
    if (payload.isEmpty) return const [];

    return payload
        .whereType<Map<String, dynamic>>()
        .map(PropertyReviewModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<String> submitReview(ReviewSubmissionRequest request) async {
    final response = await dio.post(
      '/api/user/reviews',
      data: ReviewSubmissionModel.fromEntity(request).toJson(),
    );

    final message = _extractMessage(response.data);
    return message ?? 'Review submitted successfully';
  }

  List<Map<String, dynamic>> _extractReviewItems(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    if (data is Map<String, dynamic>) {
      for (final key in const ['reviews', 'data', 'items', 'results']) {
        final value = data[key];
        if (value is List) {
          return value.whereType<Map<String, dynamic>>().toList(growable: false);
        }
        if (value is Map<String, dynamic>) {
          final nested = _extractReviewItems(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }

    return const [];
  }

  String? _extractMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map<String, dynamic>) {
      for (final key in const ['message', 'detail', 'status']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return _extractMessage(nested);
      }
    }

    return null;
  }
}
