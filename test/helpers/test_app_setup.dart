import 'package:flutter_app/core/di/injection_container.dart' as di;
import 'package:flutter_app/core/theme/theme_cubit.dart';
import 'package:flutter_app/features/auth/domain/entities/auth_token.dart';
import 'package:flutter_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_app/features/auth/domain/usecases/check_auth_status.dart';
import 'package:flutter_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:flutter_app/features/onboarding/domain/usecases/check_onboarding_status.dart';
import 'package:flutter_app/features/onboarding/domain/usecases/get_onboarding_slides.dart';
import 'package:flutter_app/features/onboarding/domain/usecases/mark_onboarding_complete.dart';
import 'package:flutter_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter_app/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_fakes.dart';

Future<void> registerTestAppDependencies({
  bool onboardingComplete = false,
  AuthToken? authenticatedToken,
}) async {
  await di.sl.reset();
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final authRepository = FakeAuthRepository()
    ..storedToken = authenticatedToken;

  final onboardingRepository = FakeOnboardingRepository()
    ..completed = onboardingComplete;

  di.sl.registerSingleton<SharedPreferences>(prefs);
  di.sl.registerSingleton<ThemeCubit>(ThemeCubit(sharedPreferences: prefs));

  di.sl.registerSingleton<AuthRepository>(authRepository);
  di.sl.registerSingleton<OnboardingRepository>(onboardingRepository);

  di.sl.registerSingleton<CheckAuthStatus>(CheckAuthStatus(authRepository));
  di.sl.registerSingleton<CheckOnboardingStatus>(
    CheckOnboardingStatus(onboardingRepository),
  );
  di.sl.registerSingleton<GetOnboardingSlides>(
    GetOnboardingSlides(onboardingRepository),
  );
  di.sl.registerSingleton<MarkOnboardingComplete>(
    MarkOnboardingComplete(onboardingRepository),
  );

  di.sl.registerFactory<SplashBloc>(
    () => SplashBloc(
      checkAuthStatus: di.sl<CheckAuthStatus>(),
      checkOnboardingStatus: di.sl<CheckOnboardingStatus>(),
    ),
  );

  di.sl.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(
      getOnboardingSlides: di.sl<GetOnboardingSlides>(),
      markOnboardingComplete: di.sl<MarkOnboardingComplete>(),
      checkOnboardingStatus: di.sl<CheckOnboardingStatus>(),
    ),
  );
}
