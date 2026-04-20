import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../models/onboarding_slide_model.dart';

abstract class OnboardingLocalDataSource {
  Future<List<OnboardingSlideModel>> getCachedSlides();
  Future<void> cacheSlides(List<OnboardingSlideModel> slides);
  Future<void> setOnboardingComplete();
  Future<bool> isOnboardingComplete();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const _slidesKey = 'CACHED_ONBOARDING_SLIDES';
  static const _doneKey = 'ONBOARDING_COMPLETE';

  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<OnboardingSlideModel>> getCachedSlides() async {
    final json = sharedPreferences.getString(_slidesKey);
    if (json == null) throw CacheFailure();
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => OnboardingSlideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheSlides(List<OnboardingSlideModel> slides) async {
    final json = jsonEncode(slides.map((s) => s.toJson()).toList());
    await sharedPreferences.setString(_slidesKey, json);
  }

  @override
  Future<void> setOnboardingComplete() =>
      sharedPreferences.setBool(_doneKey, true);

  @override
  Future<bool> isOnboardingComplete() async =>
      sharedPreferences.getBool(_doneKey) ?? false;
}
