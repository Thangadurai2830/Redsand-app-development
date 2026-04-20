import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/filter_bloc.dart';
import '../../domain/entities/filter_entity.dart';

class FilterPage extends StatefulWidget {
  final FilterEntity initialFilter;

  const FilterPage({super.key, required this.initialFilter});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late RangeValues _priceRange;
  String? _selectedType;
  int? _selectedBedrooms;
  String _sortBy = 'newest';

  static const double _rentMin = 0;
  static const double _rentMax = 200000;
  static const double _buyMin = 0;
  static const double _buyMax = 50000000;

  bool get _isRent => widget.initialFilter.listingFor == 'rent';

  double get _rangeMin => _isRent ? _rentMin : _buyMin;
  double get _rangeMax => _isRent ? _rentMax : _buyMax;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilter.propertyType;
    _selectedBedrooms = widget.initialFilter.minBedrooms;
    _sortBy = widget.initialFilter.sortBy;
    _priceRange = RangeValues(
      widget.initialFilter.minPrice ?? _rangeMin,
      widget.initialFilter.maxPrice ?? _rangeMax,
    );
  }

  String _formatPrice(double value) {
    if (!_isRent) {
      if (value >= 10000000) return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
      if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(0)}L';
      return '₹${value.toInt()}';
    }
    if (value >= 100000) return '₹${(value / 1000).toStringAsFixed(0)}K/mo';
    return '₹${value.toInt()}/mo';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FilterBloc(),
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBg,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.primaryDarkText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Filters',
            style: TextStyle(
              color: AppColors.primaryDarkText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _resetAll,
              child: const Text(
                'Reset All',
                style: TextStyle(
                  color: AppColors.mainPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: 'Property Type',
                      child: _buildPropertyTypeSelector(),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Price Range',
                      child: _buildPriceRange(),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Bedrooms',
                      child: _buildBedroomsSelector(),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Sort By',
                      child: _buildSortSelector(),
                    ),
                  ],
                ),
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTypeSelector() {
    const types = ['apartment', 'villa', 'pg', 'commercial'];
    const labels = ['Apartment', 'Villa', 'PG', 'Commercial'];
    const icons = [
      Icons.apartment,
      Icons.villa,
      Icons.bed,
      Icons.business,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(types.length, (i) {
        final isSelected = _selectedType == types[i];
        return GestureDetector(
          onTap: () => setState(() {
            _selectedType = isSelected ? null : types[i];
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.mainPurple : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.mainPurple : AppColors.borderGray,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icons[i],
                  size: 16,
                  color: isSelected ? AppColors.white : AppColors.secondaryGrayText,
                ),
                const SizedBox(width: 6),
                Text(
                  labels[i],
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.primaryDarkText,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPriceRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatPrice(_priceRange.start),
              style: const TextStyle(
                color: AppColors.mainPurple,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              _formatPrice(_priceRange.end),
              style: const TextStyle(
                color: AppColors.mainPurple,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.mainPurple,
            inactiveTrackColor: AppColors.lightLavender,
            thumbColor: AppColors.mainPurple,
            overlayColor: AppColors.mainPurple.withOpacity(0.1),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: _rangeMin,
            max: _rangeMax,
            divisions: 100,
            onChanged: (v) => setState(() => _priceRange = v),
          ),
        ),
      ],
    );
  }

  Widget _buildBedroomsSelector() {
    const options = [1, 2, 3, 4, 5];
    return Row(
      children: options.map((n) {
        final isSelected = _selectedBedrooms == n;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedBedrooms = isSelected ? null : n;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mainPurple : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.mainPurple : AppColors.borderGray,
                ),
              ),
              child: Center(
                child: Text(
                  n == 5 ? '5+' : '$n',
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.primaryDarkText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSortSelector() {
    const options = [
      ('newest', 'Newest First', Icons.schedule),
      ('price_asc', 'Price: Low to High', Icons.arrow_upward),
      ('price_desc', 'Price: High to Low', Icons.arrow_downward),
    ];

    return Column(
      children: options.map((opt) {
        final isSelected = _sortBy == opt.$1;
        return GestureDetector(
          onTap: () => setState(() => _sortBy = opt.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.veryLightPurpleBg : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.mainPurple : AppColors.borderGray,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  opt.$3,
                  size: 18,
                  color: isSelected ? AppColors.mainPurple : AppColors.secondaryGrayText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    opt.$2,
                    style: TextStyle(
                      color: isSelected ? AppColors.mainPurple : AppColors.primaryDarkText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.mainPurple,
                    size: 18,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextButton(
            onPressed: _applyFilters,
            child: const Text(
              'Apply Filters',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetAll() {
    setState(() {
      _selectedType = null;
      _selectedBedrooms = null;
      _sortBy = 'newest';
      _priceRange = RangeValues(_rangeMin, _rangeMax);
    });
  }

  void _applyFilters() {
    final filter = widget.initialFilter.copyWith(
      propertyType: _selectedType,
      minPrice: _priceRange.start > _rangeMin ? _priceRange.start : null,
      maxPrice: _priceRange.end < _rangeMax ? _priceRange.end : null,
      minBedrooms: _selectedBedrooms,
      sortBy: _sortBy,
      clearPropertyType: _selectedType == null,
      clearMinPrice: _priceRange.start <= _rangeMin,
      clearMaxPrice: _priceRange.end >= _rangeMax,
      clearMinBedrooms: _selectedBedrooms == null,
    );
    Navigator.of(context).pop(filter);
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryDarkText,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
