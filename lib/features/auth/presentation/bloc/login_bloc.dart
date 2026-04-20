import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/login_with_google.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Login login;
  final SendOtp sendOtp;
  final LoginWithGoogle loginWithGoogle;

  LoginBloc({
    required this.login,
    required this.sendOtp,
    required this.loginWithGoogle,
  }) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithOtpRequested>(_onLoginWithOtpRequested);
    on<LoginWithGoogleRequested>(_onLoginWithGoogleRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    final result = await login(
      LoginParams(username: event.email, password: event.password),
    );
    result.fold(
      (_) => emit(const LoginFailure('Invalid credentials. Please try again.')),
      (token) => emit(LoginSuccess(token.role)),
    );
  }

  Future<void> _onLoginWithOtpRequested(
    LoginWithOtpRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    final result = await sendOtp(event.email);
    result.fold(
      (_) => emit(const LoginFailure('Failed to send OTP. Please try again.')),
      (_) => emit(LoginOtpSent(event.email)),
    );
  }

  Future<void> _onLoginWithGoogleRequested(
    LoginWithGoogleRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    final result = await loginWithGoogle(event.idToken);
    result.fold(
      (_) => emit(const LoginFailure('Google login failed. Please try again.')),
      (token) => emit(LoginSuccess(token.role)),
    );
  }
}
