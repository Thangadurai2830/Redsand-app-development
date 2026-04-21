import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../home/domain/entities/listing_entity.dart';
import '../../../../property_details/presentation/pages/property_details_page.dart';
import '../../../domain/entities/saved_listing_entity.dart';
import '../../widgets/compare/saved_listings_compare_widgets.dart';

class SavedListingsComparePage extends StatelessWidget {
  final List<SavedListingEntity> listings;

  const SavedListingsComparePage({
    super.key,
    required this.listings,
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.lightGrayBg,
        appBar: AppBar(
          title: const Text('Compare Listings'),
          backgroundColor: AppColors.deepRoyalPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Select at least two saved properties to compare them.',
            style: TextStyle(color: AppColors.secondaryGrayText),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        title: const Text('Compare Listings'),
        backgroundColor: AppColors.deepRoyalPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = math.max(
              constraints.maxWidth - 32,
              140 + (listings.length * 232.0),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompareIntro(count: listings.length),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 250,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: listings.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (_, index) => CompareListingCard(
                                entry: listings[index],
                                onOpenDetail: () => _openDetails(context, listings[index].listing),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CompareSectionCard(
                            title: 'Core comparison',
                            subtitle: 'Price, size, and location side by side',
                            child: Column(
                              children: [
                                CompareFieldRow(
                                  label: 'Price',
                                  cells: listings.map((entry) => CompareValueCell(
                                    text: _priceLabel(entry.listing),
                                    emphasized: true,
                                  )).toList(),
                                ),
                                const SizedBox(height: 10),
                                CompareFieldRow(
                                  label: 'BHK',
                                  cells: listings.map((entry) => CompareValueCell(
                                    text: '${entry.listing.bedrooms} BHK',
                                  )).toList(),
                                ),
                                const SizedBox(height: 10),
                                CompareFieldRow(
                                  label: 'Size',
                                  cells: listings.map((entry) => CompareValueCell(
                                    text: '${entry.listing.areaSqft.toInt()} sqft',
                                  )).toList(),
                                ),
                                const SizedBox(height: 10),
                                CompareFieldRow(
                                  label: 'Location',
                                  cells: listings.map((entry) => CompareValueCell(
                                    text: '${entry.listing.locality}, ${entry.listing.city}',
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          CompareSectionCard(
                            title: 'Amenities',
                            subtitle: 'What each home includes',
                            child: CompareFieldRow(
                              label: 'Amenities',
                              cells: listings.map((entry) => CompareAmenitiesCell(
                                amenities: entry.listing.amenities,
                              )).toList(),
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
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, ListingEntity listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailsPage(listing: listing),
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
}

class _CompareIntro extends StatelessWidget {
  final int count;

  const _CompareIntro({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.softLavender,
            AppColors.mainPurple.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Side-by-side comparison',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count saved properties selected. Compare price, BHK, size, amenities, and location before opening full details.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
