import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/owner_analytics_entity.dart';
import '../../domain/entities/owner_buyer_interest_entity.dart';
import '../../domain/entities/owner_listing_entity.dart';
import '../../domain/entities/owner_listing_status.dart';
import '../bloc/owner_dashboard_bloc.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  final _scrollController = ScrollController();
  final _listingsKey = GlobalKey();
  final _interestsKey = GlobalKey();
  final _analyticsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OwnerDashboardBloc>()..add(const OwnerDashboardStarted()),
      child: _OwnerDashboardView(
        scrollController: _scrollController,
        listingsKey: _listingsKey,
        interestsKey: _interestsKey,
        analyticsKey: _analyticsKey,
      ),
    );
  }
}

class _OwnerDashboardView extends StatelessWidget {
  final ScrollController scrollController;
  final GlobalKey listingsKey;
  final GlobalKey interestsKey;
  final GlobalKey analyticsKey;

  const _OwnerDashboardView({
    required this.scrollController,
    required this.listingsKey,
    required this.interestsKey,
    required this.analyticsKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OwnerDashboardBloc, OwnerDashboardState>(
      listenWhen: (previous, current) => previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message!)),
        );
        context.read<OwnerDashboardBloc>().add(const OwnerDashboardMessageCleared());
      },
      builder: (context, state) {
        final analytics = state.analytics;
        final isInitialLoading = state.status == OwnerDashboardStatus.loading && !state.hasData;

        return Scaffold(
          backgroundColor: AppColors.lightGrayBg,
          appBar: AppBar(
            backgroundColor: AppColors.deepRoyalPurple,
            foregroundColor: Colors.white,
            title: const Text(
              'Owner Dashboard',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: state.isLoading
                    ? null
                    : () => context.read<OwnerDashboardBloc>().add(const OwnerDashboardRefreshed()),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: isInitialLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.mainPurple))
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<OwnerDashboardBloc>().add(const OwnerDashboardRefreshed());
                    await Future<void>.delayed(const Duration(milliseconds: 350));
                  },
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _HeroSection(
                        analytics: analytics,
                        listings: state.listings,
                        interests: state.interests,
                      ),
                      const SizedBox(height: 16),
                      const _SectionHeader(
                        title: 'Quick Actions',
                        subtitle: 'Jump to the tools owners use most often.',
                      ),
                      const SizedBox(height: 12),
                      _ActionGrid(
                        onViewListings: () => _scrollToSection(listingsKey),
                        onViewInterests: () => _scrollToSection(interestsKey),
                        onViewAnalytics: () => _scrollToSection(analyticsKey),
                        onBoostListing: state.filteredListings.isEmpty
                            ? null
                            : () => context
                                .read<OwnerDashboardBloc>()
                                .add(OwnerDashboardBoostRequested(state.filteredListings.first.id)),
                      ),
                      const SizedBox(height: 16),
                      const _SectionHeader(
                        title: 'Listing Status',
                        subtitle: 'Filter by status: draft, pending, approved, flagged, rented.',
                      ),
                      const SizedBox(height: 12),
                      _StatusChips(
                        selected: state.selectedStatus,
                        onChanged: (status) =>
                            context.read<OwnerDashboardBloc>().add(OwnerDashboardStatusFilterChanged(status)),
                      ),
                      const SizedBox(height: 16),
                      _SectionHeader(
                        key: listingsKey,
                        title: 'View Listings',
                        subtitle: '${state.filteredListings.length} listings match the selected status.',
                      ),
                      const SizedBox(height: 12),
                      if (state.filteredListings.isEmpty)
                        const _EmptyState(
                          icon: Icons.home_work_outlined,
                          title: 'No listings found',
                          subtitle: 'Try a different status filter or refresh the dashboard.',
                        )
                      else
                        Column(
                          children: [
                            for (final listing in state.filteredListings) ...[
                              _ListingCard(
                                listing: listing,
                                isBoosting: state.boostingListingIds.contains(listing.id),
                                onBoost: () => context
                                    .read<OwnerDashboardBloc>()
                                    .add(OwnerDashboardBoostRequested(listing.id)),
                              ),
                              if (listing != state.filteredListings.last) const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      const SizedBox(height: 16),
                      _SectionHeader(
                        key: interestsKey,
                        title: 'Interested Buyers',
                        subtitle: 'Recent buyers who requested a callback or showed interest.',
                      ),
                      const SizedBox(height: 12),
                      if (state.interests.isEmpty)
                        const _EmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No buyer interests yet',
                          subtitle: 'Interested buyers will appear here when the API returns results.',
                        )
                      else
                        Column(
                          children: [
                            for (final interest in state.interests) ...[
                              _InterestCard(interest: interest),
                              if (interest != state.interests.last) const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      const SizedBox(height: 16),
                      _SectionHeader(
                        key: analyticsKey,
                        title: 'Analytics',
                        subtitle: 'A fast snapshot of listing performance and response health.',
                      ),
                      const SizedBox(height: 12),
                      _AnalyticsCard(analytics: analytics),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

void _scrollToSection(GlobalKey key) {
  final targetContext = key.currentContext;
  if (targetContext == null) return;
  Scrollable.ensureVisible(
    targetContext,
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeInOut,
    alignment: 0.05,
  );
}

class _HeroSection extends StatelessWidget {
  final OwnerAnalyticsEntity? analytics;
  final List<OwnerListingEntity> listings;
  final List<OwnerBuyerInterestEntity> interests;

  const _HeroSection({
    required this.analytics,
    required this.listings,
    required this.interests,
  });

  @override
  Widget build(BuildContext context) {
    final totalListings = analytics?.totalListings ?? listings.length;
    final totalLeads = analytics?.totalInterestedBuyers ?? interests.length;
    final boosted = analytics?.boostedListings ?? listings.where((listing) => listing.isBoosted).length;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your portfolio at a glance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track status, interest, and boost readiness from one owner-first workspace.',
            style: TextStyle(color: Colors.white.withOpacity(0.78), height: 1.4),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MiniMetric(label: 'Listings', value: '$totalListings'),
              _MiniMetric(label: 'Leads', value: '$totalLeads'),
              _MiniMetric(label: 'Boosted', value: '$boosted'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final VoidCallback onViewListings;
  final VoidCallback onViewInterests;
  final VoidCallback onViewAnalytics;
  final VoidCallback? onBoostListing;

  const _ActionGrid({
    required this.onViewListings,
    required this.onViewInterests,
    required this.onViewAnalytics,
    required this.onBoostListing,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
        title: 'View Listings',
        subtitle: 'Open property inventory',
        icon: Icons.home_outlined,
        color: AppColors.deepRoyalPurple,
        onTap: onViewListings,
      ),
      _ActionData(
        title: 'Interested Buyers',
        subtitle: 'See buyer requests',
        icon: Icons.people_outline_rounded,
        color: AppColors.cyanBlue,
        onTap: onViewInterests,
      ),
      _ActionData(
        title: 'Analytics',
        subtitle: 'Inspect performance',
        icon: Icons.insights_rounded,
        color: AppColors.mintGreen,
        onTap: onViewAnalytics,
      ),
      _ActionData(
        title: 'Boost Listing',
        subtitle: 'Promote faster visibility',
        icon: Icons.trending_up_rounded,
        color: AppColors.mainPurple,
        onTap: onBoostListing,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 120,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) => _ActionCard(data: actions[index]),
    );
  }
}

class _StatusChips extends StatelessWidget {
  final OwnerListingStatus? selected;
  final ValueChanged<OwnerListingStatus?> onChanged;

  const _StatusChips({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const statuses = OwnerListingStatus.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          for (final status in statuses)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(status.label),
                selected: selected == status,
                onSelected: (_) => onChanged(status),
              ),
            ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final OwnerListingEntity listing;
  final bool isBoosting;
  final VoidCallback onBoost;

  const _ListingCard({
    required this.listing,
    required this.isBoosting,
    required this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: AspectRatio(
              aspectRatio: 1.8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    listing.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.veryLightPurpleBg,
                      alignment: Alignment.center,
                      child: const Icon(Icons.home_outlined, size: 44, color: AppColors.mainPurple),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.48), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _StatusBadge(status: listing.status),
                  ),
                  if (listing.isBoosted)
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: _BoostBadge(),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${listing.locality}, ${listing.city}',
                  style: const TextStyle(color: AppColors.secondaryGrayText),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _InfoPill(icon: Icons.currency_rupee, label: '₹${listing.price.toStringAsFixed(0)}'),
                    const SizedBox(width: 8),
                    _InfoPill(icon: Icons.bed_outlined, label: '${listing.bedrooms} bed'),
                    const SizedBox(width: 8),
                    _InfoPill(icon: Icons.group_outlined, label: '${listing.interestedBuyersCount} leads'),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isBoosting ? null : onBoost,
                    icon: isBoosting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.campaign_outlined),
                    label: Text(listing.isBoosted ? 'Boost again' : 'Boost listing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
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

class _InterestCard extends StatelessWidget {
  final OwnerBuyerInterestEntity interest;

  const _InterestCard({required this.interest});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGray),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.veryLightPurpleBg,
                child: Icon(Icons.person_outline_rounded, color: AppColors.mainPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      interest.buyerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      interest.listingTitle,
                      style: const TextStyle(color: AppColors.secondaryGrayText),
                    ),
                  ],
                ),
              ),
              _InfoPill(icon: Icons.payments_outlined, label: interest.budget),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            interest.note,
            style: const TextStyle(height: 1.4, color: AppColors.primaryDarkText),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(icon: Icons.phone_outlined, label: interest.phone.isEmpty ? 'No phone' : interest.phone),
              _InfoPill(icon: Icons.email_outlined, label: interest.email.isEmpty ? 'No email' : interest.email),
              _InfoPill(
                icon: Icons.schedule_outlined,
                label: interest.requestedAt == null
                    ? 'Recent interest'
                    : _formatDate(interest.requestedAt!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final OwnerAnalyticsEntity? analytics;

  const _AnalyticsCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final data = analytics;
    if (data == null) {
      return const _EmptyState(
        icon: Icons.query_stats_rounded,
        title: 'Analytics not available',
        subtitle: 'The analytics API has not returned data yet.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderGray),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Views', value: '${data.totalViews}'),
              _StatCard(label: 'Leads', value: '${data.totalLeads}'),
              _StatCard(label: 'Conversion', value: '${data.displayLeadConversionRate.toStringAsFixed(1)}%'),
              _StatCard(label: 'Response', value: '${data.averageResponseMinutes}m'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Status breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDarkText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusMetric(status: OwnerListingStatus.draft, count: data.draftCount),
              _StatusMetric(status: OwnerListingStatus.pending, count: data.pendingCount),
              _StatusMetric(status: OwnerListingStatus.approved, count: data.approvedCount),
              _StatusMetric(status: OwnerListingStatus.flagged, count: data.flaggedCount),
              _StatusMetric(status: OwnerListingStatus.rented, count: data.rentedCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _ActionData data;

  const _ActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGray),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.color),
            ),
            const SizedBox(height: 10),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.subtitle,
              style: const TextStyle(
                color: AppColors.secondaryGrayText,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.secondaryGrayText, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDarkText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  final OwnerListingStatus status;
  final int count;

  const _StatusMetric({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: _statusColor(status).withOpacity(0.12),
      side: BorderSide(color: _statusColor(status).withOpacity(0.3)),
      label: Text('${status.label}: $count'),
      labelStyle: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w600),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondaryGrayText),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.primaryDarkText),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OwnerListingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BoostBadge extends StatelessWidget {
  const _BoostBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Boosted',
        style: TextStyle(
          color: AppColors.mainPurple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.mainPurple),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDarkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondaryGrayText, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDarkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.secondaryGrayText, height: 1.35),
        ),
      ],
    );
  }
}

class _ActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

Color _statusColor(OwnerListingStatus status) {
  switch (status) {
    case OwnerListingStatus.draft:
      return AppColors.secondaryGrayText;
    case OwnerListingStatus.pending:
      return AppColors.cyanBlue;
    case OwnerListingStatus.approved:
      return AppColors.mintGreen;
    case OwnerListingStatus.flagged:
      return Colors.deepOrange;
    case OwnerListingStatus.rented:
      return AppColors.mainPurple;
  }
}

String _formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  return '$day/$month/${dateTime.year}';
}
