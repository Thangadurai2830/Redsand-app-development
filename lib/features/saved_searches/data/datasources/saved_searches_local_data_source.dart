import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../filter/domain/entities/filter_entity.dart';
import '../models/saved_search_alert_model.dart';

abstract class SavedSearchesLocalDataSource {
  Future<List<SavedSearchAlertModel>> getSavedSearches();
  Future<SavedSearchAlertModel> saveSavedSearch(SavedSearchAlertModel search);
  Future<void> removeSavedSearch(String id);
}

const _savedSearchesKey = 'saved_search_alerts';

class SavedSearchesLocalDataSourceImpl implements SavedSearchesLocalDataSource {
  final SharedPreferences sharedPreferences;

  SavedSearchesLocalDataSourceImpl({required this.sharedPreferences});

  static List<SavedSearchAlertModel> get _seededSearches => [
        SavedSearchAlertModel(
          id: 'saved-search-1',
          query: '2BHK Whitefield',
          filter: const FilterEntity(
            listingFor: 'rent',
            propertyType: 'apartment',
            city: 'Bangalore',
            locality: 'Whitefield',
            minPrice: 25000,
            maxPrice: 45000,
            minBedrooms: 2,
            sortBy: 'newest',
          ),
          notifyByPush: true,
          notifyInApp: true,
          priceDropAlert: true,
          savedAt: DateTime.now().subtract(const Duration(days: 2)),
          newMatchCount: 3,
          lastMatchedAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        SavedSearchAlertModel(
          id: 'saved-search-2',
          query: 'Luxury villa for sale',
          filter: const FilterEntity(
            listingFor: 'buy',
            propertyType: 'villa',
            city: 'Bangalore',
            minPrice: 7500000,
            maxPrice: 15000000,
            sortBy: 'price_desc',
          ),
          notifyByPush: true,
          notifyInApp: false,
          priceDropAlert: false,
          savedAt: DateTime.now().subtract(const Duration(days: 6)),
          newMatchCount: 1,
          lastMatchedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  @override
  Future<List<SavedSearchAlertModel>> getSavedSearches() async {
    final encoded = sharedPreferences.getString(_savedSearchesKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return List<SavedSearchAlertModel>.from(_seededSearches);
    }

    final decoded = jsonDecode(encoded);
    if (decoded is! List) return List<SavedSearchAlertModel>.from(_seededSearches);

    final items = decoded
        .whereType<Map<String, dynamic>>()
        .map(SavedSearchAlertModel.fromJson)
        .toList();

    return items;
  }

  @override
  Future<SavedSearchAlertModel> saveSavedSearch(SavedSearchAlertModel search) async {
    final current = await getSavedSearches();
    final id = search.id.trim().isNotEmpty ? search.id : 'saved-search-${DateTime.now().microsecondsSinceEpoch}';
    final updated = SavedSearchAlertModel(
      id: id,
      query: search.query,
      filter: search.filter,
      notifyByPush: search.notifyByPush,
      notifyInApp: search.notifyInApp,
      priceDropAlert: search.priceDropAlert,
      savedAt: search.savedAt,
      newMatchCount: search.newMatchCount,
      lastMatchedAt: search.lastMatchedAt,
    );

    final filtered = current.where((entry) => entry.id != id).toList();
    filtered.insert(0, updated);
    await _persist(filtered);
    return updated;
  }

  @override
  Future<void> removeSavedSearch(String id) async {
    final current = await getSavedSearches();
    final filtered = current.where((entry) => entry.id != id).toList();
    await _persist(filtered);
  }

  Future<void> _persist(List<SavedSearchAlertModel> searches) async {
    final encoded = jsonEncode(searches.map((entry) => entry.toJson()).toList());
    await sharedPreferences.setString(_savedSearchesKey, encoded);
  }
}
