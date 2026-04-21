import 'package:equatable/equatable.dart';

import '../../../property_details/domain/entities/property_review_entity.dart';

enum ReviewsStatus { initial, loading, loaded, failure }

class ReviewsState extends Equatable {
  final ReviewsStatus status;
  final List<PropertyReviewEntity> reviews;
  final bool isSubmitting;
  final String? message;

  const ReviewsState({
    required this.status,
    required this.reviews,
    required this.isSubmitting,
    required this.message,
  });

  const ReviewsState.initial()
      : status = ReviewsStatus.initial,
        reviews = const [],
        isSubmitting = false,
        message = null;

  bool get hasReviews => reviews.isNotEmpty;

  ReviewsState copyWith({
    ReviewsStatus? status,
    List<PropertyReviewEntity>? reviews,
    bool? isSubmitting,
    String? message,
    bool clearMessage = false,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, reviews, isSubmitting, message];
}
