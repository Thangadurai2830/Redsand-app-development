import '../../../property_details/domain/entities/property_review_entity.dart';

class PropertyReviewModel extends PropertyReviewEntity {
  const PropertyReviewModel({
    required super.reviewerName,
    required super.rating,
    required super.dateLabel,
    required super.comment,
  });

  factory PropertyReviewModel.fromJson(Map<String, dynamic> json) {
    return PropertyReviewModel(
      reviewerName: _readString(json, const ['reviewer_name', 'reviewerName', 'name', 'user_name'], 'Guest User'),
      rating: _readRating(json),
      dateLabel: _readString(json, const ['date_label', 'dateLabel', 'created_at', 'createdAt'], 'Recently'),
      comment: _readString(json, const ['comment', 'review', 'body', 'text', 'message'], ''),
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }

  static double _readRating(Map<String, dynamic> json) {
    final rating = json['rating'] ?? json['stars'] ?? json['score'];
    if (rating is num) {
      return rating.toDouble();
    }
    if (rating is String) {
      return double.tryParse(rating) ?? 0;
    }
    return 0;
  }
}
