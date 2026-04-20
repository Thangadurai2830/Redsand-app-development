import 'package:equatable/equatable.dart';

abstract class FilterEvent extends Equatable {
  const FilterEvent();
  @override
  List<Object?> get props => [];
}

class FilterUpdated extends FilterEvent {
  final String? listingFor;
  final String? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final double? minAreaSqft;
  final String? sortBy;
  final bool clearPropertyType;
  final bool clearMinPrice;
  final bool clearMaxPrice;
  final bool clearMinBedrooms;
  final bool clearMinAreaSqft;

  const FilterUpdated({
    this.listingFor,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minAreaSqft,
    this.sortBy,
    this.clearPropertyType = false,
    this.clearMinPrice = false,
    this.clearMaxPrice = false,
    this.clearMinBedrooms = false,
    this.clearMinAreaSqft = false,
  });

  @override
  List<Object?> get props => [
        listingFor, propertyType, minPrice, maxPrice,
        minBedrooms, minAreaSqft, sortBy,
        clearPropertyType, clearMinPrice, clearMaxPrice,
        clearMinBedrooms, clearMinAreaSqft,
      ];
}

class FilterReset extends FilterEvent {
  const FilterReset();
}

class FilterApplied extends FilterEvent {
  const FilterApplied();
}
