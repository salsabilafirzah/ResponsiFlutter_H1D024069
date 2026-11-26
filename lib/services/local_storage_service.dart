import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class LocalStorageService {
  static const String _keyFavorites = 'weather_favorite_locations';
  static const String _keyHistory = 'weather_search_history';
  static const String _keyLastLocation = 'weather_last_selected_location';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // =================== FAVORITE LOCATIONS ===================

  List<LocationModel> getFavorites() {
    final rawList = _prefs.getStringList(_keyFavorites) ?? [];
    return rawList
        .map((str) => LocationModel.fromJson(json.decode(str)))
        .toList();
  }

  Future<bool> saveFavorites(List<LocationModel> favorites) async {
    final rawList =
        favorites.map((loc) => json.encode(loc.toJson())).toList();
    return await _prefs.setStringList(_keyFavorites, rawList);
  }

  Future<bool> addFavorite(LocationModel location) async {
    final list = getFavorites();
    if (!list.any((loc) => loc.name == location.name && loc.latitude == location.latitude && loc.longitude == location.longitude)) {
      list.insert(0, location);
      return await saveFavorites(list);
    }
    return true;
  }

  Future<bool> removeFavorite(LocationModel location) async {
    final list = getFavorites();
    list.removeWhere((loc) =>
        loc.name == location.name &&
        loc.latitude == location.latitude &&
        loc.longitude == location.longitude);
    return await saveFavorites(list);
  }

  bool isFavorite(LocationModel location) {
    final list = getFavorites();
    return list.any((loc) =>
        loc.name == location.name &&
        loc.latitude == location.latitude &&
        loc.longitude == location.longitude);
  }

  // =================== SEARCH HISTORY ===================

  List<LocationModel> getSearchHistory() {
    final rawList = _prefs.getStringList(_keyHistory) ?? [];
    return rawList
        .map((str) => LocationModel.fromJson(json.decode(str)))
        .toList();
  }

  Future<bool> addToHistory(LocationModel location) async {
    final list = getSearchHistory();
    list.removeWhere((loc) =>
        loc.name == location.name &&
        loc.latitude == location.latitude &&
        loc.longitude == location.longitude);
    list.insert(0, location);
    // Batasi riwayat hingga maksimal 15 item
    if (list.length > 15) {
      list.removeRange(15, list.length);
    }
    final rawList = list.map((loc) => json.encode(loc.toJson())).toList();
    return await _prefs.setStringList(_keyHistory, rawList);
  }

  Future<bool> clearHistory() async {
    return await _prefs.remove(_keyHistory);
  }

  // =================== LAST SELECTED LOCATION ===================

  LocationModel? getLastLocation() {
    final rawStr = _prefs.getString(_keyLastLocation);
    if (rawStr != null && rawStr.isNotEmpty) {
      try {
        return LocationModel.fromJson(json.decode(rawStr));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<bool> saveLastLocation(LocationModel location) async {
    return await _prefs.setString(
      _keyLastLocation,
      json.encode(location.toJson()),
    );
  }
}
