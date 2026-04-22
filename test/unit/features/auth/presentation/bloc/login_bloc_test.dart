import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/error/failures.dart';
import 'package:flutter_app/features/auth/data/models/auth_token_model.dart';
import 'package:flutter_app/features/auth/domain/entities/user_role.dart';
import 'package:flutter_app/features/auth/presentation/bloc/login_bloc.dart';

import '../../../../../helpers/test_fakes.dart';

void main() {
  test('submitting credentials emits loading then success', () async {
    final token = AuthTokenModel(
      accessToken: 'access',
      refreshToken: 'refresh',
      role: UserRole.owner,
      expiresAt: DateTime.parse('2030-01-01T00:00:00.000Z'),
    );
    final bloc = LoginBloc(
      login: FakeLoginUseCase(Right(token)),
      sendOtp: FakeSendOtpUseCase(const Right(true)),
      loginWithGoogle: FakeLoginWithGoogleUseCase(Right(token)),
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        const LoginLoading(),
        const LoginSuccess(UserRole.owner),
      ]),
    );

    bloc.add(const LoginSubmitted(
      email: 'owner@example.com',
      password: 'secret',
    ));

    await expectation;
    await bloc.close();
  });

  test('requesting OTP emits loading then OTP sent', () async {
    final bloc = LoginBloc(
      login: FakeLoginUseCase(Left(NetworkFailure())),
      sendOtp: FakeSendOtpUseCase(const Right(true)),
      loginWithGoogle: FakeLoginWithGoogleUseCase(Left(NetworkFailure())),
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        const LoginLoading(),
        const LoginOtpSent('test@example.com'),
      ]),
    );

    bloc.add(const LoginWithOtpRequested(email: 'test@example.com'));

    await expectation;
    await bloc.close();
  });
}
