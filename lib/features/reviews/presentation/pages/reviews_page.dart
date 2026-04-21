import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../../../property_details/domain/entities/property_review_entity.dart';
import '../../domain/entities/review_submission_request.dart';
import '../bloc/reviews_bloc.dart';
import '../bloc/reviews_event.dart';
import '../bloc/reviews_state.dart';

class ReviewsPage extends StatelessWidget {
  final ListingEntity listing;

  const ReviewsPage({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ReviewsBloc>()..add(ReviewsRequested(listing.id)),
      child: _ReviewsView(listing: listing),
    );
  }
}

class _ReviewsView extends StatefulWidget {
  final ListingEntity listing;

  const _ReviewsView({required this.listing});

  @override
  State<_ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<_ReviewsView> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _rating = 0;
  bool _submittedThisRound = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a rating from 1 to 5')),
      );
      return;
    }

    _submittedThisRound = true;
    context.read<ReviewsBloc>().add(
          ReviewSubmitted(
            ReviewSubmissionRequest(
              listingId: widget.listing.id,
              rating: _rating,
              reviewBody: _reviewController.text.trim(),
            ),
          ),
        );
  }

  void _resetForm() {
    setState(() {
      _rating = 0;
      _reviewController.clear();
      _submittedThisRound = false;
    });
  }

  double _averageRating(List<PropertyReviewEntity> reviews) {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(0, (total, review) => total + review.rating);
    return sum / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsBloc, ReviewsState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.status == ReviewsStatus.failure ? Colors.red : Colors.green,
            ),
          );
          context.read<ReviewsBloc>().add(const ReviewsMessageCleared());

          if (_submittedThisRound && state.status == ReviewsStatus.loaded && !state.isSubmitting) {
            _resetForm();
          } else {
            _submittedThisRound = false;
          }
        }
      },
      builder: (context, state) {
        final isInitialLoading = state.status == ReviewsStatus.loading && !state.hasReviews;
        final averageRating = _averageRating(state.reviews);

        return Scaffold(
          backgroundColor: AppColors.lightGrayBg,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            foregroundColor: AppColors.primaryDarkText,
            title: const Text(
              'Reviews',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: state.isSubmitting
                    ? null
                    : () => context.read<ReviewsBloc>().add(ReviewsRequested(widget.listing.id)),
              ),
            ],
          ),
          body: AbsorbPointer(
            absorbing: state.isSubmitting,
            child: RefreshIndicator(
              onRefresh: () {
                context.read<ReviewsBloc>().add(ReviewsRequested(widget.listing.id));
                return Future.value();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ListingHeaderCard(
                    listing: widget.listing,
                    averageRating: averageRating,
                    reviewCount: state.reviews.length,
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Write a Review',
                    subtitle: 'Rate the owner and property after your visit or deal.',
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RatingSelector(
                            rating: _rating,
                            onChanged: (value) => setState(() => _rating = value),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _reviewController,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              labelText: 'Review body',
                              hintText: 'Share what stood out, what could be better, and whether you would recommend it.',
                              alignLabelWithHint: true,
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 84),
                                child: Icon(Icons.rate_review_outlined),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Review body is required';
                              }
                              if (value.trim().length < 20) {
                                return 'Please write a slightly longer review';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: state.isSubmitting ? null : _submit,
                              icon: state.isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(state.isSubmitting ? 'Submitting' : 'Submit Review'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mainPurple,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Property Reviews',
                    subtitle: 'Recent feedback from visitors and tenants.',
                    trailing: state.status == ReviewsStatus.loading && state.hasReviews
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    child: isInitialLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.mainPurple),
                            ),
                          )
                        : state.status == ReviewsStatus.failure && !state.hasReviews
                            ? _ErrorState(
                                message: state.message ?? 'We could not load the reviews right now.',
                                onRetry: () => context.read<ReviewsBloc>().add(ReviewsRequested(widget.listing.id)),
                              )
                            : state.hasReviews
                                ? Column(
                                    children: [
                                      for (final review in state.reviews) ...[
                                        _ReviewTile(review: review),
                                        if (review != state.reviews.last) const SizedBox(height: 12),
                                      ],
                                    ],
                                  )
                                : const _EmptyState(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ListingHeaderCard extends StatelessWidget {
  final ListingEntity listing;
  final double averageRating;
  final int reviewCount;

  const _ListingHeaderCard({
    required this.listing,
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepRoyalPurple,
            AppColors.mainPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainPurple.withOpacity(0.24),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${listing.locality}, ${listing.city}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      averageRating == 0 ? 'No rating yet' : averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$reviewCount review${reviewCount == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDarkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.secondaryGrayText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _RatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const _RatingSelector({
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkText,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (index) {
            final value = index + 1;
            final selected = value <= rating;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkResponse(
                onTap: () => onChanged(value),
                radius: 24,
                child: Icon(
                  selected ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 32,
                  color: selected ? Colors.amber : AppColors.secondaryGrayText,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          rating == 0 ? 'Tap a star to rate' : '$rating out of 5',
          style: const TextStyle(
            color: AppColors.secondaryGrayText,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final PropertyReviewEntity review;

  const _ReviewTile({required this.review});

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final reviewText = review.comment.toString().trim().isEmpty
        ? 'No review body provided.'
        : review.comment.toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.veryLightPurpleBg,
                child: Text(
                  _initial(review.reviewerName.toString()),
                  style: const TextStyle(
                    color: AppColors.mainPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.dateLabel.toString(),
                      style: const TextStyle(
                        color: AppColors.secondaryGrayText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(review.rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reviewText,
            style: const TextStyle(
              color: AppColors.primaryDarkText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 36, color: AppColors.secondaryGrayText),
          SizedBox(height: 10),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDarkText,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Be the first to share your experience with this property.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryGrayText),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.secondaryGrayText),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primaryDarkText),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
