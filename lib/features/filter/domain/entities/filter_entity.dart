import 'package:equatable/equatable.dart';

class FilterEntity extends Equatable {
  final String listingFor; // rent, buy
  final String? propertyType; // apartment, villa, pg, commercial
  final String? furnishing; // unfurnished, semi_furnished, furnished
  final List<String> amenities;
  final String? city;
  final String? locality;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final double? minAreaSqft;
  final String sortBy; // newest, price_asc, price_desc

  const FilterEntity({
    this.listingFor = 'rent',
    this.propertyType,
    this.furnishing,
    this.amenities = const [],
    this.city,
    this.locality,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minAreaSqft,
    this.sortBy = 'newest',
  });

  FilterEntity copyWith({
    String? listingFor,
    String? propertyType,
    String? furnishing,
    List<String>? amenities,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    double? minAreaSqft,
    String? sortBy,
    bool clearPropertyType = false,
    bool clearFurnishing = false,
    bool clearAmenities = false,
    bool clearCity = false,
    bool clearLocality = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinBedrooms = false,
    bool clearMinAreaSqft = false,
  }) {
    return FilterEntity(
      listingFor: listingFor ?? this.listingFor,
      propertyType: clearPropertyType ? null : (propertyType ?? this.propertyType),
      furnishing: clearFurnishing ? null : (furnishing ?? this.furnishing),
      amenities: clearAmenities ? const <String>[] : (amenities ?? this.amenities),
      city: clearCity ? null : (city ?? this.city),
      locality: clearLocality ? null : (locality ?? this.locality),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minBedrooms: clearMinBedrooms ? null : (minBedrooms ?? this.minBedrooms),
      minAreaSqft: clearMinAreaSqft ? null : (minAreaSqft ?? this.minAreaSqft),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      propertyType != null ||
      furnishing != null ||
      amenities.isNotEmpty ||
      city != null ||
      locality != null ||
      minPrice != null ||
      maxPrice != null ||
      minBedrooms != null ||
      minAreaSqft != null;

  Map<String, dynamic> toQueryParameters() {
    return {
      'listing_for': listingFor,
      if (propertyType != null) 'property_type': propertyType,
      if (furnishing != null) 'furnishing': furnishing,
      if (amenities.isNotEmpty) 'amenities': amenities.join(','),
      if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
      if (locality != null && locality!.trim().isNotEmpty) 'locality': locality!.trim(),
      if (minPrice != null) 'budget_min': minPrice,
      if (maxPrice != null) 'budget_max': maxPrice,
      if (minBedrooms != null) 'bhk': minBedrooms,
      if (minAreaSqft != null) 'area_min_sqft': minAreaSqft,
      'sort_by': sortBy,
    };
  }

  @override
  List<Object?> get props => [
        listingFor,
        propertyType,
        furnishing,
        amenities,
        city,
        locality,
        minPrice,
        maxPrice,
        minBedrooms,
        minAreaSqft,
        sortBy,
      ];
}
