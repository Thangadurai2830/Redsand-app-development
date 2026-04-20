import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const []]);
}

class CacheFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class TokenExpiredFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class NoTokenFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class NetworkFailure extends Failure {
  @override
  List<Object?> get props => [];
}
