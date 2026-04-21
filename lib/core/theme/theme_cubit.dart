import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFeaturesKey = 'app_features';
const _darkModeFeatureId = 'dark_mode';

class ThemeCubit extends Cubit<bool> {
  final SharedPreferences sharedPreferences;

  ThemeCubit({required this.sharedPreferences}) : super(_loadInitialState(sharedPreferences));

  static bool _loadInitialState(SharedPreferences prefs) {
    final json = prefs.getString(_kFeaturesKey);
    if (json == null) return false;
    try {
      final List<dynamic> decoded = jsonDecode(json) as List<dynamic>;
      final feature = decoded.firstWhere(
        (e) => e['id'] == _darkModeFeatureId,
        orElse: () => null,
      );
      return feature?['isEnabled'] == true;
    } catch (_) {
      return false;
    }
  }

  void setDarkMode(bool isDark) => emit(isDark);
}
