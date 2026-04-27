import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../network/api_client.dart';

// Auth feature
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/send_otp.dart';
import '../../features/auth/domain/usecases/login_with_google.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';

// Splash feature
import '../../features/splash/presentation/bloc/splash_bloc.dart';

// Onboarding feature
import '../../features/onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/check_onboarding_status.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_slides.dart';
import '../../features/onboarding/domain/usecases/mark_onboarding_complete.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

// Search result feature
import '../../features/search_result/presentation/bloc/search_result_bloc.dart';

// Saved searches feature
import '../../features/saved_searches/data/datasources/saved_searches_local_data_source.dart';
import '../../features/saved_searches/data/datasources/saved_searches_remote_data_source.dart';
import '../../features/saved_searches/data/repositories/saved_searches_repository_impl.dart';
import '../../features/saved_searches/domain/repositories/saved_searches_repository.dart';
import '../../features/saved_searches/domain/usecases/get_saved_searches.dart';
import '../../features/saved_searches/domain/usecases/remove_saved_search.dart';
import '../../features/saved_searches/domain/usecases/save_saved_search.dart';
import '../../features/saved_searches/presentation/bloc/saved_searches_bloc.dart';

// Home feature
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

// Property details feature
import '../../features/property_details/data/datasources/property_details_local_data_source.dart';
import '../../features/property_details/data/datasources/property_details_remote_data_source.dart';
import '../../features/property_details/data/repositories/property_details_repository_impl.dart';
import '../../features/property_details/domain/repositories/property_details_repository.dart';
import '../../features/property_details/presentation/bloc/property_details_bloc.dart';

// Reviews feature
import '../../features/reviews/data/datasources/reviews_remote_data_source.dart';
import '../../features/reviews/data/repositories/reviews_repository_impl.dart';
import '../../features/reviews/domain/repositories/reviews_repository.dart';
import '../../features/reviews/domain/usecases/get_property_reviews.dart';
import '../../features/reviews/domain/usecases/submit_review.dart';
import '../../features/reviews/presentation/bloc/reviews_bloc.dart';

// Schedule visit feature
import '../../features/schedule_visit/data/datasources/schedule_visit_remote_data_source.dart';
import '../../features/schedule_visit/data/repositories/schedule_visit_repository_impl.dart';
import '../../features/schedule_visit/domain/repositories/schedule_visit_repository.dart';
import '../../features/schedule_visit/domain/usecases/schedule_visit.dart';
import '../../features/schedule_visit/presentation/bloc/schedule_visit_bloc.dart';

// Maintenance requests feature
import '../../features/maintenance_requests/data/datasources/maintenance_local_data_source.dart';
import '../../features/maintenance_requests/data/datasources/maintenance_remote_data_source.dart';
import '../../features/maintenance_requests/data/repositories/maintenance_repository_impl.dart';
import '../../features/maintenance_requests/domain/repositories/maintenance_repository.dart';
import '../../features/maintenance_requests/domain/usecases/get_maintenance_history.dart';
import '../../features/maintenance_requests/domain/usecases/raise_maintenance_request.dart';
import '../../features/maintenance_requests/presentation/bloc/maintenance_requests_bloc.dart';

// Rent receipts feature
import '../../features/rent_receipts/data/datasources/rent_receipts_local_data_source.dart';
import '../../features/rent_receipts/data/datasources/rent_receipts_remote_data_source.dart';
import '../../features/rent_receipts/data/repositories/rent_receipts_repository_impl.dart';
import '../../features/rent_receipts/domain/repositories/rent_receipts_repository.dart';
import '../../features/rent_receipts/domain/usecases/download_rent_receipt.dart';
import '../../features/rent_receipts/domain/usecases/get_rent_receipts.dart';
import '../../features/rent_receipts/presentation/bloc/rent_receipts_bloc.dart';

// Saved listings feature
import '../../features/saved_listings/data/datasources/saved_listings_local_data_source.dart';
import '../../features/saved_listings/data/datasources/saved_listings_remote_data_source.dart';
import '../../features/saved_listings/data/repositories/saved_listings_repository_impl.dart';
import '../../features/saved_listings/domain/repositories/saved_listings_repository.dart';
import '../../features/saved_listings/domain/usecases/get_saved_listings.dart';
import '../../features/saved_listings/domain/usecases/remove_saved_listing.dart';
import '../../features/saved_listings/presentation/bloc/saved_listings_bloc.dart';

// Owner dashboard feature
import '../../features/owner_dashboard/data/datasources/owner_dashboard_remote_data_source.dart';
import '../../features/owner_dashboard/data/repositories/owner_dashboard_repository_impl.dart';
import '../../features/owner_dashboard/domain/repositories/owner_dashboard_repository.dart';
import '../../features/owner_dashboard/domain/usecases/boost_owner_listing.dart';
import '../../features/owner_dashboard/domain/usecases/get_owner_analytics.dart';
import '../../features/owner_dashboard/domain/usecases/get_owner_interests.dart';
import '../../features/owner_dashboard/domain/usecases/get_owner_listings.dart';
import '../../features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart';

// Profile feature
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/get_site_visits.dart';
import '../../features/profile/domain/usecases/submit_kyc_documents.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

// Role selection feature
import '../../features/role_selection/data/datasources/role_selection_local_data_source.dart';
import '../../features/role_selection/data/repositories/role_selection_repository_impl.dart';
import '../../features/role_selection/domain/repositories/role_selection_repository.dart';
import '../../features/role_selection/domain/usecases/save_selected_role.dart';
import '../../features/role_selection/presentation/bloc/role_selection_bloc.dart';

// Register feature
import '../../features/register/data/datasources/register_remote_data_source.dart';
import '../../features/register/data/repositories/register_repository_impl.dart';
import '../../features/register/domain/repositories/register_repository.dart';
import '../../features/register/domain/usecases/register_user_usecase.dart';
import '../../features/register/presentation/bloc/register_bloc.dart';

// OTP feature
import '../../features/otp/data/datasources/otp_remote_data_source.dart';
import '../../features/otp/data/repositories/otp_repository_impl.dart';
import '../../features/otp/domain/repositories/otp_repository.dart';
import '../../features/otp/domain/usecases/verify_otp_usecase.dart';
import '../../features/otp/domain/usecases/resend_otp_usecase.dart';
import '../../features/otp/presentation/bloc/otp_bloc.dart';

// Theme
import '../theme/theme_cubit.dart';

// Feature selection feature
import '../../features/feature_selection/data/datasources/feature_local_data_source.dart';
import '../../features/feature_selection/data/repositories/feature_repository_impl.dart';
import '../../features/feature_selection/domain/repositories/feature_repository.dart';
import '../../features/feature_selection/domain/usecases/get_features.dart';
import '../../features/feature_selection/domain/usecases/toggle_feature.dart';
import '../../features/feature_selection/domain/usecases/save_features.dart';
import '../../features/feature_selection/presentation/bloc/feature_selection_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── External ─────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerLazySingleton<Dio>(() => ApiClient.create(sharedPreferences: sl()));

  // ─── Splash ───────────────────────────────────────────────────────────────
  sl.registerFactory(() => SplashBloc(
        checkAuthStatus: sl(),
        checkOnboardingStatus: sl(),
      ));

  // ─── Auth ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => LoginBloc(
        login: sl(),
        logout: sl(),
        sendOtp: sl(),
        loginWithGoogle: sl(),
      ));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => LoginWithGoogle(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // ─── Onboarding ───────────────────────────────────────────────────────────
  sl.registerFactory(() => OnboardingBloc(
        getOnboardingSlides: sl(),
        markOnboardingComplete: sl(),
        checkOnboardingStatus: sl(),
      ));
  sl.registerLazySingleton(() => GetOnboardingSlides(sl()));
  sl.registerLazySingleton(() => MarkOnboardingComplete(sl()));
  sl.registerLazySingleton(() => CheckOnboardingStatus(sl()));
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ─── Search Result ────────────────────────────────────────────────────────
  sl.registerFactory(() => SearchResultBloc(searchListings: sl()));

  // ─── Saved Searches ──────────────────────────────────────────────────────
  sl.registerFactory(() => SavedSearchesBloc(
        getSavedSearches: sl(),
        saveSavedSearch: sl(),
        removeSavedSearch: sl(),
      ));
  sl.registerLazySingleton(() => GetSavedSearches(sl()));
  sl.registerLazySingleton(() => SaveSavedSearch(sl()));
  sl.registerLazySingleton(() => RemoveSavedSearch(sl()));
  sl.registerLazySingleton<SavedSearchesRepository>(
    () => SavedSearchesRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<SavedSearchesRemoteDataSource>(
    () => SavedSearchesRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<SavedSearchesLocalDataSource>(
    () => SavedSearchesLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ─── Home ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => HomeBloc(
        getFeaturedListings: sl(),
        getRecommendedListings: sl(),
        searchListings: sl(),
        getSearchSuggestions: sl(),
      ));
  sl.registerLazySingleton(() => GetFeaturedListings(sl()));
  sl.registerLazySingleton(() => GetRecommendedListings(sl()));
  sl.registerLazySingleton(() => SearchListings(sl()));
  sl.registerLazySingleton(() => GetSearchSuggestions(sl()));
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: sl()),
  );

  // ─── Property Details ────────────────────────────────────────────────────
  sl.registerFactory(() => PropertyDetailsBloc(repository: sl()));
  sl.registerLazySingleton<PropertyDetailsRepository>(
    () => PropertyDetailsRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<PropertyDetailsLocalDataSource>(
    () => PropertyDetailsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<PropertyDetailsRemoteDataSource>(
    () => PropertyDetailsRemoteDataSourceImpl(dio: sl()),
  );

  // ─── Reviews ────────────────────────────────────────────────────────────
  sl.registerFactory(() => ReviewsBloc(
        getPropertyReviews: sl(),
        submitReview: sl(),
      ));
  sl.registerLazySingleton(() => GetPropertyReviews(sl()));
  sl.registerLazySingleton(() => SubmitReview(sl()));
  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ReviewsRemoteDataSource>(
    () => ReviewsRemoteDataSourceImpl(dio: sl()),
  );

  // ─── Schedule Visit ─────────────────────────────────────────────────────
  sl.registerFactory(() => ScheduleVisitBloc(scheduleVisit: sl()));
  sl.registerLazySingleton(() => ScheduleVisit(sl()));
  sl.registerLazySingleton<ScheduleVisitRepository>(
    () => ScheduleVisitRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ScheduleVisitRemoteDataSource>(
    () => ScheduleVisitRemoteDataSourceImpl(dio: sl()),
  );

  // ─── Maintenance Requests ────────────────────────────────────────────────
  sl.registerFactory(() => MaintenanceRequestsBloc(
        getMaintenanceHistory: sl(),
        raiseMaintenanceRequest: sl(),
      ));
  sl.registerLazySingleton(() => GetMaintenanceHistory(sl()));
  sl.registerLazySingleton(() => RaiseMaintenanceRequest(sl()));
  sl.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<MaintenanceRemoteDataSource>(
    () => MaintenanceRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<MaintenanceLocalDataSource>(
    () => MaintenanceLocalDataSourceImpl(),
  );

  // ─── Rent Receipts ───────────────────────────────────────────────────────
  sl.registerFactory(() => RentReceiptsBloc(
        getRentReceipts: sl(),
        downloadRentReceipt: sl(),
      ));
  sl.registerLazySingleton(() => GetRentReceipts(sl()));
  sl.registerLazySingleton(() => DownloadRentReceipt(sl()));
  sl.registerLazySingleton<RentReceiptsRepository>(
    () => RentReceiptsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<RentReceiptsRemoteDataSource>(
    () => RentReceiptsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RentReceiptsLocalDataSource>(
    () => RentReceiptsLocalDataSourceImpl(),
  );

  // ─── Saved Listings ─────────────────────────────────────────────────────
  sl.registerFactory(() => SavedListingsBloc(
        getSavedListings: sl(),
        removeSavedListing: sl(),
      ));
  sl.registerLazySingleton(() => GetSavedListings(sl()));
  sl.registerLazySingleton(() => RemoveSavedListing(sl()));
  sl.registerLazySingleton<SavedListingsRepository>(
    () => SavedListingsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<SavedListingsRemoteDataSource>(
    () => SavedListingsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<SavedListingsLocalDataSource>(
    () => SavedListingsLocalDataSourceImpl(),
  );

  // ─── Owner Dashboard ────────────────────────────────────────────────────
  sl.registerFactory(() => OwnerDashboardBloc(
        getOwnerListings: sl(),
        getOwnerInterests: sl(),
        getOwnerAnalytics: sl(),
        boostOwnerListing: sl(),
      ));
  sl.registerLazySingleton(() => GetOwnerListings(sl()));
  sl.registerLazySingleton(() => GetOwnerInterests(sl()));
  sl.registerLazySingleton(() => GetOwnerAnalytics(sl()));
  sl.registerLazySingleton(() => BoostOwnerListing(sl()));
  sl.registerLazySingleton<OwnerDashboardRepository>(
    () => OwnerDashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OwnerDashboardRemoteDataSource>(
    () => OwnerDashboardRemoteDataSourceImpl(dio: sl()),
  );

  // ─── Profile ─────────────────────────────────────────────────────────────
  sl.registerFactory(() => ProfileBloc(
        getProfile: sl(),
        updateProfile: sl(),
        submitKycDocuments: sl(),
        getSiteVisits: sl(),
      ));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => SubmitKycDocuments(sl()));
  sl.registerLazySingleton(() => GetSiteVisits(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(),
  );

  // ─── Role Selection ───────────────────────────────────────────────────────
  sl.registerFactory(() => RoleSelectionBloc(saveSelectedRole: sl()));
  sl.registerLazySingleton(() => SaveSelectedRole(sl()));
  sl.registerLazySingleton<RoleSelectionRepository>(
    () => RoleSelectionRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<RoleSelectionLocalDataSource>(
    () => RoleSelectionLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ─── Register ─────────────────────────────────────────────────────────────
  sl.registerFactory(() => RegisterBloc(registerUser: sl()));
  sl.registerLazySingleton(() => RegisterUserUsecase(sl()));
  sl.registerLazySingleton<RegisterRepository>(
    () => RegisterRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RegisterRemoteDataSource>(
    () => RegisterRemoteDataSourceImpl(dio: sl()),
  );

  // ─── OTP ──────────────────────────────────────────────────────────────────
  sl.registerFactory(() => OtpBloc(verifyOtp: sl(), resendOtp: sl()));
  sl.registerLazySingleton(() => VerifyOtpUsecase(sl()));
  sl.registerLazySingleton(() => ResendOtpUsecase(sl()));
  sl.registerLazySingleton<OtpRepository>(
    () => OtpRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<OtpRemoteDataSource>(
    () => OtpRemoteDataSourceImpl(dio: sl()),
  );

  // ─── Theme ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ThemeCubit(sharedPreferences: sl()));

  // ─── Feature Selection ────────────────────────────────────────────────────
  sl.registerFactory(() => FeatureSelectionBloc(
        getFeatures: sl(),
        toggleFeature: sl(),
        saveFeatures: sl(),
      ));
  sl.registerLazySingleton(() => GetFeatures(sl()));
  sl.registerLazySingleton(() => ToggleFeature(sl()));
  sl.registerLazySingleton(() => SaveFeatures(sl()));
  sl.registerLazySingleton<FeatureRepository>(
    () => FeatureRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<FeatureLocalDataSource>(
    () => FeatureLocalDataSourceImpl(sharedPreferences: sl()),
  );
}
