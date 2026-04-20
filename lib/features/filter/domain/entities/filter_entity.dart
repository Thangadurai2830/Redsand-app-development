import 'package:equatable/equatable.dart';

class FilterEntity extends Equatable {
  final String listingFor; // rent, buy
  final String? propertyType; // apartment, villa, pg, commercial
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final double? minAreaSqft;
  final String sortBy; // newest, price_asc, price_desc

  const FilterEntity({
    this.listingFor = 'rent',
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minAreaSqft,
    this.sortBy = 'newest',
  });

  FilterEntity copyWith({
    String? listingFor,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    double? minAreaSqft,
    String? sortBy,
    bool clearPropertyType = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinBedrooms = false,
    bool clearMinAreaSqft = false,
  }) {
    return FilterEntity(
      listingFor: listingFor ?? this.listingFor,
      propertyType: clearPropertyType ? null : (propertyType ?? this.propertyType),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minBedrooms: clearMinBedrooms ? null : (minBedrooms ?? this.minBedrooms),
      minAreaSqft: clearMinAreaSqft ? null : (minAreaSqft ?? this.minAreaSqft),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      propertyType != null ||
      minPrice != null ||
      maxPrice != null ||
      minBedrooms != null ||
      minAreaSqft != null;

  @override
  List<Object?> get props => [
        listingFor,
        propertyType,
        minPrice,
        maxPrice,
        minBedrooms,
        minAreaSqft,
        sortBy,
      ];
}
