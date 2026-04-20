part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingLoaded extends OnboardingState {
  final List<OnboardingSlide> slides;
  final int currentPage;

  const OnboardingLoaded({
    required this.slides,
    this.currentPage = 0,
  });

  bool get isLastPage => currentPage == slides.length - 1;

  OnboardingLoaded copyWith({int? currentPage}) => OnboardingLoaded(
        slides: slides,
        currentPage: currentPage ?? this.currentPage,
      );

  @override
  List<Object?> get props => [slides, currentPage];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when the user skips or completes onboarding — triggers navigation.
class OnboardingFinished extends OnboardingState {
  const OnboardingFinished();
}
