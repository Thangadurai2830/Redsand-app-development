import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  final String listingFor;
  const LoadHomeData({this.listingFor = 'rent'});

  @override
  List<Object?> get props => [listingFor];
}

class ToggleListingFor extends HomeEvent {
  final String listingFor;
  const ToggleListingFor(this.listingFor);

  @override
  List<Object?> get props => [listingFor];
}

class SearchQueryChanged extends HomeEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SubmitSearch extends HomeEvent {
  final String query;
  const SubmitSearch(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends HomeEvent {
  const ClearSearch();
}
