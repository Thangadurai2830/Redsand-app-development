import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../feature_selection/presentation/pages/feature_selection_page.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../maintenance_requests/presentation/pages/maintenance_requests_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/domain/entities/site_visit_record.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../rent_receipts/presentation/pages/rent_receipts_page.dart';
import '../../../saved_listings/presentation/pages/saved_listings_page.dart';
import '../../../saved_searches/presentation/pages/saved_searches_page.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: const _UserDashboardView(),
    );
  }
}

class _UserDashboardView extends StatelessWidget {
  const _UserDashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) => previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message!)),
        );
        context.read<ProfileBloc>().add(const ProfileMessageCleared());
      },
      builder: (context, state) {
        final profile = state.profile;
        final isInitialLoading = state.status == ProfileStatus.loading && profile == null;

        return Scaffold(
          backgroundColor: AppColors.lightGrayBg,
          appBar: AppBar(
            backgroundColor: AppColors.deepRoyalPurple,
            foregroundColor: Colors.white,
            title: const Text(
              'Dashboard',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: state.isSavingProfile || state.isSubmittingKyc
                    ? null
                    : () => context.read<ProfileBloc>().add(const ProfileRefreshRequested()),
              ),
              IconButton(
                tooltip: 'Profile',
                icon: const Icon(Icons.person_outline_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
              ),
            ],
          ),
          body: isInitialLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.mainPurple),
                )
              : state.status == ProfileStatus.failure && profile == null
                  ? _DashboardErrorState(
                      message: state.message ?? 'Unable to load your dashboard right now.',
                      onRetry: () => context.read<ProfileBloc>().add(const ProfileLoadRequested()),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<ProfileBloc>().add(const ProfileRefreshRequested());
                        await Future<void>.delayed(const Duration(milliseconds: 350));
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: [
                          _DashboardHero(
                            profile: profile,
                            visitCount: state.visits.length,
                            isProfileComplete: _isProfileComplete(profile),
                          ),
                          const SizedBox(height: 16),
                          _OverviewRow(
                            profile: profile,
                            visitCount: state.visits.length,
                            completeness: _profileCompleteness(profile),
                          ),
                          const SizedBox(height: 16),
                          _SectionHeader(
                            title: 'Quick Actions',
                            subtitle: 'Access the tools you use most often.',
                          ),
                          const SizedBox(height: 12),
                          _ShortcutGrid(
                            shortcuts: [
                              _ShortcutItem(
                                title: 'Browse Homes',
                                subtitle: 'Explore latest listings',
                                icon: Icons.home_outlined,
                                color: AppColors.deepRoyalPurple,
                                onTap: () => _openHome(context),
                              ),
                              _ShortcutItem(
                                title: 'Saved Listings',
                                subtitle: 'Compare and revisit',
                                icon: Icons.bookmark_outline_rounded,
                                color: AppColors.cyanBlue,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SavedListingsPage()),
                                ),
                              ),
                              _ShortcutItem(
                                title: 'Saved Searches',
                                subtitle: 'Track alerts automatically',
                                icon: Icons.notifications_active_outlined,
                                color: AppColors.mainPurple,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SavedSearchesPage()),
                                ),
                              ),
                              _ShortcutItem(
                                title: 'Profile',
                                subtitle: 'Update KYC and details',
                                icon: Icons.person_outline_rounded,
                                color: AppColors.softLavender,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                                ),
                              ),
                              _ShortcutItem(
                                title: 'Maintenance',
                                subtitle: 'Raise or track tickets',
                                icon: Icons.build_circle_outlined,
                                color: AppColors.mintGreen,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const MaintenanceRequestsPage()),
                                ),
                              ),
                              _ShortcutItem(
                                title: 'Rent Receipts',
                                subtitle: 'Download proof instantly',
                                icon: Icons.receipt_long_outlined,
                                color: AppColors.cyanBlue,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RentReceiptsPage()),
                                ),
                              ),
                              _ShortcutItem(
                                title: 'Feature Selection',
                                subtitle: 'Personalize your experience',
                                icon: Icons.tune_rounded,
                                color: AppColors.deepRoyalPurple,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const FeatureSelectionPage()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _SectionHeader(
                            title: 'Recommended Next Step',
                            subtitle: 'A simple path to keep your account in top shape.',
                          ),
                          const SizedBox(height: 12),
                          _NextStepCard(
                            profile: profile,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ProfilePage()),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SectionHeader(
                            title: 'Recent Activity',
                            subtitle: 'Your latest visits and account activity.',
                          ),
                          const SizedBox(height: 12),
                          _RecentActivityCard(
                            visits: state.visits,
                            isLoading: state.isLoadingVisits,
                            onOpenReceipts: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RentReceiptsPage()),
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}

void _openHome(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => di.sl<HomeBloc>(),
        child: const HomePage(),
      ),
    ),
  );
}

bool _isProfileComplete(UserProfile? profile) {
  if (profile == null) return false;
  return profile.fullName.trim().isNotEmpty &&
      profile.email.trim().isNotEmpty &&
      profile.phone.trim().isNotEmpty &&
      profile.address.trim().isNotEmpty &&
      profile.aadhaarVerified &&
      profile.panVerified;
}

int _profileCompleteness(UserProfile? profile) {
  if (profile == null) return 0;
  var score = 0;
  if (profile.fullName.trim().isNotEmpty) score += 20;
  if (profile.email.trim().isNotEmpty) score += 15;
  if (profile.phone.trim().isNotEmpty) score += 15;
  if (profile.address.trim().isNotEmpty) score += 15;
  if (profile.aadhaarVerified) score += 15;
  if (profile.panVerified) score += 20;
  return score.clamp(0, 100);
}

class _DashboardHero extends StatelessWidget {
  final UserProfile? profile;
  final int visitCount;
  final bool isProfileComplete;

  const _DashboardHero({
    required this.profile,
    required this.visitCount,
    required this.isProfileComplete,
  });

  @override
  Widget build(BuildContext context) {
    final rawName = profile?.fullName.trim() ?? '';
    final displayName = rawName.isNotEmpty ? rawName : 'Welcome back';
    final subtitle = profile == null
        ? 'Your account overview will appear here once profile data loads.'
        : isProfileComplete
            ? 'Your account is in strong shape. Keep exploring properties and managing your requests.'
            : 'A few quick updates will make your account fully ready for property actions.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepRoyalPurple.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -12,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _initials(displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal dashboard',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.35,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroPill(
                    label: isProfileComplete ? 'Profile ready' : 'Profile pending',
                    icon: isProfileComplete ? Icons.verified_rounded : Icons.pending_outlined,
                  ),
                  _HeroPill(
                    label: '$visitCount recent visit${visitCount == 1 ? '' : 's'}',
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HeroPill({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final UserProfile? profile;
  final int visitCount;
  final int completeness;

  const _OverviewRow({
    required this.profile,
    required this.visitCount,
    required this.completeness,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MiniStat(
        label: 'Profile',
        value: '$completeness%',
        icon: Icons.account_circle_outlined,
        accent: AppColors.mainPurple,
      ),
      _MiniStat(
        label: 'Visits',
        value: '$visitCount',
        icon: Icons.history_rounded,
        accent: AppColors.cyanBlue,
      ),
      _MiniStat(
        label: 'KYC',
        value: profile?.isKycComplete == true ? 'Ready' : 'Pending',
        icon: Icons.verified_user_outlined,
        accent: profile?.isKycComplete == true ? AppColors.mintGreen : AppColors.softLavender,
      ),
      _MiniStat(
        label: 'Support',
        value: '24/7',
        icon: Icons.support_agent_rounded,
        accent: AppColors.deepRoyalPurple,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 560;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isWide ? 1.35 : 1.45,
          ),
          itemBuilder: (_, index) => cards[index],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDarkText,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryGrayText,
              fontWeight: FontWeight.w500,
            ),
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
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDarkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.secondaryGrayText,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ShortcutItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ShortcutGrid extends StatelessWidget {
  final List<_ShortcutItem> shortcuts;

  const _ShortcutGrid({
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 560;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shortcuts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 3 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isWide ? 1.45 : 1.2,
          ),
          itemBuilder: (context, index) => _ShortcutCard(item: shortcuts[index]),
        );
      },
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final _ShortcutItem item;

  const _ShortcutCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkText,
                ),
              ),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryGrayText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final UserProfile? profile;
  final VoidCallback onTap;

  const _NextStepCard({
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = profile?.isKycComplete == true;
    final title = isComplete ? 'Review your saved homes' : 'Complete your profile';
    final description = isComplete
        ? 'Your KYC looks good. Browse new properties, compare saved listings, or manage receipts.'
        : 'A complete profile helps with smoother verification, faster support, and better property actions.';

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.ctaGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  isComplete ? Icons.bookmark_added_rounded : Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDarkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryGrayText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.secondaryGrayText),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final List<SiteVisitRecord> visits;
  final bool isLoading;
  final VoidCallback onOpenReceipts;

  const _RecentActivityCard({
    required this.visits,
    required this.isLoading,
    required this.onOpenReceipts,
  });

  @override
  Widget build(BuildContext context) {
    final recentVisits = visits.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.mainPurple),
              ),
            )
              : visits.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No recent visits yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDarkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Once your viewing or site history is available, it will appear here for quick reference.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryGrayText,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onOpenReceipts,
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('Open Receipts'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppColors.deepRoyalPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    for (var i = 0; i < recentVisits.length; i++) ...[
                      _VisitTile(visit: recentVisits[i]),
                      if (i != recentVisits.length - 1) const Divider(height: 18),
                    ],
                  ],
                ),
    );
  }
}

class _VisitTile extends StatelessWidget {
  final SiteVisitRecord visit;

  const _VisitTile({
    required this.visit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.veryLightPurpleBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.location_on_outlined, color: AppColors.mainPurple, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visit.propertyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDarkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${visit.status} - ${visit.visitDate} at ${visit.visitTime}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryGrayText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.deepRoyalPurple, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dashboard unavailable',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryGrayText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.deepRoyalPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
