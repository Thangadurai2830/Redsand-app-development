import '../../../home/data/models/home_model.dart';
import '../../domain/entities/saved_listing_entity.dart';

class SavedListingModel extends SavedListingEntity {
  const SavedListingModel({
    required super.id,
    required super.listing,
    super.savedAt,
  });

  factory SavedListingModel.fromJson(Map<String, dynamic> json) {
    final listingJson = (json['listing'] as Map<String, dynamic>?) ?? json;
    return SavedListingModel(
      id: (json['id'] ?? listingJson['id']).toString(),
      listing: ListingModel.fromJson(listingJson),
      savedAt: _parseSavedAt(json['saved_at'] ?? json['savedAt']),
    );
  }

  static DateTime? _parseSavedAt(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
