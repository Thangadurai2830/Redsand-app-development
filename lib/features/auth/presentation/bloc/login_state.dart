part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserRole role;
  const LoginSuccess(this.role);
  @override
  List<Object> get props => [role];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);
  @override
  List<Object> get props => [message];
}

/// OTP was sent successfully — navigate to OTP page with this email.
class LoginOtpSent extends LoginState {
  final String email;
  const LoginOtpSent(this.email);
  @override
  List<Object> get props => [email];
}

class LogoutSuccess extends LoginState {
  const LogoutSuccess();
}

class LogoutFailure extends LoginState {
  final String message;
  const LogoutFailure(this.message);
  @override
  List<Object> get props => [message];
}
