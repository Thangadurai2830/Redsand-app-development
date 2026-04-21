import 'package:equatable/equatable.dart';

import '../../domain/entities/saved_search_alert.dart';

enum SavedSearchesStatus { initial, loading, loaded, failure }

class SavedSearchesState extends Equatable {
  final SavedSearchesStatus status;
  final List<SavedSearchAlert> searches;
  final bool isSaving;
  final Set<String> removingIds;
  final String? message;

  const SavedSearchesState({
    required this.status,
    required this.searches,
    required this.isSaving,
    required this.removingIds,
    this.message,
  });

  const SavedSearchesState.initial()
      : status = SavedSearchesStatus.initial,
        searches = const [],
        isSaving = false,
        removingIds = const {},
        message = null;

  SavedSearchesState copyWith({
    SavedSearchesStatus? status,
    List<SavedSearchAlert>? searches,
    bool? isSaving,
    Set<String>? removingIds,
    String? message,
  }) {
    return SavedSearchesState(
      status: status ?? this.status,
      searches: searches ?? this.searches,
      isSaving: isSaving ?? this.isSaving,
      removingIds: removingIds ?? this.removingIds,
      message: message,
    );
  }

  bool get isEmpty => searches.isEmpty;

  int get pushEnabledCount => searches.where((search) => search.notifyByPush).length;

  int get inAppEnabledCount => searches.where((search) => search.notifyInApp).length;

  int get priceDropAlertCount => searches.where((search) => search.priceDropAlert).length;

  @override
  List<Object?> get props => [status, searches, isSaving, removingIds, message];
}
