import 'package:equatable/equatable.dart';
import '../../../filter/domain/entities/filter_entity.dart';
import '../../../home/domain/entities/listing_entity.dart';

abstract class SearchResultState extends Equatable {
  const SearchResultState();
  @override
  List<Object?> get props => [];
}

class SearchResultInitial extends SearchResultState {
  const SearchResultInitial();
}

class SearchResultLoading extends SearchResultState {
  const SearchResultLoading();
}

class SearchResultLoaded extends SearchResultState {
  final List<ListingEntity> listings;
  final String query;
  final FilterEntity filter;
  final Set<String> savedIds;

  const SearchResultLoaded({
    required this.listings,
    required this.query,
    required this.filter,
    this.savedIds = const {},
  });

  List<ListingEntity> get sorted {
    final list = List<ListingEntity>.from(listings);
    switch (filter.sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        break;
    }
    return list;
  }

  SearchResultLoaded copyWith({
    List<ListingEntity>? listings,
    String? query,
    FilterEntity? filter,
    Set<String>? savedIds,
  }) {
    return SearchResultLoaded(
      listings: listings ?? this.listings,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      savedIds: savedIds ?? this.savedIds,
    );
  }

  @override
  List<Object?> get props => [listings, query, filter, savedIds];
}

class SearchResultError extends SearchResultState {
  final String message;
  const SearchResultError(this.message);

  @override
  List<Object?> get props => [message];
}
