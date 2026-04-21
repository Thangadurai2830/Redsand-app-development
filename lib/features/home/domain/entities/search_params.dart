import 'package:equatable/equatable.dart';
import '../../../filter/domain/entities/filter_entity.dart';

class SearchParams extends Equatable {
  final String query;
  final String listingFor;
  final FilterEntity filter;

  const SearchParams({
    required this.query,
    required this.listingFor,
    this.filter = const FilterEntity(),
  });

  @override
  List<Object?> get props => [query, listingFor, filter];
}
