import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../models/app_feature_model.dart';
import '../../domain/entities/app_feature.dart';

abstract class FeatureLocalDataSource {
  Future<List<AppFeatureModel>> getFeatures();
  Future<AppFeatureModel> toggleFeature(String featureId, bool isEnabled);
  Future<void> saveFeatures(List<AppFeature> features);
}

const _kFeaturesKey = 'app_features';

class FeatureLocalDataSourceImpl implements FeatureLocalDataSource {
  final SharedPreferences sharedPreferences;

  FeatureLocalDataSourceImpl({required this.sharedPreferences});

  static List<AppFeatureModel> get _defaultFeatures => [
        const AppFeatureModel(
          id: 'analytics',
          name: 'Analytics',
          description: 'Track usage and performance metrics',
          category: FeatureCategory.analytics,
          isEnabled: true,
        ),
        const AppFeatureModel(
          id: 'dark_mode',
          name: 'Dark Mode',
          description: 'Switch to a darker color scheme',
          category: FeatureCategory.settings,
          isEnabled: false,
        ),
        const AppFeatureModel(
          id: 'notifications',
          name: 'Push Notifications',
          description: 'Receive real-time alerts and updates',
          category: FeatureCategory.communication,
          isEnabled: true,
        ),
        const AppFeatureModel(
          id: 'export',
          name: 'Data Export',
          description: 'Export your data in CSV or PDF format',
          category: FeatureCategory.productivity,
          isEnabled: false,
        ),
        const AppFeatureModel(
          id: 'advanced_reports',
          name: 'Advanced Reports',
          description: 'Generate detailed analytical reports',
          category: FeatureCategory.analytics,
          isEnabled: false,
          requiresAdmin: true,
        ),
        const AppFeatureModel(
          id: 'user_management',
          name: 'User Management',
          description: 'Add, edit and remove user accounts',
          category: FeatureCategory.settings,
          isEnabled: true,
          requiresAdmin: true,
        ),
        const AppFeatureModel(
          id: 'calendar',
          name: 'Calendar Sync',
          description: 'Sync events with your calendar app',
          category: FeatureCategory.productivity,
          isEnabled: false,
        ),
        const AppFeatureModel(
          id: 'chat',
          name: 'In-App Chat',
          description: 'Chat with team members directly',
          category: FeatureCategory.communication,
          isEnabled: true,
        ),
      ];

  @override
  Future<List<AppFeatureModel>> getFeatures() async {
    final json = sharedPreferences.getString(_kFeaturesKey);
    if (json == null) return _defaultFeatures;
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((e) => AppFeatureModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AppFeatureModel> toggleFeature(String featureId, bool isEnabled) async {
    final features = await getFeatures();
    final index = features.indexWhere((f) => f.id == featureId);
    if (index == -1) throw CacheFailure();
    final updated = AppFeatureModel(
      id: features[index].id,
      name: features[index].name,
      description: features[index].description,
      category: features[index].category,
      isEnabled: isEnabled,
      requiresAdmin: features[index].requiresAdmin,
    );
    final updatedList = [...features];
    updatedList[index] = updated;
    await saveFeatures(updatedList);
    return updated;
  }

  @override
  Future<void> saveFeatures(List<AppFeature> features) async {
    final models = features.map(AppFeatureModel.fromEntity).toList();
    final encoded = jsonEncode(models.map((m) => m.toJson()).toList());
    await sharedPreferences.setString(_kFeaturesKey, encoded);
  }
}
