import 'package:equatable/equatable.dart';
import '../../../filter/domain/entities/filter_entity.dart';

abstract class SearchResultEvent extends Equatable {
  const SearchResultEvent();
  @override
  List<Object?> get props => [];
}

class SearchResultLoad extends SearchResultEvent {
  final String query;
  final FilterEntity filter;

  const SearchResultLoad({required this.query, required this.filter});

  @override
  List<Object?> get props => [query, filter];
}

class SearchResultFilterChanged extends SearchResultEvent {
  final FilterEntity filter;
  const SearchResultFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchResultSortChanged extends SearchResultEvent {
  final String sortBy;
  const SearchResultSortChanged(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class SearchResultToggleSaved extends SearchResultEvent {
  final String listingId;
  const SearchResultToggleSaved(this.listingId);

  @override
  List<Object?> get props => [listingId];
}
