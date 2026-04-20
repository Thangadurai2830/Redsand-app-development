import 'package:equatable/equatable.dart';

enum FeatureCategory { productivity, analytics, settings, communication }

class AppFeature extends Equatable {
  final String id;
  final String name;
  final String description;
  final FeatureCategory category;
  final bool isEnabled;
  final bool requiresAdmin;

  const AppFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isEnabled,
    this.requiresAdmin = false,
  });

  AppFeature copyWith({bool? isEnabled}) => AppFeature(
        id: id,
        name: name,
        description: description,
        category: category,
        isEnabled: isEnabled ?? this.isEnabled,
        requiresAdmin: requiresAdmin,
      );

  @override
  List<Object?> get props => [id, name, description, category, isEnabled, requiresAdmin];
}
