import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/auth_token.dart';

abstract class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpVerified extends OtpState {
  final AuthToken token;

  const OtpVerified(this.token);

  @override
  List<Object?> get props => [token];
}

class OtpResent extends OtpState {}

class OtpFailure extends OtpState {
  final String message;

  const OtpFailure(this.message);

  @override
  List<Object?> get props => [message];
}
