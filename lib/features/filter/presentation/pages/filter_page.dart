import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/filter_entity.dart';
import '../widgets/filter_option_chip.dart';
import '../widgets/filter_section_card.dart';

class FilterPage extends StatefulWidget {
  final FilterEntity initialFilter;

  const FilterPage({super.key, required this.initialFilter});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late RangeValues _budgetRange;
  late int? _selectedBhk;
  late String? _selectedPropertyType;
  late String? _selectedFurnishing;
  late List<String> _selectedAmenities;
  late final TextEditingController _cityController;
  late final TextEditingController _localityController;
  late String _sortBy;

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
    _selectedPropertyType = widget.initialFilter.propertyType;
    _selectedFurnishing = widget.initialFilter.furnishing;
    _selectedAmenities = List<String>.from(widget.initialFilter.amenities);
    _selectedBhk = widget.initialFilter.minBedrooms;
    _sortBy = widget.initialFilter.sortBy;
    _cityController = TextEditingController(text: widget.initialFilter.city ?? '');
    _localityController = TextEditingController(text: widget.initialFilter.locality ?? '');
    _cityController.addListener(_onTextChanged);
    _localityController.addListener(_onTextChanged);
    _budgetRange = RangeValues(
      widget.initialFilter.minPrice ?? _rangeMin,
      widget.initialFilter.maxPrice ?? _rangeMax,
    );
  }

  @override
  void dispose() {
    _cityController.removeListener(_onTextChanged);
    _localityController.removeListener(_onTextChanged);
    _cityController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
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

  int get _activeFilterCount {
    var count = 0;
    if (_selectedPropertyType != null) count++;
    if (_selectedFurnishing != null) count++;
    if (_selectedAmenities.isNotEmpty) count++;
    if (_selectedBhk != null) count++;
    if (_cityController.text.trim().isNotEmpty) count++;
    if (_localityController.text.trim().isNotEmpty) count++;
    if (_budgetRange.start > _rangeMin || _budgetRange.end < _rangeMax) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: AppColors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.veryLightPurpleBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _activeFilterCount == 0
                        ? 'No filters applied'
                        : '$_activeFilterCount filters selected',
                    style: const TextStyle(
                      color: AppColors.mainPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.initialFilter.listingFor == 'rent' ? 'For Rent' : 'For Buy',
                  style: const TextStyle(
                    color: AppColors.secondaryGrayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  FilterSectionCard(
                    title: 'Budget',
                    child: _buildBudgetSection(),
                  ),
                  const SizedBox(height: 12),
                  FilterSectionCard(
                    title: 'BHK',
                    child: _buildBhkSection(),
                  ),
                  const SizedBox(height: 12),
                  FilterSectionCard(
                    title: 'Property Type',
                    child: _buildPropertyTypeSection(),
                  ),
                  const SizedBox(height: 12),
                  FilterSectionCard(
                    title: 'Furnishing',
                    child: _buildFurnishingSection(),
                  ),
                  const SizedBox(height: 12),
                  FilterSectionCard(
                    title: 'Amenities',
                    child: _buildAmenitiesSection(),
                  ),
                  const SizedBox(height: 12),
                  FilterSectionCard(
                    title: 'City',
                    child: _buildTextInput(
                      controller: _cityController,
                      hintText: 'Enter city',
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilterSectionCard(
                    title: 'Locality',
                    child: _buildTextInput(
                      controller: _localityController,
                      hintText: 'Enter locality or area',
                      icon: Icons.place_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilterSectionCard(
                    title: 'Sort By',
                    child: _buildSortSection(),
                  ),
                ],
              ),
            ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatPrice(_budgetRange.start),
              style: const TextStyle(
                color: AppColors.mainPurple,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              _formatPrice(_budgetRange.end),
              style: const TextStyle(
                color: AppColors.mainPurple,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.mainPurple,
            inactiveTrackColor: AppColors.lightLavender,
            thumbColor: AppColors.mainPurple,
            overlayColor: AppColors.mainPurple.withOpacity(0.1),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: _budgetRange,
            min: _rangeMin,
            max: _rangeMax,
            divisions: 100,
            onChanged: (value) => setState(() => _budgetRange = value),
          ),
        ),
      ],
    );
  }

  Widget _buildBhkSection() {
    const bhkOptions = [1, 2, 3, 4, 5];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: bhkOptions.map((value) {
        final selected = _selectedBhk == value;
        return FilterOptionChip(
          label: value == 5 ? '5+ BHK' : '$value BHK',
          selected: selected,
          onTap: () => setState(() {
            _selectedBhk = selected ? null : value;
          }),
        );
      }).toList(),
    );
  }

  Widget _buildPropertyTypeSection() {
    const options = [
      ('apartment', 'Apartment', Icons.apartment),
      ('villa', 'Villa', Icons.villa),
      ('pg', 'PG', Icons.bed),
      ('commercial', 'Commercial', Icons.business),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final selected = _selectedPropertyType == option.$1;
        return FilterOptionChip(
          label: option.$2,
          selected: selected,
          icon: option.$3,
          onTap: () => setState(() {
            _selectedPropertyType = selected ? null : option.$1;
          }),
        );
      }).toList(),
    );
  }

  Widget _buildFurnishingSection() {
    const options = [
      ('unfurnished', 'Unfurnished'),
      ('semi_furnished', 'Semi-furnished'),
      ('furnished', 'Furnished'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final selected = _selectedFurnishing == option.$1;
        return FilterOptionChip(
          label: option.$2,
          selected: selected,
          onTap: () => setState(() {
            _selectedFurnishing = selected ? null : option.$1;
          }),
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesSection() {
    const options = [
      ('parking', 'Parking', Icons.local_parking_outlined),
      ('gym', 'Gym', Icons.fitness_center_outlined),
      ('pool', 'Pool', Icons.pool_outlined),
      ('security', 'Security', Icons.security_outlined),
      ('lift', 'Lift', Icons.arrow_upward),
      ('power_backup', 'Power Backup', Icons.battery_charging_full),
      ('clubhouse', 'Clubhouse', Icons.business),
      ('cctv', 'CCTV', Icons.videocam),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final selected = _selectedAmenities.contains(option.$1);
        return FilterOptionChip(
          label: option.$2,
          selected: selected,
          icon: option.$3,
          onTap: () => setState(() {
            if (selected) {
              _selectedAmenities.remove(option.$1);
            } else {
              _selectedAmenities.add(option.$1);
            }
          }),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, size: 18, color: AppColors.secondaryGrayText),
        filled: true,
        fillColor: AppColors.lightGrayBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildSortSection() {
    const options = [
      ('newest', 'Newest First', Icons.schedule),
      ('price_asc', 'Price: Low to High', Icons.arrow_upward),
      ('price_desc', 'Price: High to Low', Icons.arrow_downward),
    ];

    return Column(
      children: options.map((option) {
        final selected = _sortBy == option.$1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() => _sortBy = option.$1),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.veryLightPurpleBg : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.mainPurple : AppColors.borderGray,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    option.$3,
                    size: 18,
                    color: selected ? AppColors.mainPurple : AppColors.secondaryGrayText,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option.$2,
                      style: TextStyle(
                        color: selected ? AppColors.mainPurple : AppColors.primaryDarkText,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.mainPurple,
                      size: 18,
                    ),
                ],
              ),
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
      _selectedPropertyType = null;
      _selectedFurnishing = null;
      _selectedAmenities = [];
      _selectedBhk = null;
      _sortBy = 'newest';
      _cityController.clear();
      _localityController.clear();
      _budgetRange = RangeValues(_rangeMin, _rangeMax);
    });
  }

  void _applyFilters() {
    final city = _cityController.text.trim();
    final locality = _localityController.text.trim();

    final filter = widget.initialFilter.copyWith(
      propertyType: _selectedPropertyType,
      furnishing: _selectedFurnishing,
      amenities: _selectedAmenities,
      city: city.isEmpty ? null : city,
      locality: locality.isEmpty ? null : locality,
      minPrice: _budgetRange.start > _rangeMin ? _budgetRange.start : null,
      maxPrice: _budgetRange.end < _rangeMax ? _budgetRange.end : null,
      minBedrooms: _selectedBhk,
      sortBy: _sortBy,
      clearPropertyType: _selectedPropertyType == null,
      clearFurnishing: _selectedFurnishing == null,
      clearAmenities: _selectedAmenities.isEmpty,
      clearCity: city.isEmpty,
      clearLocality: locality.isEmpty,
      clearMinPrice: _budgetRange.start <= _rangeMin,
      clearMaxPrice: _budgetRange.end >= _rangeMax,
      clearMinBedrooms: _selectedBhk == null,
    );

    Navigator.of(context).pop(filter);
  }
}
