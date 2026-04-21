import 'package:equatable/equatable.dart';

import '../../domain/entities/site_visit_record.dart';
import '../../domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final List<SiteVisitRecord> visits;
  final bool isSavingProfile;
  final bool isSubmittingKyc;
  final bool isLoadingVisits;
  final String? message;

  const ProfileState({
    required this.status,
    required this.profile,
    required this.visits,
    required this.isSavingProfile,
    required this.isSubmittingKyc,
    required this.isLoadingVisits,
    required this.message,
  });

  const ProfileState.initial()
      : status = ProfileStatus.initial,
        profile = null,
        visits = const [],
        isSavingProfile = false,
        isSubmittingKyc = false,
        isLoadingVisits = false,
        message = null;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<SiteVisitRecord>? visits,
    bool? isSavingProfile,
    bool? isSubmittingKyc,
    bool? isLoadingVisits,
    String? message,
    bool clearMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      visits: visits ?? this.visits,
      isSavingProfile: isSavingProfile ?? this.isSavingProfile,
      isSubmittingKyc: isSubmittingKyc ?? this.isSubmittingKyc,
      isLoadingVisits: isLoadingVisits ?? this.isLoadingVisits,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        visits,
        isSavingProfile,
        isSubmittingKyc,
        isLoadingVisits,
        message,
      ];
}
