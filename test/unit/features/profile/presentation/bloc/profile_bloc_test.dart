import 'package:dartz/dartz.dart';
import 'package:flutter_app/core/error/failures.dart';
import 'package:flutter_app/features/profile/domain/entities/kyc_submission_request.dart';
import 'package:flutter_app/features/profile/domain/entities/profile_update_request.dart';
import 'package:flutter_app/features/profile/domain/entities/site_visit_record.dart';
import 'package:flutter_app/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:flutter_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_fakes.dart';

UserProfile get _profile => const UserProfile(
      fullName: 'Priya Sharma',
      email: 'priya@example.com',
      phone: '9876543210',
      address: 'Koramangala, Bangalore',
      avatarUrl: 'https://example.com/avatar.jpg',
      kycStatus: 'pending',
      aadhaarVerified: false,
      panVerified: false,
      verificationMessage: '',
    );

SiteVisitRecord get _visit => const SiteVisitRecord(
      id: 'v-1',
      propertyName: 'Sunrise Apartments',
      propertyAddress: 'HSR Layout',
      visitDate: '2024-03-20',
      visitTime: '10:00 AM',
      status: 'completed',
      receiptUrl: null,
      notes: 'Good property',
    );

ProfileBloc _makeBloc({
  required FakeGetProfile getProfile,
  required FakeUpdateProfile updateProfile,
  required FakeSubmitKycDocuments submitKyc,
  required FakeGetSiteVisits getSiteVisits,
}) =>
    ProfileBloc(
      getProfile: getProfile,
      updateProfile: updateProfile,
      submitKycDocuments: submitKyc,
      getSiteVisits: getSiteVisits,
    );

void main() {
  group('ProfileBloc – ProfileLoadRequested', () {
    test('emits loading then loaded with profile and visits', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('KYC submitted')),
        getSiteVisits: FakeGetSiteVisits(Right([_visit])),
      );

      final states = <ProfileState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ProfileLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.first.status, ProfileStatus.loading);
      final loaded = states.last;
      expect(loaded.status, ProfileStatus.loaded);
      expect(loaded.profile, _profile);
      expect(loaded.visits, [_visit]);
      expect(loaded.message, isNull);

      await sub.cancel();
      await bloc.close();
    });

    test('emits failure when getProfile fails', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Left(NetworkFailure())),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('ok')),
        getSiteVisits: FakeGetSiteVisits(const Right([])),
      );

      bloc.add(const ProfileLoadRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == ProfileStatus.failure,
      );

      expect(state.message, 'Network error. Please try again.');
      await bloc.close();
    });

    test('loads profile even when getSiteVisits fails', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('ok')),
        getSiteVisits: FakeGetSiteVisits(Left(NetworkFailure())),
      );

      bloc.add(const ProfileLoadRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == ProfileStatus.loaded,
      );

      expect(state.profile, _profile);
      expect(state.visits, isEmpty);
      expect(state.message, isNotNull);
      await bloc.close();
    });
  });

  group('ProfileBloc – ProfileRefreshRequested', () {
    test('emits loaded with refresh message on success', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('ok')),
        getSiteVisits: FakeGetSiteVisits(Right([_visit])),
      );

      bloc.add(const ProfileRefreshRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == ProfileStatus.loaded,
      );

      expect(state.message, 'Profile refreshed');
      await bloc.close();
    });
  });

  group('ProfileBloc – ProfileUpdateRequested', () {
    test('emits isSavingProfile then loaded with success message', () async {
      const updated = UserProfile(
        fullName: 'Priya Updated',
        email: 'priya@example.com',
        phone: '9000000000',
        address: 'Indiranagar',
        avatarUrl: '',
        kycStatus: 'pending',
        aadhaarVerified: false,
        panVerified: false,
        verificationMessage: '',
      );

      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(const Right(updated)),
        submitKyc: FakeSubmitKycDocuments(const Right('ok')),
        getSiteVisits: FakeGetSiteVisits(const Right([])),
      );

      bloc.add(const ProfileUpdateRequested(
        ProfileUpdateRequest(
          fullName: 'Priya Updated',
          phone: '9000000000',
          address: 'Indiranagar',
        ),
      ));

      final states = await bloc.stream.take(2).toList();
      expect(states[0].isSavingProfile, isTrue);
      expect(states[1].status, ProfileStatus.loaded);
      expect(states[1].isSavingProfile, isFalse);
      expect(states[1].message, 'Profile updated successfully');
      expect(states[1].profile?.fullName, 'Priya Updated');
      await bloc.close();
    });

    test('emits failure when updateProfile fails', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Left(NetworkFailure())),
        submitKyc: FakeSubmitKycDocuments(const Right('ok')),
        getSiteVisits: FakeGetSiteVisits(const Right([])),
      );

      bloc.add(const ProfileUpdateRequested(
        ProfileUpdateRequest(fullName: 'X', phone: '0', address: 'Y'),
      ));

      final state = await bloc.stream.firstWhere(
        (s) => s.status == ProfileStatus.failure,
      );
      expect(state.isSavingProfile, isFalse);
      expect(state.message, isNotNull);
      await bloc.close();
    });
  });

  group('ProfileBloc – KYC events', () {
    test('AadhaarUploadRequested emits isSubmittingKyc then loaded', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('Aadhaar submitted')),
        getSiteVisits: FakeGetSiteVisits(const Right([])),
      );

      bloc.add(const AadhaarUploadRequested('aadhaar-ref-123'));

      final states = await bloc.stream.take(2).toList();
      expect(states[0].isSubmittingKyc, isTrue);
      expect(states[1].isSubmittingKyc, isFalse);
      expect(states[1].message, 'Aadhaar submitted');
      await bloc.close();
    });

    test('PanUploadRequested emits isSubmittingKyc then loaded', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('PAN submitted')),
        getSiteVisits: FakeGetSiteVisits(const Right([])),
      );

      bloc.add(const PanUploadRequested('pan-ref-456'));

      final states = await bloc.stream.take(2).toList();
      expect(states[0].isSubmittingKyc, isTrue);
      expect(states[1].isSubmittingKyc, isFalse);
      expect(states[1].message, 'PAN submitted');
      await bloc.close();
    });

    test('KycSubmissionRequested delegates to submitKycDocuments', () async {
      const request = KycSubmissionRequest(
        aadhaarReference: 'a-ref',
        panReference: 'p-ref',
        notes: 'Both docs',
      );

      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('KYC complete')),
        getSiteVisits: FakeGetSiteVisits(const Right([])),
      );

      bloc.add(const KycSubmissionRequested(request));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == ProfileStatus.loaded && s.message != null,
      );

      expect(state.message, 'KYC complete');
      await bloc.close();
    });

    test('KYC failure emits failure state', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(Left(NetworkFailure())),
        getSiteVisits: FakeGetSiteVisits(const Right([])),
      );

      bloc.add(const AadhaarUploadRequested('bad-ref'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == ProfileStatus.failure,
      );

      expect(state.isSubmittingKyc, isFalse);
      await bloc.close();
    });
  });

  group('ProfileBloc – VisitHistoryRefreshRequested', () {
    test('emits isLoadingVisits then loaded with visits', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('ok')),
        getSiteVisits: FakeGetSiteVisits(Right([_visit])),
      );

      bloc.add(const VisitHistoryRefreshRequested());
      final states = await bloc.stream.take(2).toList();

      expect(states[0].isLoadingVisits, isTrue);
      expect(states[1].status, ProfileStatus.loaded);
      expect(states[1].visits, [_visit]);
      expect(states[1].message, 'Visit history refreshed');
      await bloc.close();
    });

    test('emits failure when getSiteVisits fails', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Right(_profile)),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('ok')),
        getSiteVisits: FakeGetSiteVisits(Left(NetworkFailure())),
      );

      bloc.add(const VisitHistoryRefreshRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == ProfileStatus.failure,
      );

      expect(state.isLoadingVisits, isFalse);
      await bloc.close();
    });
  });

  group('ProfileBloc – ProfileMessageCleared', () {
    test('clears message', () async {
      final bloc = _makeBloc(
        getProfile: FakeGetProfile(Left(NetworkFailure())),
        updateProfile: FakeUpdateProfile(Right(_profile)),
        submitKyc: FakeSubmitKycDocuments(const Right('ok')),
        getSiteVisits: FakeGetSiteVisits(const Right([])),
      );

      bloc.add(const ProfileLoadRequested());
      await bloc.stream.firstWhere((s) => s.message != null);

      bloc.add(const ProfileMessageCleared());
      final state = await bloc.stream.first;
      expect(state.message, isNull);
      await bloc.close();
    });
  });
}
