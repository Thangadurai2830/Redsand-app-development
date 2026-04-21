import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_property_reviews.dart';
import '../../domain/usecases/submit_review.dart';
import 'reviews_event.dart';
import 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final GetPropertyReviews getPropertyReviews;
  final SubmitReview submitReview;

  ReviewsBloc({
    required this.getPropertyReviews,
    required this.submitReview,
  }) : super(const ReviewsState.initial()) {
    on<ReviewsRequested>(_onRequested);
    on<ReviewSubmitted>(_onSubmitted);
    on<ReviewsMessageCleared>(_onMessageCleared);
  }

  Future<void> _onRequested(
    ReviewsRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(state.copyWith(status: ReviewsStatus.loading, clearMessage: true));
    final result = await getPropertyReviews(event.listingId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ReviewsStatus.failure,
        message: _messageForFailure(failure),
      )),
      (reviews) => emit(state.copyWith(
        status: ReviewsStatus.loaded,
        reviews: reviews,
      )),
    );
  }

  Future<void> _onSubmitted(
    ReviewSubmitted event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearMessage: true));
    final result = await submitReview(event.request);
    await result.fold(
      (failure) async => emit(state.copyWith(
        isSubmitting: false,
        status: ReviewsStatus.failure,
        message: _messageForFailure(failure),
      )),
      (message) async {
        final refreshed = await getPropertyReviews(event.request.listingId);
        refreshed.fold(
          (failure) => emit(state.copyWith(
            isSubmitting: false,
            status: ReviewsStatus.loaded,
            message: message,
          )),
          (reviews) => emit(state.copyWith(
            isSubmitting: false,
            status: ReviewsStatus.loaded,
            reviews: reviews,
            message: message,
          )),
        );
      },
    );
  }

  void _onMessageCleared(
    ReviewsMessageCleared event,
    Emitter<ReviewsState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }

  String _messageForFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Unable to reach reviews service. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
