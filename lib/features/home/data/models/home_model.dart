import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/search_suggestion_entity.dart';

class ListingModel extends ListingEntity {
  const ListingModel({
    required super.id,
    required super.title,
    required super.locality,
    required super.city,
    required super.price,
    required super.type,
    required super.listingFor,
    required super.imageUrl,
    required super.isPremium,
    required super.isBoosted,
    required super.bedrooms,
    required super.areaSqft,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      locality: json['locality'] as String,
      city: json['city'] as String,
      price: (json['price'] as num).toDouble(),
      type: json['type'] as String,
      listingFor: json['listing_for'] as String,
      imageUrl: json['image_url'] as String,
      isPremium: json['is_premium'] as bool? ?? false,
      isBoosted: json['is_boosted'] as bool? ?? false,
      bedrooms: json['bedrooms'] as int? ?? 0,
      areaSqft: (json['area_sqft'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'locality': locality,
      'city': city,
      'price': price,
      'type': type,
      'listing_for': listingFor,
      'image_url': imageUrl,
      'is_premium': isPremium,
      'is_boosted': isBoosted,
      'bedrooms': bedrooms,
      'area_sqft': areaSqft,
    };
  }
}

class SearchSuggestionModel extends SearchSuggestionEntity {
  const SearchSuggestionModel({
    required super.id,
    required super.text,
    required super.type,
  });

  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
    );
  }
}
