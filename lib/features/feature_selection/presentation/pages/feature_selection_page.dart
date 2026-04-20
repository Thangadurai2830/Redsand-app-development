import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/app_feature.dart';
import '../bloc/feature_selection_bloc.dart';

class FeatureSelectionPage extends StatelessWidget {
  const FeatureSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<FeatureSelectionBloc>()..add(const LoadFeatures()),
      child: const _FeatureSelectionView(),
    );
  }
}

class _FeatureSelectionView extends StatelessWidget {
  const _FeatureSelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Selection'),
        backgroundColor: AppColors.deepRoyalPurple,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<FeatureSelectionBloc, FeatureSelectionState>(
            builder: (context, state) {
              if (state is FeatureSelectionLoaded) {
                return state.isSaving
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.save_rounded),
                        tooltip: 'Save',
                        onPressed: () =>
                            context.read<FeatureSelectionBloc>().add(const SaveFeaturesEvent()),
                      );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<FeatureSelectionBloc, FeatureSelectionState>(
        listener: (context, state) {
          if (state is FeatureSelectionLoaded && state.savedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Features saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is FeatureSelectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is FeatureSelectionLoading || state is FeatureSelectionInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FeatureSelectionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FeatureSelectionBloc>().add(const LoadFeatures()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is FeatureSelectionLoaded) {
            return _FeatureList(features: state.features);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  final List<AppFeature> features;

  const _FeatureList({required this.features});

  @override
  Widget build(BuildContext context) {
    final grouped = <FeatureCategory, List<AppFeature>>{};
    for (final f in features) {
      grouped.putIfAbsent(f.category, () => []).add(f);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: grouped.entries.map((entry) {
        return _CategorySection(category: entry.key, features: entry.value);
      }).toList(),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final FeatureCategory category;
  final List<AppFeature> features;

  const _CategorySection({required this.category, required this.features});

  String get _categoryLabel => switch (category) {
        FeatureCategory.productivity => 'Productivity',
        FeatureCategory.analytics => 'Analytics',
        FeatureCategory.settings => 'Settings',
        FeatureCategory.communication => 'Communication',
      };

  IconData get _categoryIcon => switch (category) {
        FeatureCategory.productivity => Icons.work_outline,
        FeatureCategory.analytics => Icons.bar_chart,
        FeatureCategory.settings => Icons.settings_outlined,
        FeatureCategory.communication => Icons.chat_bubble_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Icon(_categoryIcon, size: 18, color: AppColors.deepRoyalPurple),
              const SizedBox(width: 8),
              Text(
                _categoryLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.deepRoyalPurple,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
        ),
        ...features.map((f) => _FeatureTile(feature: f)),
        const Divider(height: 1),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final AppFeature feature;

  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: feature.isEnabled,
      onChanged: (value) {
        context.read<FeatureSelectionBloc>().add(
              ToggleFeatureEvent(featureId: feature.id, isEnabled: value),
            );
      },
      title: Row(
        children: [
          Text(feature.name),
          if (feature.requiresAdmin) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.deepRoyalPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Admin',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.deepRoyalPurple,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        feature.description,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
      ),
      activeColor: AppColors.deepRoyalPurple,
    );
  }
}
