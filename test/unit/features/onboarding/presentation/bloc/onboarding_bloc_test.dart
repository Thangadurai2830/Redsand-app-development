import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/onboarding/data/models/onboarding_slide_model.dart';
import 'package:flutter_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';

import '../../../../../helpers/test_fakes.dart';

void main() {
  test('starting onboarding loads slides', () async {
    final slides = [
      const OnboardingSlideModel(
        id: '1',
        title: 'Welcome',
        description: 'Hello',
        illustration: 'rental',
      ),
      const OnboardingSlideModel(
        id: '2',
        title: 'Connect',
        description: 'Find people',
        illustration: 'connect',
      ),
    ];

    final bloc = OnboardingBloc(
      getOnboardingSlides: FakeGetOnboardingSlides(Right(slides)),
      markOnboardingComplete: FakeMarkOnboardingComplete(const Right(null)),
      checkOnboardingStatus: FakeCheckOnboardingStatus(const Right(false)),
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        const OnboardingLoading(),
        OnboardingLoaded(slides: slides),
      ]),
    );

    bloc.add(const OnboardingStarted());

    await expectation;
    await bloc.close();
  });

  test('page change updates the current page and completion emits finished', () async {
    final markComplete = FakeMarkOnboardingComplete(const Right(null));
    final bloc = OnboardingBloc(
      getOnboardingSlides: FakeGetOnboardingSlides(
        Right(OnboardingSlideModel.defaults),
      ),
      markOnboardingComplete: markComplete,
      checkOnboardingStatus: FakeCheckOnboardingStatus(const Right(false)),
    );

    final startExpectation = expectLater(
      bloc.stream,
      emitsInOrder([
        const OnboardingLoading(),
        OnboardingLoaded(slides: OnboardingSlideModel.defaults),
      ]),
    );
    bloc.add(const OnboardingStarted());
    await startExpectation;

    bloc.add(const OnboardingPageChanged(1));
    await Future<void>.delayed(Duration.zero);
    expect(
      bloc.state,
      OnboardingLoaded(slides: OnboardingSlideModel.defaults, currentPage: 1),
    );

    final finishExpectation = expectLater(
      bloc.stream,
      emits(const OnboardingFinished()),
    );
    bloc.add(const OnboardingCompleted());
    await finishExpectation;
    expect(markComplete.called, isTrue);
    await bloc.close();
  });
}
