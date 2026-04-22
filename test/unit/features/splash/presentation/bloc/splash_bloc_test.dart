import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/auth/domain/entities/user_role.dart';
import 'package:flutter_app/features/auth/domain/usecases/check_auth_status.dart';
import 'package:flutter_app/features/splash/presentation/bloc/splash_bloc.dart';

import '../../../../../helpers/test_fakes.dart';

void main() {
  test('authenticated users are routed to their dashboard role', () async {
    final bloc = SplashBloc(
      checkAuthStatus: FakeCheckAuthStatus(
        const Right(AuthStatus(isAuthenticated: true, role: UserRole.admin)),
      ),
      checkOnboardingStatus: FakeCheckOnboardingStatus(const Right(true)),
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        const SplashLoading(),
        const SplashAuthenticated(UserRole.admin),
      ]),
    );

    bloc.add(const SplashStarted());
    await expectation;
    await bloc.close();
  });

  test('users without auth but completed onboarding see unauthenticated flow', () async {
    final bloc = SplashBloc(
      checkAuthStatus: FakeCheckAuthStatus(
        const Right(AuthStatus(isAuthenticated: false)),
      ),
      checkOnboardingStatus: FakeCheckOnboardingStatus(const Right(true)),
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        const SplashLoading(),
        const SplashUnauthenticated(),
      ]),
    );

    bloc.add(const SplashStarted());
    await expectation;
    await bloc.close();
  });
}
