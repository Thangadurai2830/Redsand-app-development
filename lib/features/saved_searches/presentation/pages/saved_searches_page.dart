import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../search_result/presentation/pages/search_result_page.dart';
import '../../domain/entities/saved_search_alert.dart';
import '../bloc/saved_searches_bloc.dart';
import '../bloc/saved_searches_event.dart';
import '../bloc/saved_searches_state.dart';

class SavedSearchesPage extends StatelessWidget {
  const SavedSearchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SavedSearchesBloc>()..add(const SavedSearchesLoadRequested()),
      child: const _SavedSearchesView(),
    );
  }
}

class _SavedSearchesView extends StatelessWidget {
  const _SavedSearchesView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavedSearchesBloc, SavedSearchesState>(
      listenWhen: (previous, current) => previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
          context.read<SavedSearchesBloc>().add(const SavedSearchesClearMessageRequested());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightGrayBg,
          appBar: AppBar(
            backgroundColor: AppColors.deepRoyalPurple,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saved Search Alerts'),
                Text(
                  '${state.searches.length} alert${state.searches.length == 1 ? '' : 's'} configured',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: state.status == SavedSearchesStatus.loading
                    ? null
                    : () => context.read<SavedSearchesBloc>().add(const SavedSearchesRefreshRequested()),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SavedSearchesState state) {
    if (state.status == SavedSearchesStatus.loading || state.status == SavedSearchesStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mainPurple),
      );
    }

    if (state.status == SavedSearchesStatus.failure && state.searches.isEmpty) {
      return _EmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'Unable to load saved searches',
        subtitle: state.message ?? 'Please try again in a moment.',
        actionLabel: 'Retry',
        onAction: () => context.read<SavedSearchesBloc>().add(const SavedSearchesLoadRequested()),
      );
    }

    if (state.searches.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_outlined,
        title: 'No saved search alerts yet',
        subtitle: 'Save a search from the results screen to get push and in-app alerts.',
        actionLabel: 'Browse homes',
        onAction: () => Navigator.of(context).pop(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<SavedSearchesBloc>().add(const SavedSearchesRefreshRequested()),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _OverviewCard(state: state),
          const SizedBox(height: 16),
          ...state.searches.map(
            (search) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SavedSearchCard(
                search: search,
                removing: state.removingIds.contains(search.id),
                onRemove: () => context.read<SavedSearchesBloc>().add(SavedSearchesRemoveRequested(search.id)),
                onOpenSearch: () => _openSearch(context, search),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context, SavedSearchAlert search) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultPage(
          query: search.query,
          initialFilter: search.filter,
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final SavedSearchesState state;

  const _OverviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepRoyalPurple, AppColors.mainPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay ahead of new inventory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.pushEnabledCount} push, ${state.inAppEnabledCount} in-app, ${state.priceDropAlertCount} price-drop alerts',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedSearchCard extends StatelessWidget {
  final SavedSearchAlert search;
  final bool removing;
  final VoidCallback onRemove;
  final VoidCallback onOpenSearch;

  const _SavedSearchCard({
    required this.search,
    required this.removing,
    required this.onRemove,
    required this.onOpenSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpenSearch,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.veryLightPurpleBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.manage_search_outlined, color: AppColors.mainPurple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          search.searchLabel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primaryDarkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitle,
                          style: const TextStyle(
                            color: AppColors.secondaryGrayText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: removing ? null : onRemove,
                    icon: removing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mainPurple),
                          )
                        : const Icon(Icons.delete_outline, color: AppColors.secondaryGrayText),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(text: search.filter.listingFor == 'buy' ? 'Buy' : 'Rent'),
                  if (search.filter.propertyType != null)
                    _Chip(text: search.filter.propertyType!.toUpperCase()),
                  if (search.filter.city != null && search.filter.city!.trim().isNotEmpty)
                    _Chip(text: search.filter.city!.trim()),
                  if (search.filter.locality != null && search.filter.locality!.trim().isNotEmpty)
                    _Chip(text: search.filter.locality!.trim()),
                  if (search.filter.minBedrooms != null) _Chip(text: '${search.filter.minBedrooms} BHK'),
                  _Chip(text: search.notifyByPush ? 'Push' : 'No push'),
                  _Chip(text: search.notifyInApp ? 'In-app' : 'No in-app'),
                  if (search.priceDropAlert) _Chip(text: 'Price drop'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (search.newMatchCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mintGreen.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${search.newMatchCount} new match${search.newMatchCount == 1 ? '' : 'es'}',
                        style: const TextStyle(
                          color: AppColors.mintGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _savedAtLabel,
                    style: const TextStyle(
                      color: AppColors.secondaryGrayText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    final parts = <String>[];
    if (search.filter.minPrice != null || search.filter.maxPrice != null) {
      parts.add(_priceRange(search.filter.minPrice, search.filter.maxPrice));
    }
    if (search.filter.minBedrooms != null) {
      parts.add('${search.filter.minBedrooms} BHK');
    }
    if (search.filter.sortBy != 'newest') {
      parts.add(search.filter.sortBy == 'price_desc' ? 'Price: High to Low' : 'Price: Low to High');
    }
    if (parts.isEmpty) {
      parts.add('Alerts for matching inventory');
    }
    return parts.join(' • ');
  }

  String get _savedAtLabel {
    final now = DateTime.now();
    final diff = now.difference(search.savedAt);
    if (diff.inDays <= 0) return 'Saved today';
    if (diff.inDays == 1) return 'Saved yesterday';
    return 'Saved ${diff.inDays} days ago';
  }

  String _priceRange(double? min, double? max) {
    String format(double value) {
      if (value >= 10000000) return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
      if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(0)}L';
      if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(0)}K';
      return '₹${value.toInt()}';
    }

    if (min != null && max != null) return '${format(min)} - ${format(max)}';
    if (min != null) return 'From ${format(min)}';
    if (max != null) return 'Up to ${format(max)}';
    return 'Budget';
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryDarkText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.mainPurple),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryGrayText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepRoyalPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
