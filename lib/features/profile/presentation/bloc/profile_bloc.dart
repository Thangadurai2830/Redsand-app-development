import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/kyc_submission_request.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/get_site_visits.dart';
import '../../domain/usecases/submit_kyc_documents.dart';
import '../../domain/usecases/update_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final SubmitKycDocuments submitKycDocuments;
  final GetSiteVisits getSiteVisits;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.submitKycDocuments,
    required this.getSiteVisits,
  }) : super(const ProfileState.initial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileRefreshRequested>(_onRefreshRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<AadhaarUploadRequested>(_onAadhaarUploadRequested);
    on<PanUploadRequested>(_onPanUploadRequested);
    on<KycVerificationRequested>(_onVerificationRequested);
    on<KycSubmissionRequested>(_onKycSubmissionRequested);
    on<VisitHistoryRefreshRequested>(_onVisitHistoryRefreshRequested);
    on<ProfileMessageCleared>(_onMessageCleared);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearMessage: true));
    await _loadAll(emit);
  }

  Future<void> _onRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      status: state.profile == null ? ProfileStatus.loading : state.status,
      isLoadingVisits: true,
      clearMessage: true,
    ));
    await _loadAll(emit, successMessage: 'Profile refreshed');
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSavingProfile: true, clearMessage: true));
    final result = await updateProfile(event.request);
    result.fold(
      (failure) => emit(_failureState(_messageForFailure(failure))),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        isSavingProfile: false,
        message: 'Profile updated successfully',
      )),
    );
  }

  Future<void> _onAadhaarUploadRequested(
    AadhaarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _submitKyc(
      emit,
      KycSubmissionRequest(
        aadhaarReference: event.reference,
        panReference: '',
        notes: 'Aadhaar document uploaded from profile screen',
      ),
    );
  }

  Future<void> _onPanUploadRequested(
    PanUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _submitKyc(
      emit,
      KycSubmissionRequest(
        aadhaarReference: '',
        panReference: event.reference,
        notes: 'PAN document uploaded from profile screen',
      ),
    );
  }

  Future<void> _onVerificationRequested(
    KycVerificationRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _loadProfileOnly(emit);
  }

  Future<void> _onKycSubmissionRequested(
    KycSubmissionRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _submitKyc(emit, event.request);
  }

  Future<void> _onVisitHistoryRefreshRequested(
    VisitHistoryRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoadingVisits: true, clearMessage: true));
    final result = await getSiteVisits(const NoParams());
    result.fold(
      (failure) => emit(_failureState(_messageForFailure(failure))),
      (visits) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        visits: visits,
        isLoadingVisits: false,
        message: 'Visit history refreshed',
      )),
    );
  }

  void _onMessageCleared(
    ProfileMessageCleared event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }

  Future<void> _loadAll(
    Emitter<ProfileState> emit, {
    String? successMessage,
  }) async {
    final profileResult = await getProfile(const NoParams());
    final visitResult = await getSiteVisits(const NoParams());

    profileResult.fold(
      (failure) => emit(_failureState(_messageForFailure(failure))),
      (profile) {
        visitResult.fold(
          (failure) => emit(state.copyWith(
            status: ProfileStatus.loaded,
            profile: profile,
            visits: const [],
            isSavingProfile: false,
            isSubmittingKyc: false,
            isLoadingVisits: false,
            message: _messageForFailure(failure),
          )),
          (visits) => emit(state.copyWith(
            status: ProfileStatus.loaded,
            profile: profile,
            visits: visits,
            isSavingProfile: false,
            isSubmittingKyc: false,
            isLoadingVisits: false,
            message: successMessage,
          )),
        );
      },
    );
  }

  Future<void> _loadProfileOnly(Emitter<ProfileState> emit) async {
    emit(state.copyWith(clearMessage: true));
    final result = await getProfile(const NoParams());
    result.fold(
      (failure) => emit(_failureState(_messageForFailure(failure))),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        message: 'KYC status refreshed',
      )),
    );
  }

  Future<void> _submitKyc(
    Emitter<ProfileState> emit,
    KycSubmissionRequest request,
  ) async {
    emit(state.copyWith(isSubmittingKyc: true, clearMessage: true));
    final result = await submitKycDocuments(request);
    result.fold(
      (failure) => emit(_failureState(_messageForFailure(failure))),
      (message) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        isSubmittingKyc: false,
        message: message,
      )),
    );
  }

  ProfileState _failureState(String message) {
    return state.copyWith(
      status: ProfileStatus.failure,
      isSavingProfile: false,
      isSubmittingKyc: false,
      isLoadingVisits: false,
      message: message,
    );
  }

  String _messageForFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Network error. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
