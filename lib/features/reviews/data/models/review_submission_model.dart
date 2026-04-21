import '../../domain/entities/review_submission_request.dart';

class ReviewSubmissionModel {
  final String listingId;
  final int rating;
  final String reviewBody;

  const ReviewSubmissionModel({
    required this.listingId,
    required this.rating,
    required this.reviewBody,
  });

  factory ReviewSubmissionModel.fromEntity(ReviewSubmissionRequest request) {
    return ReviewSubmissionModel(
      listingId: request.listingId,
      rating: request.rating,
      reviewBody: request.reviewBody,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listing_id': listingId,
      'rating': rating,
      'review': reviewBody,
      'review_body': reviewBody,
      'comment': reviewBody,
    };
  }
}
