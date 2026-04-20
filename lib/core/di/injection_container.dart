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

// Home feature
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

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
  sl.registerLazySingleton<Dio>(() => ApiClient.create());

  // ─── Splash ───────────────────────────────────────────────────────────────
  sl.registerFactory(() => SplashBloc(
        checkAuthStatus: sl(),
        checkOnboardingStatus: sl(),
      ));

  // ─── Auth ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => LoginBloc(
        login: sl(),
        sendOtp: sl(),
        loginWithGoogle: sl(),
      ));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => Login(sl()));
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
