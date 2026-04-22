import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../onboarding/domain/entities/onboarding_slide.dart';
import '../../domain/usecases/check_onboarding_status.dart';
import '../../domain/usecases/get_onboarding_slides.dart';
import '../../domain/usecases/mark_onboarding_complete.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingSlides getOnboardingSlides;
  final MarkOnboardingComplete markOnboardingComplete;
  final CheckOnboardingStatus checkOnboardingStatus;

  OnboardingBloc({
    required this.getOnboardingSlides,
    required this.markOnboardingComplete,
    required this.checkOnboardingStatus,
  }) : super(const OnboardingInitial()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingSkipped>(_onSkipped);
    on<OnboardingCompleted>(_onCompleted);
  }

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    final result = await getOnboardingSlides(const NoParams());
    result.fold(
      (failure) => emit(const OnboardingError('Failed to load slides')),
      (slides) => emit(OnboardingLoaded(slides: slides)),
    );
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    final current = state;
    if (current is OnboardingLoaded) {
      emit(current.copyWith(currentPage: event.pageIndex));
    }
  }

  Future<void> _onSkipped(
    OnboardingSkipped event,
    Emitter<OnboardingState> emit,
  ) async {
    await markOnboardingComplete(const NoParams());
    emit(const OnboardingFinished());
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    await markOnboardingComplete(const NoParams());
    emit(const OnboardingFinished());
  }
}
