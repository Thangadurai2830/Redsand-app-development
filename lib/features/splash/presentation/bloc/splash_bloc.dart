import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../features/auth/domain/entities/user_role.dart';
import '../../../../features/auth/domain/usecases/check_auth_status.dart';
import '../../../../features/onboarding/domain/usecases/check_onboarding_status.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CheckAuthStatus checkAuthStatus;
  final CheckOnboardingStatus checkOnboardingStatus;

  SplashBloc({
    required this.checkAuthStatus,
    required this.checkOnboardingStatus,
  }) : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    await Future.delayed(const Duration(milliseconds: 2000));

    final authResult = await checkAuthStatus(const NoParams());

    await authResult.fold(
      (_) async => emit(await _resolveUnauthenticated()),
      (status) async {
        if (status.isAuthenticated && status.role != null) {
          emit(SplashAuthenticated(status.role!));
        } else {
          emit(await _resolveUnauthenticated());
        }
      },
    );
  }

  Future<SplashState> _resolveUnauthenticated() async {
    final onboardingResult = await checkOnboardingStatus(const NoParams());
    return onboardingResult.fold(
      (_) => const SplashNeedsOnboarding(),
      (done) => done ? const SplashUnauthenticated() : const SplashNeedsOnboarding(),
    );
  }
}
