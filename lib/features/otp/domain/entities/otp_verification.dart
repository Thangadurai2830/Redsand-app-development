import 'package:equatable/equatable.dart';

class OtpVerification extends Equatable {
  final String email;
  final String phone;
  final String otp;

  const OtpVerification({
    required this.email,
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, phone, otp];
}
