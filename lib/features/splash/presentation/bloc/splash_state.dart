part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();
  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashAuthenticated extends SplashState {
  final UserRole role;
  const SplashAuthenticated(this.role);
  @override
  List<Object?> get props => [role];
}

class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}

class SplashNeedsOnboarding extends SplashState {
  const SplashNeedsOnboarding();
}

class SplashError extends SplashState {
  final String message;
  const SplashError(this.message);
  @override
  List<Object?> get props => [message];
}
