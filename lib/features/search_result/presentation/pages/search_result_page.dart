import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../filter/domain/entities/filter_entity.dart';
import '../../../filter/presentation/pages/filter_page.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../../../property_details/presentation/pages/property_details_page.dart';
import '../../../saved_searches/presentation/bloc/saved_searches_bloc.dart';
import '../../../saved_searches/presentation/bloc/saved_searches_event.dart';
import '../../../saved_searches/presentation/bloc/saved_searches_state.dart';
import '../../../saved_searches/presentation/widgets/saved_search_save_sheet.dart';
import '../../presentation/bloc/search_result_bloc.dart';
import '../../presentation/bloc/search_result_event.dart';
import '../../presentation/bloc/search_result_state.dart';
import '../../../map/presentation/pages/map_page.dart';

class SearchResultPage extends StatelessWidget {
  final String query;
  final FilterEntity initialFilter;

  const SearchResultPage({
    super.key,
    required this.query,
    required this.initialFilter,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<SearchResultBloc>()
            ..add(SearchResultLoad(query: query, filter: initialFilter)),
        ),
        BlocProvider(create: (_) => sl<SavedSearchesBloc>()),
      ],
      child: _SearchResultView(query: query, initialFilter: initialFilter),
    );
  }
}

class _SearchResultView extends StatelessWidget {
  final String query;
  final FilterEntity initialFilter;

  const _SearchResultView({
    required this.query,
    required this.initialFilter,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavedSearchesBloc, SavedSearchesState>(
      listenWhen: (previous, current) => previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
          context.read<SavedSearchesBloc>().add(const SavedSearchesClearMessageRequested());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBg,
        appBar: _buildAppBar(context),
        body: BlocBuilder<SearchResultBloc, SearchResultState>(
          builder: (context, state) {
            if (state is SearchResultLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.mainPurple),
              );
            }
            if (state is SearchResultError) {
              return _ErrorView(message: state.message);
            }
            if (state is SearchResultLoaded) {
              return _LoadedView(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkText),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            query.isEmpty ? 'Search Results' : '"$query"',
            style: const TextStyle(
              color: AppColors.primaryDarkText,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          BlocBuilder<SearchResultBloc, SearchResultState>(
            builder: (context, state) {
              if (state is SearchResultLoaded) {
                return Text(
                  '${state.listings.length} properties found',
                  style: const TextStyle(
                    color: AppColors.secondaryGrayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      actions: [
        BlocBuilder<SearchResultBloc, SearchResultState>(
          builder: (context, state) {
            final filter = state is SearchResultLoaded ? state.filter : const FilterEntity();
            final hasFilters = filter.hasActiveFilters;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.tune, color: AppColors.primaryDarkText),
                  onPressed: () => _openFilter(context, filter),
                ),
                if (hasFilters)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.mainPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryDarkText),
          onPressed: () => _openSaveSheet(context),
        ),
        IconButton(
          icon: const Icon(Icons.map_outlined, color: AppColors.primaryDarkText),
          onPressed: () => _openMap(context),
        ),
      ],
    );
  }

  void _openFilter(BuildContext context, FilterEntity filter) async {
    final result = await Navigator.of(context).push<FilterEntity>(
      MaterialPageRoute(
        builder: (_) => FilterPage(initialFilter: filter),
        fullscreenDialog: true,
      ),
    );
    if (result != null && context.mounted) {
      context.read<SearchResultBloc>().add(SearchResultFilterChanged(result));
    }
  }

  void _openMap(BuildContext context) {
    final state = context.read<SearchResultBloc>().state;
    final listings = state is SearchResultLoaded ? state.sorted : <ListingEntity>[];
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MapPage(listings: listings)),
    );
  }

  void _openSaveSheet(BuildContext context) {
    final currentState = context.read<SearchResultBloc>().state;
    final currentFilter = currentState is SearchResultLoaded ? currentState.filter : initialFilter;
    final savedSearchesBloc = context.read<SavedSearchesBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: savedSearchesBloc,
        child: SavedSearchSaveSheet(
          query: query,
          filter: currentFilter,
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final SearchResultLoaded state;
  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final listings = state.sorted;

    return Column(
      children: [
        _SortBar(currentSort: state.filter.sortBy),
        if (listings.isEmpty)
          const Expanded(child: _EmptyView())
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: listings.length,
              itemBuilder: (context, index) => _PropertyCard(
                listing: listings[index],
                isSaved: state.savedIds.contains(listings[index].id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailsPage(listing: listings[index]),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SortBar extends StatelessWidget {
  final String currentSort;
  const _SortBar({required this.currentSort});

  String get _label {
    switch (currentSort) {
      case 'price_asc': return 'Price: Low to High';
      case 'price_desc': return 'Price: High to Low';
      default: return 'Newest First';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 18, color: AppColors.secondaryGrayText),
          const SizedBox(width: 6),
          const Text(
            'Sort: ',
            style: TextStyle(
              color: AppColors.secondaryGrayText,
              fontSize: 13,
            ),
          ),
          GestureDetector(
            onTap: () => _showSortSheet(context),
            child: Row(
              children: [
                Text(
                  _label,
                  style: const TextStyle(
                    color: AppColors.mainPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: AppColors.mainPurple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        const options = [
          ('newest', 'Newest First', Icons.schedule),
          ('price_asc', 'Price: Low to High', Icons.arrow_upward),
          ('price_desc', 'Price: High to Low', Icons.arrow_downward),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  color: AppColors.primaryDarkText,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSelected = currentSort == opt.$1;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    opt.$3,
                    color: isSelected ? AppColors.mainPurple : AppColors.secondaryGrayText,
                  ),
                  title: Text(
                    opt.$2,
                    style: TextStyle(
                      color: isSelected ? AppColors.mainPurple : AppColors.primaryDarkText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.mainPurple)
                      : null,
                  onTap: () {
                    context.read<SearchResultBloc>().add(SearchResultSortChanged(opt.$1));
                    Navigator.of(sheetCtx).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final ListingEntity listing;
  final bool isSaved;
  final VoidCallback onTap;

  const _PropertyCard({
    required this.listing,
    required this.isSaved,
    required this.onTap,
  });

  String _formatPrice() {
    if (listing.listingFor == 'rent') {
      if (listing.price >= 100000) {
        return '₹${(listing.price / 1000).toStringAsFixed(0)}K/mo';
      }
      return '₹${listing.price.toInt()}/mo';
    }
    if (listing.price >= 10000000) {
      return '₹${(listing.price / 10000000).toStringAsFixed(1)} Cr';
    }
    if (listing.price >= 100000) {
      return '₹${(listing.price / 100000).toStringAsFixed(0)} L';
    }
    return '₹${listing.price.toInt()}';
  }

  String get _ownerTypeLabel {
    switch (listing.type) {
      case 'pg': return 'PG / Hostel';
      case 'commercial': return 'Commercial';
      case 'villa': return 'Villa';
      default: return 'Apartment';
    }
  }

  Color get _ownerTypeColor {
    switch (listing.type) {
      case 'pg': return AppColors.mintGreen;
      case 'commercial': return AppColors.cyanBlue;
      case 'villa': return AppColors.softPink;
      default: return AppColors.softLavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),
            _buildDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: listing.imageUrl.isNotEmpty
              ? Image.network(
                  listing.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                )
              : _placeholderImage(),
        ),
        if (listing.isPremium)
          const Positioned(
            top: 12,
            left: 12,
            child: _Badge(label: 'Premium', color: AppColors.mainPurple),
          ),
        if (listing.isBoosted)
          Positioned(
            top: listing.isPremium ? 44 : 12,
            left: 12,
            child: const _Badge(label: 'Boosted', color: AppColors.mintGreen),
          ),
        Positioned(
          top: 10,
          right: 10,
          child: _SaveButton(
            listingId: listing.id,
            isSaved: isSaved,
          ),
        ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: const Icon(Icons.home, size: 64, color: Colors.white38),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  listing.title,
                  style: const TextStyle(
                    color: AppColors.primaryDarkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatPrice(),
                style: const TextStyle(
                  color: AppColors.mainPurple,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.secondaryGrayText),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  '${listing.locality}, ${listing.city}',
                  style: const TextStyle(
                    color: AppColors.secondaryGrayText,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(
                icon: Icons.category_outlined,
                label: _ownerTypeLabel,
                bgColor: _ownerTypeColor.withOpacity(0.15),
                textColor: _ownerTypeColor,
              ),
              const SizedBox(width: 8),
              if (listing.bedrooms > 0)
                _InfoChip(
                  icon: Icons.bed_outlined,
                  label: '${listing.bedrooms} BHK',
                  bgColor: AppColors.softSkyBlue,
                  textColor: AppColors.cyanBlue,
                ),
              const SizedBox(width: 8),
              if (listing.areaSqft > 0)
                _InfoChip(
                  icon: Icons.square_foot_outlined,
                  label: '${listing.areaSqft.toInt()} sqft',
                  bgColor: AppColors.lightMint,
                  textColor: AppColors.mintGreen,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String listingId;
  final bool isSaved;

  const _SaveButton({required this.listingId, required this.isSaved});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .read<SearchResultBloc>()
          .add(SearchResultToggleSaved(listingId)),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          size: 20,
          color: isSaved ? AppColors.mainPurple : AppColors.secondaryGrayText,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 72, color: AppColors.borderGray),
          SizedBox(height: 16),
          Text(
            'No properties found',
            style: TextStyle(
              color: AppColors.primaryDarkText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters\nor search with a different query',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondaryGrayText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: AppColors.borderGray),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: AppColors.primaryDarkText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.secondaryGrayText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Go Back',
              style: TextStyle(color: AppColors.mainPurple),
            ),
          ),
        ],
      ),
    );
  }
}
