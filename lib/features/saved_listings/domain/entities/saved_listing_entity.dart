import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/listing_entity.dart';

class SavedListingEntity extends Equatable {
  final String id;
  final ListingEntity listing;
  final DateTime? savedAt;

  const SavedListingEntity({
    required this.id,
    required this.listing,
    this.savedAt,
  });

  @override
  List<Object?> get props => [id, listing, savedAt];
}
