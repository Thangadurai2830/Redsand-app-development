import 'package:equatable/equatable.dart';

import '../../domain/entities/saved_listing_entity.dart';

enum SavedListingsStatus { initial, loading, loaded, failure }

class SavedListingsState extends Equatable {
  final SavedListingsStatus status;
  final List<SavedListingEntity> listings;
  final Set<String> selectedIds;
  final Set<String> removingIds;
  final String? message;

  const SavedListingsState({
    required this.status,
    required this.listings,
    required this.selectedIds,
    required this.removingIds,
    this.message,
  });

  const SavedListingsState.initial()
      : status = SavedListingsStatus.initial,
        listings = const [],
        selectedIds = const {},
        removingIds = const {},
        message = null;

  SavedListingsState copyWith({
    SavedListingsStatus? status,
    List<SavedListingEntity>? listings,
    Set<String>? selectedIds,
    Set<String>? removingIds,
    String? message,
  }) {
    return SavedListingsState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      selectedIds: selectedIds ?? this.selectedIds,
      removingIds: removingIds ?? this.removingIds,
      message: message,
    );
  }

  bool get canCompare => selectedIds.length >= 2;

  List<SavedListingEntity> get selectedListings =>
      listings.where((entry) => selectedIds.contains(entry.listing.id)).toList();

  @override
  List<Object?> get props => [status, listings, selectedIds, removingIds, message];
}
