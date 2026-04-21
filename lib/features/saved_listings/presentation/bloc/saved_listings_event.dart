import 'package:equatable/equatable.dart';

abstract class SavedListingsEvent extends Equatable {
  const SavedListingsEvent();

  @override
  List<Object?> get props => [];
}

class SavedListingsLoadRequested extends SavedListingsEvent {
  const SavedListingsLoadRequested();
}

class SavedListingsRefreshRequested extends SavedListingsEvent {
  const SavedListingsRefreshRequested();
}

class SavedListingsToggleSelectionRequested extends SavedListingsEvent {
  final String listingId;

  const SavedListingsToggleSelectionRequested(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

class SavedListingsRemoveRequested extends SavedListingsEvent {
  final String listingId;

  const SavedListingsRemoveRequested(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

class SavedListingsClearMessageRequested extends SavedListingsEvent {
  const SavedListingsClearMessageRequested();
}

class SavedListingsClearSelectionRequested extends SavedListingsEvent {
  const SavedListingsClearSelectionRequested();
}
