import 'package:dartz/dartz.dart';
import 'package:flutter_app/core/error/failures.dart';
import 'package:flutter_app/core/usecases/usecase.dart';
import 'package:flutter_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_app/features/auth/data/models/auth_token_model.dart';
import 'package:flutter_app/features/auth/domain/entities/auth_token.dart';
import 'package:flutter_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_app/features/auth/domain/usecases/check_auth_status.dart';
import 'package:flutter_app/features/auth/domain/usecases/login.dart';
import 'package:flutter_app/features/auth/domain/usecases/login_with_google.dart';
import 'package:flutter_app/features/auth/domain/usecases/send_otp.dart';
import 'package:flutter_app/features/feature_selection/domain/entities/app_feature.dart';
import 'package:flutter_app/features/feature_selection/domain/repositories/feature_repository.dart';
import 'package:flutter_app/features/feature_selection/domain/usecases/get_features.dart';
import 'package:flutter_app/features/feature_selection/domain/usecases/save_features.dart';
import 'package:flutter_app/features/feature_selection/domain/usecases/toggle_feature.dart';
import 'package:flutter_app/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:flutter_app/features/maintenance_requests/domain/entities/maintenance_ticket.dart';
import 'package:flutter_app/features/maintenance_requests/domain/repositories/maintenance_repository.dart';
import 'package:flutter_app/features/maintenance_requests/domain/usecases/get_maintenance_history.dart';
import 'package:flutter_app/features/maintenance_requests/domain/usecases/raise_maintenance_request.dart';
import 'package:flutter_app/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:flutter_app/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:flutter_app/features/onboarding/data/models/onboarding_slide_model.dart';
import 'package:flutter_app/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:flutter_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:flutter_app/features/onboarding/domain/usecases/check_onboarding_status.dart';
import 'package:flutter_app/features/onboarding/domain/usecases/get_onboarding_slides.dart';
import 'package:flutter_app/features/onboarding/domain/usecases/mark_onboarding_complete.dart';
import 'package:flutter_app/features/profile/domain/entities/kyc_submission_request.dart';
import 'package:flutter_app/features/profile/domain/entities/profile_update_request.dart';
import 'package:flutter_app/features/profile/domain/entities/site_visit_record.dart';
import 'package:flutter_app/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_app/features/profile/domain/usecases/get_profile.dart';
import 'package:flutter_app/features/profile/domain/usecases/get_site_visits.dart';
import 'package:flutter_app/features/profile/domain/usecases/submit_kyc_documents.dart';
import 'package:flutter_app/features/profile/domain/usecases/update_profile.dart';
import 'package:flutter_app/features/saved_searches/domain/entities/saved_search_alert.dart';
import 'package:flutter_app/features/saved_searches/domain/repositories/saved_searches_repository.dart';
import 'package:flutter_app/features/saved_searches/domain/usecases/get_saved_searches.dart';
import 'package:flutter_app/features/saved_searches/domain/usecases/remove_saved_search.dart';
import 'package:flutter_app/features/saved_searches/domain/usecases/save_saved_search.dart';

// ─── Auth ────────────────────────────────────────────────────────────────────

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  AuthTokenModel? token;
  bool throwOnGet = false;
  bool throwOnSave = false;
  bool throwOnDelete = false;

  @override
  Future<void> deleteToken() async {
    if (throwOnDelete) throw CacheFailure();
    token = null;
  }

  @override
  Future<AuthTokenModel?> getToken() async {
    if (throwOnGet) throw CacheFailure();
    return token;
  }

  @override
  Future<void> saveToken(AuthTokenModel token) async {
    if (throwOnSave) throw CacheFailure();
    this.token = token;
  }
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  AuthTokenModel? loginToken;
  AuthTokenModel? googleToken;
  bool sendOtpResult = true;
  bool throwOnLogin = false;
  bool throwOnGoogle = false;
  bool throwOnSendOtp = false;

  @override
  Future<AuthTokenModel> login(String email, String password, {String? role}) async {
    if (throwOnLogin || loginToken == null) throw NetworkFailure();
    return loginToken!;
  }

  @override
  Future<AuthTokenModel> loginWithGoogle(String idToken) async {
    if (throwOnGoogle || googleToken == null) throw NetworkFailure();
    return googleToken!;
  }

  @override
  Future<bool> sendOtp(String email) async {
    if (throwOnSendOtp) throw NetworkFailure();
    return sendOtpResult;
  }
}

class FakeAuthRepository implements AuthRepository {
  AuthToken? storedToken;
  AuthToken? refreshedToken;
  AuthToken? loginToken;
  AuthToken? googleToken;
  bool throwOnGetStoredToken = false;
  bool throwOnRefreshToken = false;
  bool throwOnClearToken = false;
  bool throwOnLogin = false;
  bool throwOnSendOtp = false;
  bool throwOnGoogleLogin = false;

  @override
  Future<Either<Failure, AuthToken?>> getStoredToken() async {
    if (throwOnGetStoredToken) return Left(CacheFailure());
    return Right(storedToken);
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    if (throwOnRefreshToken || refreshedToken == null) {
      return Left(NetworkFailure());
    }
    return Right(refreshedToken!);
  }

  @override
  Future<Either<Failure, void>> clearToken() async {
    if (throwOnClearToken) return Left(CacheFailure());
    storedToken = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, AuthToken>> login(String username, String password, {String? role}) async {
    if (throwOnLogin || loginToken == null) return Left(NetworkFailure());
    storedToken = loginToken;
    return Right(loginToken!);
  }

  @override
  Future<Either<Failure, bool>> sendOtp(String email) async {
    if (throwOnSendOtp) return Left(NetworkFailure());
    return const Right(true);
  }

  @override
  Future<Either<Failure, AuthToken>> loginWithGoogle(String idToken) async {
    if (throwOnGoogleLogin || googleToken == null) return Left(NetworkFailure());
    storedToken = googleToken;
    return Right(googleToken!);
  }
}

// ─── Onboarding ──────────────────────────────────────────────────────────────

class FakeOnboardingLocalDataSource implements OnboardingLocalDataSource {
  List<OnboardingSlideModel>? cachedSlides;
  bool onboardingComplete = false;
  bool throwOnGetCachedSlides = false;
  bool throwOnCacheSlides = false;
  bool throwOnSetComplete = false;
  bool throwOnReadComplete = false;

  @override
  Future<void> cacheSlides(List<OnboardingSlideModel> slides) async {
    if (throwOnCacheSlides) throw CacheFailure();
    cachedSlides = slides;
  }

  @override
  Future<List<OnboardingSlideModel>> getCachedSlides() async {
    if (throwOnGetCachedSlides || cachedSlides == null) throw CacheFailure();
    return cachedSlides!;
  }

  @override
  Future<bool> isOnboardingComplete() async {
    if (throwOnReadComplete) throw CacheFailure();
    return onboardingComplete;
  }

  @override
  Future<void> setOnboardingComplete() async {
    if (throwOnSetComplete) throw CacheFailure();
    onboardingComplete = true;
  }
}

class FakeOnboardingRemoteDataSource implements OnboardingRemoteDataSource {
  List<OnboardingSlideModel>? slides;
  bool throwOnGetSlides = false;

  @override
  Future<List<OnboardingSlideModel>> getSlides() async {
    if (throwOnGetSlides || slides == null) throw NetworkFailure();
    return slides!;
  }
}

class FakeOnboardingRepository implements OnboardingRepository {
  List<OnboardingSlide> slides = OnboardingSlideModel.defaults;
  bool completed = false;
  bool throwOnSlides = false;
  bool throwOnComplete = false;
  bool throwOnStatus = false;

  @override
  Future<Either<Failure, List<OnboardingSlide>>> getSlides() async {
    if (throwOnSlides) return Left(NetworkFailure());
    return Right(slides);
  }

  @override
  Future<Either<Failure, void>> markOnboardingComplete() async {
    if (throwOnComplete) return Left(CacheFailure());
    completed = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> hasCompletedOnboarding() async {
    if (throwOnStatus) return Left(CacheFailure());
    return Right(completed);
  }
}

// ─── Auth use-case fakes ─────────────────────────────────────────────────────

class FakeCheckAuthStatus implements CheckAuthStatus {
  Either<Failure, AuthStatus> result;

  FakeCheckAuthStatus(this.result);

  @override
  AuthRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthStatus>> call(NoParams params) async => result;
}

class FakeCheckOnboardingStatus implements CheckOnboardingStatus {
  Either<Failure, bool> result;

  FakeCheckOnboardingStatus(this.result);

  @override
  OnboardingRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, bool>> call(NoParams params) async => result;
}

class FakeLoginUseCase implements Login {
  Either<Failure, AuthToken> result;

  FakeLoginUseCase(this.result);

  @override
  AuthRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthToken>> call(LoginParams params) async => result;
}

class FakeSendOtpUseCase implements SendOtp {
  Either<Failure, bool> result;

  FakeSendOtpUseCase(this.result);

  @override
  AuthRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, bool>> call(String email) async => result;
}

class FakeLoginWithGoogleUseCase implements LoginWithGoogle {
  Either<Failure, AuthToken> result;

  FakeLoginWithGoogleUseCase(this.result);

  @override
  AuthRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthToken>> call(String idToken) async => result;
}

class FakeGetOnboardingSlides implements GetOnboardingSlides {
  Either<Failure, List<OnboardingSlide>> result;

  FakeGetOnboardingSlides(this.result);

  @override
  OnboardingRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<OnboardingSlide>>> call(NoParams params) async =>
      result;
}

class FakeMarkOnboardingComplete implements MarkOnboardingComplete {
  Either<Failure, void> result;
  bool called = false;

  FakeMarkOnboardingComplete(this.result);

  @override
  OnboardingRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    called = true;
    return result;
  }
}

// ─── SavedSearches ───────────────────────────────────────────────────────────

class FakeSavedSearchesRepository implements SavedSearchesRepository {
  List<SavedSearchAlert> searches = [];
  bool throwOnGet = false;
  bool throwOnSave = false;
  bool throwOnRemove = false;
  SavedSearchAlert? savedResult;

  @override
  Future<Either<Failure, List<SavedSearchAlert>>> getSavedSearches() async {
    if (throwOnGet) return Left(NetworkFailure());
    return Right(List.from(searches));
  }

  @override
  Future<Either<Failure, SavedSearchAlert>> saveSavedSearch(SavedSearchAlert search) async {
    if (throwOnSave) return Left(NetworkFailure());
    final result = savedResult ?? search;
    searches.insert(0, result);
    return Right(result);
  }

  @override
  Future<Either<Failure, void>> removeSavedSearch(String id) async {
    if (throwOnRemove) return Left(NetworkFailure());
    searches.removeWhere((s) => s.id == id);
    return const Right(null);
  }
}

class FakeGetSavedSearches implements GetSavedSearches {
  Either<Failure, List<SavedSearchAlert>> result;
  FakeGetSavedSearches(this.result);

  @override
  SavedSearchesRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<SavedSearchAlert>>> call() async => result;
}

class FakeSaveSavedSearch implements SaveSavedSearch {
  Either<Failure, SavedSearchAlert> result;
  FakeSaveSavedSearch(this.result);

  @override
  SavedSearchesRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, SavedSearchAlert>> call(SavedSearchAlert search) async => result;
}

class FakeRemoveSavedSearch implements RemoveSavedSearch {
  Either<Failure, void> result;
  FakeRemoveSavedSearch(this.result);

  @override
  SavedSearchesRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> call(String id) async => result;
}

// ─── Profile ─────────────────────────────────────────────────────────────────

class FakeProfileRepository implements ProfileRepository {
  UserProfile? profile;
  List<SiteVisitRecord> visits = [];
  bool throwOnGetProfile = false;
  bool throwOnUpdateProfile = false;
  bool throwOnSubmitKyc = false;
  bool throwOnGetVisits = false;
  String kycMessage = 'KYC submitted successfully';

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    if (throwOnGetProfile || profile == null) return Left(NetworkFailure());
    return Right(profile!);
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(ProfileUpdateRequest request) async {
    if (throwOnUpdateProfile || profile == null) return Left(NetworkFailure());
    final updated = UserProfile(
      fullName: request.fullName,
      email: profile!.email,
      phone: request.phone,
      address: request.address,
      avatarUrl: profile!.avatarUrl,
      kycStatus: profile!.kycStatus,
      aadhaarVerified: profile!.aadhaarVerified,
      panVerified: profile!.panVerified,
      verificationMessage: profile!.verificationMessage,
    );
    profile = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, String>> submitKycDocuments(KycSubmissionRequest request) async {
    if (throwOnSubmitKyc) return Left(NetworkFailure());
    return Right(kycMessage);
  }

  @override
  Future<Either<Failure, List<SiteVisitRecord>>> getSiteVisits() async {
    if (throwOnGetVisits) return Left(NetworkFailure());
    return Right(List.from(visits));
  }
}

class FakeGetProfile implements GetProfile {
  Either<Failure, UserProfile> result;
  FakeGetProfile(this.result);

  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) async => result;
}

class FakeUpdateProfile implements UpdateProfile {
  Either<Failure, UserProfile> result;
  FakeUpdateProfile(this.result);

  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, UserProfile>> call(ProfileUpdateRequest params) async => result;
}

class FakeSubmitKycDocuments implements SubmitKycDocuments {
  Either<Failure, String> result;
  FakeSubmitKycDocuments(this.result);

  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> call(KycSubmissionRequest params) async => result;
}

class FakeGetSiteVisits implements GetSiteVisits {
  Either<Failure, List<SiteVisitRecord>> result;
  FakeGetSiteVisits(this.result);

  @override
  ProfileRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<SiteVisitRecord>>> call(NoParams params) async => result;
}

// ─── MaintenanceRequests ──────────────────────────────────────────────────────

class FakeMaintenanceRepository implements MaintenanceRepository {
  List<MaintenanceTicket> tickets = [];
  bool throwOnFetch = false;
  bool throwOnRaise = false;
  MaintenanceTicket? raisedTicket;

  @override
  Future<Either<Failure, List<MaintenanceTicket>>> fetchMaintenanceHistory() async {
    if (throwOnFetch) return Left(NetworkFailure());
    return Right(List.from(tickets));
  }

  @override
  Future<Either<Failure, MaintenanceTicket>> raiseMaintenanceRequest(MaintenanceRequest request) async {
    if (throwOnRaise || raisedTicket == null) return Left(NetworkFailure());
    tickets.add(raisedTicket!);
    return Right(raisedTicket!);
  }
}

class FakeGetMaintenanceHistory implements GetMaintenanceHistory {
  Either<Failure, List<MaintenanceTicket>> result;
  FakeGetMaintenanceHistory(this.result);

  @override
  MaintenanceRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<MaintenanceTicket>>> call(NoParams params) async => result;
}

class FakeRaiseMaintenanceRequest implements RaiseMaintenanceRequest {
  Either<Failure, MaintenanceTicket> result;
  FakeRaiseMaintenanceRequest(this.result);

  @override
  MaintenanceRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, MaintenanceTicket>> call(MaintenanceRequest request) async => result;
}

// ─── FeatureSelection ─────────────────────────────────────────────────────────

class FakeFeatureRepository implements FeatureRepository {
  List<AppFeature> features = [];
  bool throwOnGet = false;
  bool throwOnToggle = false;
  bool throwOnSave = false;

  @override
  Future<Either<Failure, List<AppFeature>>> getFeatures() async {
    if (throwOnGet) return Left(NetworkFailure());
    return Right(List.from(features));
  }

  @override
  Future<Either<Failure, AppFeature>> toggleFeature(String featureId, bool isEnabled) async {
    if (throwOnToggle) return Left(NetworkFailure());
    final idx = features.indexWhere((f) => f.id == featureId);
    if (idx == -1) return Left(NetworkFailure());
    final updated = features[idx].copyWith(isEnabled: isEnabled);
    features[idx] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, void>> saveFeatures(List<AppFeature> features) async {
    if (throwOnSave) return Left(NetworkFailure());
    this.features = List.from(features);
    return const Right(null);
  }
}

class FakeGetFeatures implements GetFeatures {
  Either<Failure, List<AppFeature>> result;
  FakeGetFeatures(this.result);

  @override
  FeatureRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, List<AppFeature>>> call(NoParams params) async => result;
}

class FakeToggleFeature implements ToggleFeature {
  Either<Failure, AppFeature> result;
  FakeToggleFeature(this.result);

  @override
  FeatureRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, AppFeature>> call(ToggleFeatureParams params) async => result;
}

class FakeSaveFeatures implements SaveFeatures {
  Either<Failure, void> result;
  FakeSaveFeatures(this.result);

  @override
  FeatureRepository get repository => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> call(SaveFeaturesParams params) async => result;
}
