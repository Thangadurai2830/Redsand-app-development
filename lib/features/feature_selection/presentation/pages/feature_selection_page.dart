import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/theme_cubit.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Selection'),
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
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.save_rounded),
                        tooltip: 'Save',
                        onPressed: () => context
                            .read<FeatureSelectionBloc>()
                            .add(const SaveFeaturesEvent()),
                      );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<FeatureSelectionBloc, FeatureSelectionState>(
        listener: (context, state) {
          if (state is FeatureSelectionLoaded) {
            final darkFeature =
                state.features.where((f) => f.id == 'dark_mode').firstOrNull;
            if (darkFeature != null) {
              context.read<ThemeCubit>().setDarkMode(darkFeature.isEnabled);
            }
            if (state.savedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Features saved successfully'),
                  backgroundColor: colorScheme.primary,
                ),
              );
            }
          }
          if (state is FeatureSelectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is FeatureSelectionLoading ||
              state is FeatureSelectionInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FeatureSelectionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<FeatureSelectionBloc>()
                        .add(const LoadFeatures()),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Icon(_categoryIcon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                _categoryLabel,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                color: colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Admin',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        feature.description,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      activeColor: colorScheme.primary,
      activeTrackColor: colorScheme.primary.withOpacity(0.4),
    );
  }
}
