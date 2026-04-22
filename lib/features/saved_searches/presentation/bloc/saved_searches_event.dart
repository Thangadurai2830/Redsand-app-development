import 'package:equatable/equatable.dart';

import '../../../filter/domain/entities/filter_entity.dart';
abstract class SavedSearchesEvent extends Equatable {
  const SavedSearchesEvent();

  @override
  List<Object?> get props => [];
}

class SavedSearchesLoadRequested extends SavedSearchesEvent {
  const SavedSearchesLoadRequested();
}

class SavedSearchesRefreshRequested extends SavedSearchesEvent {
  const SavedSearchesRefreshRequested();
}

class SavedSearchesSaveRequested extends SavedSearchesEvent {
  final String query;
  final FilterEntity filter;
  final bool notifyByPush;
  final bool notifyInApp;
  final bool priceDropAlert;

  const SavedSearchesSaveRequested({
    required this.query,
    required this.filter,
    required this.notifyByPush,
    required this.notifyInApp,
    required this.priceDropAlert,
  });

  @override
  List<Object?> get props => [query, filter, notifyByPush, notifyInApp, priceDropAlert];
}

class SavedSearchesRemoveRequested extends SavedSearchesEvent {
  final String id;

  const SavedSearchesRemoveRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class SavedSearchesClearMessageRequested extends SavedSearchesEvent {
  const SavedSearchesClearMessageRequested();
}
