part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  const LoginSubmitted({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class LoginWithOtpRequested extends LoginEvent {
  final String email;
  const LoginWithOtpRequested({required this.email});
  @override
  List<Object> get props => [email];
}

class LoginWithGoogleRequested extends LoginEvent {
  final String idToken;
  const LoginWithGoogleRequested({required this.idToken});
  @override
  List<Object> get props => [idToken];
}
