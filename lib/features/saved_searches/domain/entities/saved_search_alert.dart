import 'package:equatable/equatable.dart';

import '../../../filter/domain/entities/filter_entity.dart';

class SavedSearchAlert extends Equatable {
  final String id;
  final String query;
  final FilterEntity filter;
  final bool notifyByPush;
  final bool notifyInApp;
  final bool priceDropAlert;
  final DateTime savedAt;
  final int newMatchCount;
  final DateTime? lastMatchedAt;

  const SavedSearchAlert({
    required this.id,
    required this.query,
    required this.filter,
    required this.savedAt,
    this.notifyByPush = true,
    this.notifyInApp = true,
    this.priceDropAlert = false,
    this.newMatchCount = 0,
    this.lastMatchedAt,
  });

  bool get hasNotificationChannels => notifyByPush || notifyInApp;

  String get searchLabel {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) return trimmedQuery;
    if (filter.hasActiveFilters) return 'Filtered search';
    return 'Saved search';
  }

  @override
  List<Object?> get props => [
        id,
        query,
        filter,
        notifyByPush,
        notifyInApp,
        priceDropAlert,
        savedAt,
        newMatchCount,
        lastMatchedAt,
      ];
}
