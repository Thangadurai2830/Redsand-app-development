import 'package:equatable/equatable.dart';

import '../../domain/entities/kyc_submission_request.dart';
import '../../domain/entities/profile_update_request.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final ProfileUpdateRequest request;

  const ProfileUpdateRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class AadhaarUploadRequested extends ProfileEvent {
  final String reference;

  const AadhaarUploadRequested(this.reference);

  @override
  List<Object?> get props => [reference];
}

class PanUploadRequested extends ProfileEvent {
  final String reference;

  const PanUploadRequested(this.reference);

  @override
  List<Object?> get props => [reference];
}

class KycVerificationRequested extends ProfileEvent {
  const KycVerificationRequested();
}

class KycSubmissionRequested extends ProfileEvent {
  final KycSubmissionRequest request;

  const KycSubmissionRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class VisitHistoryRefreshRequested extends ProfileEvent {
  const VisitHistoryRefreshRequested();
}

class ProfileMessageCleared extends ProfileEvent {
  const ProfileMessageCleared();
}
