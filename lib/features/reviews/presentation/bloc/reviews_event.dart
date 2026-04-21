import 'package:equatable/equatable.dart';

import '../../domain/entities/review_submission_request.dart';

sealed class ReviewsEvent extends Equatable {
  const ReviewsEvent();

  @override
  List<Object?> get props => [];
}

class ReviewsRequested extends ReviewsEvent {
  final String listingId;

  const ReviewsRequested(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

class ReviewSubmitted extends ReviewsEvent {
  final ReviewSubmissionRequest request;

  const ReviewSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class ReviewsMessageCleared extends ReviewsEvent {
  const ReviewsMessageCleared();
}
