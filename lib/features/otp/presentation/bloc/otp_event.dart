import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

class OtpSubmitted extends OtpEvent {
  final String email;
  final String phone;
  final String otp;

  const OtpSubmitted({
    required this.email,
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, phone, otp];
}

class OtpResendRequested extends OtpEvent {
  final String email;

  const OtpResendRequested(this.email);

  @override
  List<Object?> get props => [email];
}
