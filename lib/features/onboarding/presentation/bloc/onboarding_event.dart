part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the onboarding screen is first shown.
class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

/// User tapped Next or swiped to a new page.
class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

/// User tapped "Skip" — jump straight to role selection.
class OnboardingSkipped extends OnboardingEvent {
  const OnboardingSkipped();
}

/// User tapped "Get Started" on the last slide.
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
