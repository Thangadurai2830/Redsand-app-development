import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/contact_launcher.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../../domain/entities/nearby_place_entity.dart';
import '../../domain/entities/price_history_point_entity.dart';
import '../../domain/entities/property_details_entity.dart';
import '../../domain/entities/property_review_entity.dart';
import '../../domain/entities/property_owner_entity.dart';
import '../bloc/property_details_bloc.dart';
import '../bloc/property_details_event.dart';
import '../bloc/property_details_state.dart';
import 'chat_room_page.dart';
import '../../../schedule_visit/presentation/pages/schedule_visit_page.dart';
import '../../../reviews/presentation/pages/reviews_page.dart';

enum ContactAccessPlan { free, paid }
enum ContactActionType { call, chat, whatsapp }

class PropertyDetailsPage extends StatelessWidget {
  final ListingEntity listing;
  final ContactAccessPlan contactAccessPlan;

  const PropertyDetailsPage({
    super.key,
    required this.listing,
    this.contactAccessPlan = ContactAccessPlan.free,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PropertyDetailsBloc>()..add(PropertyDetailsLoaded(listing)),
      child: _PropertyDetailsView(contactAccessPlan: contactAccessPlan),
    );
  }
}

class _PropertyDetailsView extends StatefulWidget {
  final ContactAccessPlan contactAccessPlan;

  const _PropertyDetailsView({
    required this.contactAccessPlan,
  });

  @override
  State<_PropertyDetailsView> createState() => _PropertyDetailsViewState();
}

class _PropertyDetailsViewState extends State<_PropertyDetailsView> {
  final _galleryController = PageController();
  ContactActionType? _pendingAction;

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyDetailsBloc, PropertyDetailsState>(
      listenWhen: (previous, current) => previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
        if (state.contactUnlocked && _pendingAction != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final details = state.details;
            if (details != null) {
              _performContactAction(context, _pendingAction!, details);
              setState(() => _pendingAction = null);
            }
          });
        }
      },
      builder: (context, state) {
        if (state.status == PropertyDetailsStatus.loading || state.status == PropertyDetailsStatus.initial) {
          return const Scaffold(
            backgroundColor: AppColors.lightGrayBg,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.mainPurple),
            ),
          );
        }

        if (state.status == PropertyDetailsStatus.failure || state.details == null) {
          return Scaffold(
            backgroundColor: AppColors.lightGrayBg,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkText),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: Text(
                state.message ?? 'Unable to load property details',
                style: const TextStyle(color: AppColors.secondaryGrayText),
              ),
            ),
          );
        }

        final details = state.details!;
        final contactUnlocked = widget.contactAccessPlan == ContactAccessPlan.paid || state.contactUnlocked;

        return Scaffold(
          backgroundColor: AppColors.lightGrayBg,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: AppColors.deepRoyalPurple,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      state.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.white,
                    ),
                    onPressed: state.isSaved
                        ? null
                        : () => context.read<PropertyDetailsBloc>().add(const PropertyDetailsSaveRequested()),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _GalleryHeader(
                    listing: details.listing,
                    controller: _galleryController,
                    images: details.galleryImages,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryCard(details: details, contactUnlocked: contactUnlocked),
                      const SizedBox(height: 16),
                      _ActionGrid(
                        contactUnlocked: contactUnlocked,
                        onSave: state.isSaved ? null : () => context.read<PropertyDetailsBloc>().add(const PropertyDetailsSaveRequested()),
                        onCall: () => _handleContactAction(context, ContactActionType.call, details, contactUnlocked),
                        onChat: () => _handleContactAction(context, ContactActionType.chat, details, contactUnlocked),
                        onWhatsApp: () => _handleContactAction(context, ContactActionType.whatsapp, details, contactUnlocked),
                        onScheduleVisit: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ScheduleVisitPage(listing: details.listing),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ContactGateCard(
                        contactUnlocked: contactUnlocked,
                        owner: details.owner,
                        onUnlock: contactUnlocked
                            ? null
                            : () => context.read<PropertyDetailsBloc>().add(const PropertyDetailsContactRevealRequested()),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Floor Plan Viewer',
                        subtitle: 'Interactive layout preview',
                        child: _FloorPlanViewer(
                          title: details.listing.title,
                          sections: details.floorPlanSections,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Owner Info',
                        subtitle: 'Direct contact and response details',
                        child: _OwnerInfoCard(
                          owner: details.owner,
                          contactUnlocked: contactUnlocked,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Nearby Places',
                        subtitle: 'Everyday essentials around the property',
                        child: _NearbyPlacesList(places: details.nearbyPlaces),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Reviews',
                        subtitle: 'Feedback from recent visitors and tenants',
                        trailing: TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReviewsPage(listing: details.listing),
                            ),
                          ),
                          icon: const Icon(Icons.rate_review_outlined, size: 18),
                          label: const Text('Write review'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.mainPurple,
                          ),
                        ),
                        child: _ReviewsList(reviews: details.reviews),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Price History',
                        subtitle: 'Recent price movement for this property',
                        child: _PriceHistoryChart(points: details.priceHistory),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Similar Listings',
                        subtitle: 'Other options that match this home',
                        child: _SimilarListings(
                          listings: details.similarListings,
                          contactAccessPlan: widget.contactAccessPlan,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleContactAction(
    BuildContext context,
    ContactActionType action,
    PropertyDetailsEntity details,
    bool contactUnlocked,
  ) {
    if (contactUnlocked) {
      _performContactAction(context, action, details);
      return;
    }

    setState(() => _pendingAction = action);
    context.read<PropertyDetailsBloc>().add(const PropertyDetailsContactRevealRequested());
  }

  Future<void> _performContactAction(
    BuildContext context,
    ContactActionType action,
    PropertyDetailsEntity details,
  ) async {
    final phone = details.owner.phoneNumber;
    final whatsappDigits = details.owner.whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    switch (action) {
      case ContactActionType.call:
        final ok = await ContactLauncher.launchPhone(phone);
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone calling is not available on this device')),
          );
        }
        break;
      case ContactActionType.chat:
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(
              listing: details.listing,
              owner: details.owner,
            ),
          ),
        );
        break;
      case ContactActionType.whatsapp:
        final ok = await ContactLauncher.launchWhatsApp(
          whatsappDigits,
          'Hi, I am interested in ${details.listing.title}.',
        );
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp is not available on this device')),
          );
        }
        break;
    }
  }
}

class _GalleryHeader extends StatelessWidget {
  final ListingEntity listing;
  final PageController controller;
  final List<String> images;

  const _GalleryHeader({
    required this.listing,
    required this.controller,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        ),
        PageView.builder(
          controller: controller,
          itemCount: images.length,
          itemBuilder: (context, index) => _GalleryTile(
            label: images[index],
            listing: listing,
            index: index,
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmoothPageIndicator(
                controller: controller,
                count: images.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: AppColors.white,
                  dotColor: Colors.white54,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                listing.title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${listing.locality}, ${listing.city}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final String label;
  final ListingEntity listing;
  final int index;

  const _GalleryTile({
    required this.label,
    required this.listing,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 96, 16, 92),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.white.withOpacity(0.08),
                    AppColors.white.withOpacity(0.18),
                  ],
                ),
              ),
            ),
            if (listing.imageUrl.isNotEmpty)
              Image.network(
                listing.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderGallery(
                  label: label,
                  index: index,
                ),
              )
            else
              _PlaceholderGallery(label: label, index: index),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderGallery extends StatelessWidget {
  final String label;
  final int index;

  const _PlaceholderGallery({
    required this.label,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      [AppColors.softLavender, AppColors.mainPurple],
      [AppColors.cyanBlue, AppColors.deepRoyalPurple],
      [AppColors.mintGreen, AppColors.softLavender],
      [AppColors.warmCream, AppColors.mainPurple],
    ];
    final palette = colors[index % colors.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_rounded, size: 72, color: AppColors.white),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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

class _SummaryCard extends StatelessWidget {
  final PropertyDetailsEntity details;
  final bool contactUnlocked;

  const _SummaryCard({
    required this.details,
    required this.contactUnlocked,
  });

  String _priceLabel() {
    final listing = details.listing;
    if (listing.listingFor == 'rent') {
      return '₹${listing.price.toInt()}/mo';
    }
    if (listing.price >= 10000000) {
      return '₹${(listing.price / 10000000).toStringAsFixed(1)} Cr';
    }
    return '₹${(listing.price / 100000).toStringAsFixed(1)} L';
  }

  @override
  Widget build(BuildContext context) {
    final listing = details.listing;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge(
                label: listing.isPremium ? 'Premium' : 'Standard',
                color: listing.isPremium ? AppColors.mainPurple : AppColors.secondaryGrayText,
              ),
              const SizedBox(width: 8),
              if (listing.isBoosted)
                const _Badge(label: 'Boosted', color: AppColors.mintGreen),
              const Spacer(),
              Text(
                contactUnlocked ? 'Contact unlocked' : 'Contact locked',
                style: const TextStyle(
                  color: AppColors.secondaryGrayText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDarkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${listing.locality}, ${listing.city}',
            style: const TextStyle(
              color: AppColors.secondaryGrayText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoChip(icon: Icons.king_bed_outlined, label: '${listing.bedrooms} BHK'),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.square_foot, label: '${listing.areaSqft.toInt()} sqft'),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.apartment, label: listing.type.toUpperCase()),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _priceLabel(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.mainPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final bool contactUnlocked;
  final VoidCallback? onSave;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onWhatsApp;
  final VoidCallback onScheduleVisit;

  const _ActionGrid({
    required this.contactUnlocked,
    required this.onSave,
    required this.onCall,
    required this.onChat,
    required this.onWhatsApp,
    required this.onScheduleVisit,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionSpec(icon: Icons.bookmark_add_outlined, label: 'Save Listing', onTap: onSave),
      _ActionSpec(icon: Icons.call_outlined, label: 'Call Owner', onTap: onCall, locked: !contactUnlocked),
      _ActionSpec(icon: Icons.chat_bubble_outline, label: 'Chat Now', onTap: onChat, locked: !contactUnlocked),
      _ActionSpec(icon: Icons.chat, label: 'WhatsApp', onTap: onWhatsApp, locked: !contactUnlocked),
      _ActionSpec(icon: Icons.event_available_outlined, label: 'Schedule Visit', onTap: onScheduleVisit),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions.map((action) => _ActionButton(spec: action)).toList(),
    );
  }
}

class _ActionSpec {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool locked;

  const _ActionSpec({
    required this.icon,
    required this.label,
    required this.onTap,
    this.locked = false,
  });
}

class _ActionButton extends StatelessWidget {
  final _ActionSpec spec;

  const _ActionButton({required this.spec});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: spec.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: spec.locked ? AppColors.borderGray : AppColors.lightLavender),
            ),
            child: Row(
              children: [
                Icon(
                  spec.icon,
                  color: spec.locked ? AppColors.secondaryGrayText : AppColors.mainPurple,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    spec.label,
                    style: TextStyle(
                      color: spec.locked ? AppColors.secondaryGrayText : AppColors.primaryDarkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (spec.locked)
                  const Icon(
                    Icons.lock_outline,
                    color: AppColors.secondaryGrayText,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactGateCard extends StatelessWidget {
  final bool contactUnlocked;
  final PropertyOwnerEntity owner;
  final VoidCallback? onUnlock;

  const _ContactGateCard({
    required this.contactUnlocked,
    required this.owner,
    required this.onUnlock,
  });

  String _maskedPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.length <= 6) return 'Hidden';
    return '${digits.substring(0, 4)} XXXXX ${digits.substring(digits.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contactUnlocked ? 'Full contact access is active' : 'Contact details are locked on the free plan',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            contactUnlocked ? owner.phoneNumber : _maskedPhone(owner.phoneNumber),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            owner.responseTime,
            style: const TextStyle(color: Colors.white70),
          ),
          if (!contactUnlocked) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.mainPurple,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: onUnlock,
              icon: const Icon(Icons.lock_open_outlined),
              label: const Text('Unlock Contact'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
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
                        color: AppColors.secondaryGrayText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FloorPlanViewer extends StatelessWidget {
  final String title;
  final List<String> sections;

  const _FloorPlanViewer({
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.veryLightPurpleBg,
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightLavender.withOpacity(0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.mainPurple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.view_in_ar_outlined,
                    color: AppColors.mainPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.primaryDarkText,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Pinch to zoom and inspect the layout',
                        style: TextStyle(
                          color: AppColors.secondaryGrayText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 11,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 2.4,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _FloorPlanPainter(),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          top: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Blueprint',
                              style: TextStyle(
                                color: AppColors.mainPurple,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sections
                  .map(
                    (item) => _PlanTag(label: item),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTag extends StatelessWidget {
  final String label;

  const _PlanTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightLavender.withOpacity(0.7)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryDarkText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FloorPlanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF9F7FF),
          Color(0xFFF3F0FF),
          Color(0xFFFFFFFF),
        ],
      ).createShader(Offset.zero & size);
    final gridPaint = Paint()
      ..color = AppColors.lightLavender.withOpacity(0.28)
      ..strokeWidth = 1;
    final wallPaint = Paint()
      ..color = AppColors.mainPurple.withOpacity(0.72)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final roomPaint = Paint()
      ..color = AppColors.white.withOpacity(0.92)
      ..style = PaintingStyle.fill;
    final roomAccent = Paint()
      ..color = AppColors.cyanBlue.withOpacity(0.14)
      ..style = PaintingStyle.fill;
    final serviceAccent = Paint()
      ..color = AppColors.mintGreen.withOpacity(0.16)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, bgPaint);

    for (var x = 0.0; x <= size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 18, size.width - 36, size.height - 36),
      const Radius.circular(20),
    );
    canvas.drawRRect(outer, roomPaint);
    canvas.drawRRect(outer, wallPaint);

    final living = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.13, size.width * 0.36, size.height * 0.28),
      const Radius.circular(14),
    );
    final bedroom = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.48, size.height * 0.13, size.width * 0.26, size.height * 0.22),
      const Radius.circular(14),
    );
    final kitchen = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.48, size.width * 0.24, size.height * 0.2),
      const Radius.circular(14),
    );
    final dining = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.36, size.height * 0.42, size.width * 0.3, size.height * 0.24),
      const Radius.circular(14),
    );
    final balcony = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.7, size.height * 0.4, size.width * 0.14, size.height * 0.28),
      const Radius.circular(14),
    );
    final utility = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.48, size.height * 0.38, size.width * 0.16, size.height * 0.12),
      const Radius.circular(10),
    );

    canvas.drawRRect(living, roomAccent);
    canvas.drawRRect(bedroom, roomAccent);
    canvas.drawRRect(kitchen, serviceAccent);
    canvas.drawRRect(dining, roomAccent);
    canvas.drawRRect(balcony, serviceAccent);
    canvas.drawRRect(utility, roomAccent);

    final innerWallPaint = Paint()
      ..color = AppColors.mainPurple.withOpacity(0.34)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.44, size.height * 0.13),
      Offset(size.width * 0.44, size.height * 0.66),
      innerWallPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.42),
      Offset(size.width * 0.56, size.height * 0.42),
      innerWallPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.68, size.height * 0.38),
      Offset(size.width * 0.68, size.height * 0.68),
      innerWallPaint,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    _drawLabel(canvas, textPainter, 'Living', Offset(size.width * 0.26, size.height * 0.26));
    _drawLabel(canvas, textPainter, 'Bedroom', Offset(size.width * 0.61, size.height * 0.24));
    _drawLabel(canvas, textPainter, 'Kitchen', Offset(size.width * 0.2, size.height * 0.58));
    _drawLabel(canvas, textPainter, 'Dining', Offset(size.width * 0.5, size.height * 0.54));
    _drawLabel(canvas, textPainter, 'Balcony', Offset(size.width * 0.77, size.height * 0.53));
    _drawLabel(canvas, textPainter, 'Utility', Offset(size.width * 0.56, size.height * 0.44));
  }

  void _drawLabel(Canvas canvas, TextPainter painter, String text, Offset offset) {
    painter.text = TextSpan(
      text: text,
      style: const TextStyle(
        color: AppColors.primaryDarkText,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
    painter.layout();
    final bubble = RRect.fromRectAndRadius(
      Rect.fromCenter(center: offset, width: painter.width + 14, height: painter.height + 8),
      const Radius.circular(999),
    );
    final bgPaint = Paint()..color = AppColors.white.withOpacity(0.92);
    final borderPaint = Paint()
      ..color = AppColors.lightLavender.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(bubble, bgPaint);
    canvas.drawRRect(bubble, borderPaint);
    painter.paint(canvas, offset - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OwnerInfoCard extends StatelessWidget {
  final PropertyOwnerEntity owner;
  final bool contactUnlocked;

  const _OwnerInfoCard({
    required this.owner,
    required this.contactUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.veryLightPurpleBg,
          child: Text(
            owner.name.split(' ').map((part) => part[0]).take(2).join(),
            style: const TextStyle(
              color: AppColors.mainPurple,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      owner.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkText,
                      ),
                    ),
                  ),
                  if (owner.isVerified)
                    const Icon(Icons.verified, color: AppColors.cyanBlue, size: 18),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                owner.company,
                style: const TextStyle(color: AppColors.secondaryGrayText),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    owner.rating.toStringAsFixed(1),
                    style: const TextStyle(color: AppColors.primaryDarkText),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    contactUnlocked ? owner.phoneNumber : 'Hidden on free plan',
                    style: const TextStyle(color: AppColors.secondaryGrayText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NearbyPlacesList extends StatelessWidget {
  final List<NearbyPlaceEntity> places;

  const _NearbyPlacesList({required this.places});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: places
          .map(
            (place) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NearbyPlaceTile(place: place),
            ),
          )
          .toList(),
    );
  }
}

class _NearbyPlaceTile extends StatelessWidget {
  final NearbyPlaceEntity place;

  const _NearbyPlaceTile({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.veryLightPurpleBg,
            child: Icon(
              place.category == 'Transit'
                  ? Icons.directions_subway
                  : place.category == 'Healthcare'
                      ? Icons.local_hospital_outlined
                      : place.category == 'Education'
                          ? Icons.school_outlined
                          : Icons.shopping_bag_outlined,
              size: 18,
              color: AppColors.mainPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  place.category,
                  style: const TextStyle(
                    color: AppColors.secondaryGrayText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${place.distanceKm.toStringAsFixed(1)} km • ${place.travelTimeMins} min',
            style: const TextStyle(
              color: AppColors.secondaryGrayText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final List<PropertyReviewEntity> reviews;

  const _ReviewsList({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reviews
          .map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReviewTile(review: review),
            ),
          )
          .toList(),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final PropertyReviewEntity review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkText,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(review.rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review.dateLabel,
            style: const TextStyle(
              color: AppColors.secondaryGrayText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(
              color: AppColors.primaryDarkText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceHistoryChart extends StatelessWidget {
  final List<PriceHistoryPointEntity> points;

  const _PriceHistoryChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.75,
      child: CustomPaint(
        painter: _PriceHistoryPainter(points),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: points
                  .map(
                    (point) => Text(
                      point.label,
                      style: const TextStyle(
                        color: AppColors.secondaryGrayText,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceHistoryPainter extends CustomPainter {
  final List<PriceHistoryPointEntity> points;

  _PriceHistoryPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final chartRect = Rect.fromLTWH(16, 16, size.width - 32, size.height - 44);
    final minPrice = points.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final maxPrice = points.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    final range = (maxPrice - minPrice).abs() < 0.001 ? 1.0 : maxPrice - minPrice;

    final gridPaint = Paint()
      ..color = AppColors.borderGray
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = chartRect.top + (chartRect.height / 3) * i;
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = AppColors.mainPurple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x556C63FF), Color(0x006C63FF)],
      ).createShader(chartRect);

    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = chartRect.left + (chartRect.width / (points.length - 1)) * i;
      final normalized = (points[i].price - minPrice) / range;
      final y = chartRect.bottom - (normalized * chartRect.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.mainPurple);
    }
    fillPath
      ..lineTo(chartRect.right, chartRect.bottom)
      ..lineTo(chartRect.left, chartRect.bottom)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PriceHistoryPainter oldDelegate) => oldDelegate.points != points;
}

class _SimilarListings extends StatelessWidget {
  final List<ListingEntity> listings;
  final ContactAccessPlan contactAccessPlan;

  const _SimilarListings({
    required this.listings,
    required this.contactAccessPlan,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: listings.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final listing = listings[index];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyDetailsPage(
                  listing: listing,
                  contactAccessPlan: contactAccessPlan,
                ),
              ),
            ),
            child: _SimilarListingCard(listing: listing),
          );
        },
      ),
    );
  }
}

class _SimilarListingCard extends StatelessWidget {
  final ListingEntity listing;

  const _SimilarListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 104,
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: Icon(Icons.home_rounded, color: AppColors.white, size: 38),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${listing.locality}, ${listing.city}',
                  style: const TextStyle(
                    color: AppColors.secondaryGrayText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  listing.listingFor == 'rent'
                      ? '₹${listing.price.toInt()}/mo'
                      : '₹${(listing.price / 100000).toStringAsFixed(1)} L',
                  style: const TextStyle(
                    color: AppColors.mainPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.veryLightPurpleBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.mainPurple),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkText,
            ),
          ),
        ],
      ),
    );
  }
}
