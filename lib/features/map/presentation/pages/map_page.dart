import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/listing_entity.dart';

class MapPage extends StatelessWidget {
  final List<ListingEntity> listings;

  const MapPage({super.key, required this.listings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Map View',
          style: TextStyle(
            color: AppColors.primaryDarkText,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${listings.length} properties',
                style: const TextStyle(
                  color: AppColors.secondaryGrayText,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE8F4F8), Color(0xFFD0E8F0)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.mainPurple.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            size: 40,
                            color: AppColors.mainPurple,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Map Integration',
                          style: TextStyle(
                            color: AppColors.primaryDarkText,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add google_maps_flutter to pubspec.yaml\nto enable interactive map view',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondaryGrayText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ..._buildMockPins(),
              ],
            ),
          ),
          _buildListingPreview(context),
        ],
      ),
    );
  }

  List<Widget> _buildMockPins() {
    const positions = [
      Offset(0.25, 0.3),
      Offset(0.6, 0.45),
      Offset(0.4, 0.6),
      Offset(0.7, 0.25),
      Offset(0.15, 0.65),
    ];
    return List.generate(
      positions.length.clamp(0, listings.length),
      (i) => FractionalOffset(positions[i].dx, positions[i].dy).let(
        (pos) => Positioned(
          left: null,
          top: null,
          child: Align(
            alignment: FractionalOffset(positions[i].dx, positions[i].dy),
            child: _PricePin(listing: listings[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildListingPreview(BuildContext context) {
    if (listings.isEmpty) return const SizedBox.shrink();
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nearby Properties',
            style: TextStyle(
              color: AppColors.primaryDarkText,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: listings.length,
              itemBuilder: (_, i) => _MiniCard(listing: listings[i]),
            ),
          ),
        ],
      ),
    );
  }
}

extension _LetExt<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

class _PricePin extends StatelessWidget {
  final ListingEntity listing;
  const _PricePin({required this.listing});

  String get _priceLabel {
    if (listing.listingFor == 'rent') {
      return '₹${(listing.price / 1000).toStringAsFixed(0)}K';
    }
    if (listing.price >= 10000000) {
      return '₹${(listing.price / 10000000).toStringAsFixed(1)}Cr';
    }
    return '₹${(listing.price / 100000).toStringAsFixed(0)}L';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.mainPurple,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainPurple.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            _priceLabel,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(12, 6),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.mainPurple;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MiniCard extends StatelessWidget {
  final ListingEntity listing;
  const _MiniCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.veryLightPurpleBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightLavender),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home, color: Colors.white54, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    color: AppColors.primaryDarkText,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  listing.locality,
                  style: const TextStyle(
                    color: AppColors.secondaryGrayText,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
