import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/otp_verification.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final VerifyOtpUsecase verifyOtp;
  final ResendOtpUsecase resendOtp;

  OtpBloc({required this.verifyOtp, required this.resendOtp}) : super(OtpInitial()) {
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpLoading());
    final result = await verifyOtp(OtpVerification(
      email: event.email,
      phone: event.phone,
      otp: event.otp,
    ));
    result.fold(
      (failure) => emit(const OtpFailure('Invalid OTP. Please try again.')),
      (token) => emit(OtpVerified(token)),
    );
  }

  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpLoading());
    final result = await resendOtp(event.email);
    result.fold(
      (failure) => emit(const OtpFailure('Failed to resend OTP. Try again.')),
      (_) => emit(OtpResent()),
    );
  }
}
