import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/saved_listing_entity.dart';

class CompareSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const CompareSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class CompareFieldRow extends StatelessWidget {
  final String label;
  final List<Widget> cells;
  final double labelWidth;
  final double cellWidth;

  const CompareFieldRow({
    super.key,
    required this.label,
    required this.cells,
    this.labelWidth = 108,
    this.cellWidth = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryGrayText,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
        ...cells.map(
          (cell) => SizedBox(
            width: cellWidth,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: cell,
            ),
          ),
        ),
      ],
    );
  }
}

class CompareListingCard extends StatelessWidget {
  final SavedListingEntity entry;
  final VoidCallback onOpenDetail;

  const CompareListingCard({
    super.key,
    required this.entry,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final listing = entry.listing;
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.softLavender,
                  AppColors.cyanBlue.withOpacity(0.92),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Icon(Icons.home_rounded, size: 42, color: AppColors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${listing.locality}, ${listing.city}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryGrayText,
                  ),
                ),
                const SizedBox(height: 10),
                _ValueBadge(
                  text: listing.listingFor == 'rent'
                      ? '₹${listing.price.toInt()}/mo'
                      : listing.price >= 10000000
                          ? '₹${(listing.price / 10000000).toStringAsFixed(1)} Cr'
                          : '₹${(listing.price / 100000).toStringAsFixed(1)} L',
                  emphasized: true,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onOpenDetail,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Open detail'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepRoyalPurple,
                      side: const BorderSide(color: AppColors.borderGray),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

class CompareValueCell extends StatelessWidget {
  final String text;
  final bool emphasized;

  const CompareValueCell({
    super.key,
    required this.text,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasized ? AppColors.veryLightPurpleBg : AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: emphasized ? AppColors.mainPurple : AppColors.primaryDarkText,
          fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
          fontSize: 13,
          height: 1.35,
        ),
      ),
    );
  }
}

class CompareAmenitiesCell extends StatelessWidget {
  final List<String> amenities;

  const CompareAmenitiesCell({super.key, required this.amenities});

  @override
  Widget build(BuildContext context) {
    final content = amenities.isEmpty
        ? const Text(
            'Amenities not listed',
            style: TextStyle(
              color: AppColors.secondaryGrayText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          )
        : Wrap(
            spacing: 6,
            runSpacing: 6,
            children: amenities
                .map(
                  (amenity) => _ValueBadge(text: amenity),
                )
                .toList(),
          );

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: content,
    );
  }
}

class _ValueBadge extends StatelessWidget {
  final String text;
  final bool emphasized;

  const _ValueBadge({
    required this.text,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: emphasized ? AppColors.mainPurple : AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasized ? AppColors.mainPurple : AppColors.borderGray,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: emphasized ? AppColors.white : AppColors.primaryDarkText,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
