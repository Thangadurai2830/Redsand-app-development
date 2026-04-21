import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../property_details/presentation/pages/property_details_page.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../../domain/entities/saved_listing_entity.dart';
import '../bloc/saved_listings_bloc.dart';
import '../bloc/saved_listings_event.dart';
import '../bloc/saved_listings_state.dart';
import 'compare/saved_listings_compare_page.dart';

class SavedListingsPage extends StatelessWidget {
  const SavedListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SavedListingsBloc>()..add(const SavedListingsLoadRequested()),
      child: const _SavedListingsView(),
    );
  }
}

class _SavedListingsView extends StatelessWidget {
  const _SavedListingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavedListingsBloc, SavedListingsState>(
      listenWhen: (previous, current) => previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
          context.read<SavedListingsBloc>().add(const SavedListingsClearMessageRequested());
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
                const Text('Saved Listings'),
                Text(
                  '${state.listings.length} properties saved',
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
                icon: const Icon(Icons.refresh),
                onPressed: state.status == SavedListingsStatus.loading
                    ? null
                    : () => context.read<SavedListingsBloc>().add(const SavedListingsRefreshRequested()),
              ),
            ],
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: state.canCompare
              ? SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _CompareBar(
                    count: state.selectedIds.length,
                    onClear: () => context.read<SavedListingsBloc>().add(const SavedListingsClearSelectionRequested()),
                    onCompare: () {
                      final selected = state.selectedListings;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SavedListingsComparePage(listings: selected),
                        ),
                      );
                    },
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SavedListingsState state) {
    if (state.status == SavedListingsStatus.loading || state.status == SavedListingsStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mainPurple),
      );
    }

    if (state.status == SavedListingsStatus.failure && state.listings.isEmpty) {
      return _EmptyState(
        icon: Icons.error_outline,
        title: 'Unable to load saved listings',
        subtitle: state.message ?? 'Please try again in a moment.',
        actionLabel: 'Retry',
        onAction: () => context.read<SavedListingsBloc>().add(const SavedListingsLoadRequested()),
      );
    }

    if (state.listings.isEmpty) {
      return _EmptyState(
        icon: Icons.bookmark_outline,
        title: 'No saved listings yet',
        subtitle: 'Tap the bookmark button on any property to keep it here.',
        actionLabel: 'Browse homes',
        onAction: () => Navigator.of(context).pop(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<SavedListingsBloc>().add(const SavedListingsRefreshRequested()),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: state.listings.length,
        itemBuilder: (context, index) {
          final entry = state.listings[index];
          final removing = state.removingIds.contains(entry.listing.id);
          final selected = state.selectedIds.contains(entry.listing.id);
          return Padding(
            padding: EdgeInsets.only(bottom: index == state.listings.length - 1 ? 0 : 12),
            child: SavedListingCard(
              entry: entry,
              selected: selected,
              removing: removing,
              onToggleSelected: () => context
                  .read<SavedListingsBloc>()
                  .add(SavedListingsToggleSelectionRequested(entry.listing.id)),
              onRemove: () => context
                  .read<SavedListingsBloc>()
                  .add(SavedListingsRemoveRequested(entry.listing.id)),
              onOpenDetails: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PropertyDetailsPage(listing: entry.listing),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SavedListingCard extends StatelessWidget {
  final SavedListingEntity entry;
  final bool selected;
  final bool removing;
  final VoidCallback onToggleSelected;
  final VoidCallback onRemove;
  final VoidCallback onOpenDetails;

  const SavedListingCard({
    super.key,
    required this.entry,
    required this.selected,
    required this.removing,
    required this.onToggleSelected,
    required this.onRemove,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final listing = entry.listing;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpenDetails,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.mainPurple : AppColors.borderGray,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ListingThumbnail(listing: listing),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDarkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: onToggleSelected,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.mainPurple : AppColors.veryLightPurpleBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              selected ? Icons.check : Icons.add,
                              size: 16,
                              color: selected ? AppColors.white : AppColors.mainPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${listing.locality}, ${listing.city}',
                      style: const TextStyle(
                        color: AppColors.secondaryGrayText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          icon: Icons.king_bed_outlined,
                          text: '${listing.bedrooms} BHK',
                        ),
                        _Pill(
                          icon: Icons.square_foot,
                          text: '${listing.areaSqft.toInt()} sqft',
                        ),
                        _Pill(
                          icon: listing.listingFor == 'rent' ? Icons.home_work_outlined : Icons.sell_outlined,
                          text: listing.listingFor.toUpperCase(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          _priceLabel(listing),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.mainPurple,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _savedLabel(entry.savedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryGrayText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: removing ? null : onRemove,
                            icon: removing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.bookmark_remove_outlined, size: 18),
                            label: const Text('Remove'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondaryGrayText,
                              side: const BorderSide(color: AppColors.borderGray),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onOpenDetails,
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('Open'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.deepRoyalPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _priceLabel(ListingEntity listing) {
    if (listing.listingFor == 'rent') {
      return '₹${listing.price.toInt()}/mo';
    }
    if (listing.price >= 10000000) {
      return '₹${(listing.price / 10000000).toStringAsFixed(1)} Cr';
    }
    return '₹${(listing.price / 100000).toStringAsFixed(1)} L';
  }

  String _savedLabel(DateTime? savedAt) {
    if (savedAt == null) return 'Recently saved';
    final days = DateTime.now().difference(savedAt).inDays;
    if (days <= 0) return 'Saved today';
    if (days == 1) return 'Saved 1 day ago';
    return 'Saved $days days ago';
  }
}

class _ListingThumbnail extends StatelessWidget {
  final ListingEntity listing;

  const _ListingThumbnail({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 122,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.softLavender,
            AppColors.cyanBlue.withOpacity(0.95),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: listing.imageUrl.isNotEmpty
            ? Image.network(
                listing.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _PlaceholderThumb(),
              )
            : const _PlaceholderThumb(),
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: const Center(
        child: Icon(Icons.home_rounded, color: AppColors.white, size: 36),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Pill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondaryGrayText),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryGrayText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareBar extends StatelessWidget {
  final int count;
  final VoidCallback onClear;
  final VoidCallback onCompare;

  const _CompareBar({
    required this.count,
    required this.onClear,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.deepRoyalPurple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count listings selected for comparison',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text('Clear'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onCompare,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.deepRoyalPurple,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('Compare'),
          ),
        ],
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.veryLightPurpleBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 40, color: AppColors.mainPurple),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
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
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepRoyalPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
