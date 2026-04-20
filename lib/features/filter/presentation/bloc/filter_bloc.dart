import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/filter_entity.dart';
import 'filter_event.dart';
import 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc()
      : super(const FilterInitial(filter: FilterEntity())) {
    on<FilterUpdated>(_onFilterUpdated);
    on<FilterReset>(_onFilterReset);
    on<FilterApplied>(_onFilterApplied);
  }

  FilterEntity get _currentFilter {
    final s = state;
    if (s is FilterInitial) return s.filter;
    if (s is FilterChanged) return s.filter;
    if (s is FilterAppliedState) return s.filter;
    return const FilterEntity();
  }

  void _onFilterUpdated(FilterUpdated event, Emitter<FilterState> emit) {
    final updated = _currentFilter.copyWith(
      listingFor: event.listingFor,
      propertyType: event.propertyType,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      minBedrooms: event.minBedrooms,
      minAreaSqft: event.minAreaSqft,
      sortBy: event.sortBy,
      clearPropertyType: event.clearPropertyType,
      clearMinPrice: event.clearMinPrice,
      clearMaxPrice: event.clearMaxPrice,
      clearMinBedrooms: event.clearMinBedrooms,
      clearMinAreaSqft: event.clearMinAreaSqft,
    );
    emit(FilterChanged(filter: updated));
  }

  void _onFilterReset(FilterReset event, Emitter<FilterState> emit) {
    emit(const FilterInitial(filter: FilterEntity()));
  }

  void _onFilterApplied(FilterApplied event, Emitter<FilterState> emit) {
    emit(FilterAppliedState(filter: _currentFilter));
  }
}
