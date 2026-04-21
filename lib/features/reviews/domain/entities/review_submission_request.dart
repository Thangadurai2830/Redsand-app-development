import 'package:equatable/equatable.dart';

class ReviewSubmissionRequest extends Equatable {
  final String listingId;
  final int rating;
  final String reviewBody;

  const ReviewSubmissionRequest({
    required this.listingId,
    required this.rating,
    required this.reviewBody,
  });

  @override
  List<Object?> get props => [listingId, rating, reviewBody];
}
