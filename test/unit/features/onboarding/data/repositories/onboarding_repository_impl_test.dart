import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/onboarding/data/models/onboarding_slide_model.dart';
import 'package:flutter_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';

import '../../../../../helpers/test_fakes.dart';

void main() {
  late FakeOnboardingRemoteDataSource remoteDataSource;
  late FakeOnboardingLocalDataSource localDataSource;
  late OnboardingRepositoryImpl repository;

  setUp(() {
    remoteDataSource = FakeOnboardingRemoteDataSource();
    localDataSource = FakeOnboardingLocalDataSource();
    repository = OnboardingRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  });

  test('caches remote slides when network succeeds', () async {
    final slides = [
      const OnboardingSlideModel(
        id: '1',
        title: 'Welcome',
        description: 'Hello',
        illustration: 'rental',
      ),
    ];
    remoteDataSource.slides = slides;

    final result = await repository.getSlides();

    final returnedSlides = result.fold(
      (failure) => fail('Expected remote slides, got $failure'),
      (value) => value,
    );
    expect(returnedSlides, slides);
    expect(localDataSource.cachedSlides, slides);
  });

  test('falls back to cached slides after a network failure', () async {
    remoteDataSource.throwOnGetSlides = true;
    final cachedSlides = OnboardingSlideModel.defaults;
    localDataSource.cachedSlides = cachedSlides;

    final result = await repository.getSlides();

    final returnedSlides = result.fold(
      (failure) => fail('Expected cached slides, got $failure'),
      (value) => value,
    );
    expect(returnedSlides, cachedSlides);
  });

  test('returns built-in defaults when remote and cache both fail', () async {
    remoteDataSource.throwOnGetSlides = true;
    localDataSource.throwOnGetCachedSlides = true;

    final result = await repository.getSlides();

    final slides = result.fold(
      (failure) => fail('Expected defaults, got $failure'),
      (value) => value,
    );
    expect(slides, OnboardingSlideModel.defaults);
  });

  test('marks onboarding as complete locally', () async {
    final result = await repository.markOnboardingComplete();

    result.fold(
      (failure) => fail('Expected completion success, got $failure'),
      (_) {},
    );
    expect(localDataSource.onboardingComplete, isTrue);
  });

  test('reads onboarding completion status from local storage', () async {
    localDataSource.onboardingComplete = true;

    final result = await repository.hasCompletedOnboarding();

    final completed = result.fold(
      (failure) => fail('Expected completion status, got $failure'),
      (value) => value,
    );
    expect(completed, isTrue);
  });
}
