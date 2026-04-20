import '../../domain/entities/app_feature.dart';

class AppFeatureModel extends AppFeature {
  const AppFeatureModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.isEnabled,
    super.requiresAdmin,
  });

  factory AppFeatureModel.fromJson(Map<String, dynamic> json) => AppFeatureModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        category: FeatureCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => FeatureCategory.productivity,
        ),
        isEnabled: json['is_enabled'] as bool,
        requiresAdmin: json['requires_admin'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category.name,
        'is_enabled': isEnabled,
        'requires_admin': requiresAdmin,
      };

  factory AppFeatureModel.fromEntity(AppFeature entity) => AppFeatureModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        category: entity.category,
        isEnabled: entity.isEnabled,
        requiresAdmin: entity.requiresAdmin,
      );
}
