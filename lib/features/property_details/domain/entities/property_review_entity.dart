import 'package:equatable/equatable.dart';

class PropertyReviewEntity extends Equatable {
  final String reviewerName;
  final double rating;
  final String dateLabel;
  final String comment;

  const PropertyReviewEntity({
    required this.reviewerName,
    required this.rating,
    required this.dateLabel,
    required this.comment,
  });

  @override
  List<Object?> get props => [reviewerName, rating, dateLabel, comment];
}
