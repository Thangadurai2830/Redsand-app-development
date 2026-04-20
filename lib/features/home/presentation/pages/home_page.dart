import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../filter/domain/entities/filter_entity.dart';
import '../../../search_result/presentation/pages/search_result_page.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/search_suggestion_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  String _listingFor = 'rent';

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToSearchResult(String query, {String? propertyType}) {
    _searchController.clear();
    context.read<HomeBloc>().add(const ClearSearch());
    final filter = FilterEntity(
      listingFor: _listingFor,
      propertyType: propertyType,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultPage(query: query, initialFilter: filter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, state),
              if (state is HomeSearchSuggestionsLoaded)
                _buildSuggestionsList(context, state.suggestions)
              else ...[
                _buildRentBuyToggle(context),
                _buildQuickCategories(context),
                if (state is HomeLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.mainPurple),
                    ),
                  )
                else if (state is HomeError)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.secondaryGrayText),
                      ),
                    ),
                  )
                else if (state is HomeLoaded) ...[
                  _buildSectionHeader('Featured Listings'),
                  _buildFeaturedListings(state.featuredListings),
                  _buildSectionHeader('Recommended for You'),
                  _buildRecommendedListings(state.recommendedListings),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, HomeState state) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.deepRoyalPurple,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find Your Home',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildSearchBar(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeState state) {
    final showClear = state is HomeSearchSuggestionsLoaded;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search city, locality, apartment...',
          hintStyle: const TextStyle(
            color: AppColors.secondaryGrayText,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.secondaryGrayText,
            size: 20,
          ),
          suffixIcon: showClear
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.secondaryGrayText,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<HomeBloc>().add(const ClearSearch());
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (q) => context.read<HomeBloc>().add(SearchQueryChanged(q)),
        onSubmitted: (q) {
          if (q.trim().isNotEmpty) _goToSearchResult(q.trim());
        },
      ),
    );
  }

  Widget _buildRentBuyToggle(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.borderGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _toggleOption(context, 'Rent', 'rent'),
              _toggleOption(context, 'Buy', 'buy'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleOption(BuildContext context, String label, String value) {
    final isSelected = _listingFor == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _listingFor = value);
          context.read<HomeBloc>().add(ToggleListingFor(value));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mainPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.secondaryGrayText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCategories(BuildContext context) {
    const categories = [
      ('Apartment', Icons.apartment, 'apartment'),
      ('Villa', Icons.villa, 'villa'),
      ('PG', Icons.bed, 'pg'),
      ('Commercial', Icons.business, 'commercial'),
    ];
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 96,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final (label, icon, type) = categories[i];
            return GestureDetector(
              onTap: () => _goToSearchResult('', propertyType: type),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.veryLightPurpleBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: AppColors.mainPurple, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDarkText,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarkText,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedListings(List<ListingEntity> listings) {
    if (listings.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'No featured listings',
            style: TextStyle(color: AppColors.secondaryGrayText),
          ),
        ),
      );
    }
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: listings.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _FeaturedCard(listing: listings[i]),
        ),
      ),
    );
  }

  Widget _buildRecommendedListings(List<ListingEntity> listings) {
    if (listings.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Text(
            'No recommendations yet',
            style: TextStyle(color: AppColors.secondaryGrayText),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _RecommendedCard(listing: listings[i]),
        ),
        childCount: listings.length,
      ),
    );
  }

  Widget _buildSuggestionsList(
    BuildContext context,
    List<SearchSuggestionEntity> suggestions,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final s = suggestions[i];
          return ListTile(
            leading: Icon(
              s.type == 'city'
                  ? Icons.location_city
                  : s.type == 'locality'
                      ? Icons.map
                      : Icons.apartment,
              color: AppColors.mainPurple,
            ),
            title: Text(s.text),
            subtitle: Text(
              s.type,
              style: const TextStyle(
                color: AppColors.secondaryGrayText,
                fontSize: 12,
              ),
            ),
            onTap: () => _goToSearchResult(s.text),
          );
        },
        childCount: suggestions.length,
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final ListingEntity listing;
  const _FeaturedCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.veryLightPurpleBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.home,
                    size: 48,
                    color: AppColors.lightLavender,
                  ),
                ),
              ),
              if (listing.isPremium)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.mainPurple,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (listing.isBoosted)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Boosted',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primaryDarkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${listing.locality}, ${listing.city}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryGrayText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  listing.listingFor == 'rent'
                      ? '₹${listing.price.toInt()}/mo'
                      : '₹${(listing.price / 100000).toStringAsFixed(1)}L',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.mainPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final ListingEntity listing;
  const _RecommendedCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.veryLightPurpleBg,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
            ),
            child: const Center(
              child: Icon(
                Icons.home,
                size: 36,
                color: AppColors.lightLavender,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.primaryDarkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (listing.isPremium)
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.veryLightPurpleBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              color: AppColors.mainPurple,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.locality}, ${listing.city}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryGrayText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.king_bed_outlined,
                        size: 14,
                        color: AppColors.secondaryGrayText,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${listing.bedrooms} BHK',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryGrayText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.square_foot,
                        size: 14,
                        color: AppColors.secondaryGrayText,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${listing.areaSqft.toInt()} sqft',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryGrayText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.listingFor == 'rent'
                        ? '₹${listing.price.toInt()}/mo'
                        : '₹${(listing.price / 100000).toStringAsFixed(1)}L',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.mainPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
