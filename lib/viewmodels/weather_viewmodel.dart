import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final ApiService apiService;
  final LocalStorageService storageService;

  WeatherViewModel({
    required this.apiService,
    required this.storageService,
  });

  // State Variables
  LocationModel? _currentLocation;
  WeatherModel? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  List<LocationModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchErrorMessage;

  List<LocationModel> _favoriteLocations = [];
  List<LocationModel> _searchHistory = [];

  // Getters
  LocationModel? get currentLocation => _currentLocation;
  WeatherModel? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<LocationModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchErrorMessage => _searchErrorMessage;

  List<LocationModel> get favoriteLocations => _favoriteLocations;
  List<LocationModel> get searchHistory => _searchHistory;

  bool get isCurrentFavorite {
    if (_currentLocation == null) return false;
    return isFavorite(_currentLocation!);
  }

  bool isFavorite(LocationModel location) {
    return _favoriteLocations.any((loc) =>
        loc.name == location.name &&
        loc.latitude == location.latitude &&
        loc.longitude == location.longitude);
  }

  /// Inisialisasi awal saat aplikasi dibuka:
  /// Memuat daftar favorit, riwayat, dan lokasi terakhir atau default Jakarta.
  Future<void> initialize() async {
    _loadFavoritesAndHistory();

    final lastLocation = storageService.getLastLocation();
    if (lastLocation != null) {
      await fetchWeatherForLocation(lastLocation);
    } else {
      // Default ke Jakarta jika baru pertama kali install / buka
      final defaultCity = LocationModel(
        name: 'Jakarta',
        latitude: -6.2088,
        longitude: 106.8456,
        country: 'Indonesia',
        admin1: 'DKI Jakarta',
      );
      await fetchWeatherForLocation(defaultCity);
    }
  }

  void _loadFavoritesAndHistory() {
    _favoriteLocations = storageService.getFavorites();
    _searchHistory = storageService.getSearchHistory();
    notifyListeners();
  }

  /// Mengambil data cuaca berdasarkan lokasi yang diberikan
  Future<void> fetchWeatherForLocation(LocationModel location) async {
    _currentLocation = location;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final weather = await apiService.fetchWeatherData(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _weatherData = weather;
      _errorMessage = null;

      // Simpan lokasi terakhir ke local storage
      await storageService.saveLastLocation(location);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Gagal memuat cuaca: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Melakukan refresh data cuaca untuk lokasi saat ini
  Future<void> refreshCurrentWeather() async {
    if (_currentLocation != null) {
      await fetchWeatherForLocation(_currentLocation!);
    }
  }

  /// Mencari lokasi kota berdasarkan teks
  Future<void> searchCity(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = [];
      _searchErrorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchErrorMessage = null;
    notifyListeners();

    try {
      final results = await apiService.searchLocations(trimmed);
      _searchResults = results;
      if (results.isEmpty) {
        _searchErrorMessage = 'Kota "$trimmed" tidak ditemukan. Coba kata kunci lain.';
      }
    } on ApiException catch (e) {
      _searchErrorMessage = e.message;
      _searchResults = [];
    } catch (e) {
      _searchErrorMessage = 'Terjadi kesalahan saat mencari kota: $e';
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Mengosongkan hasil pencarian
  void clearSearchResults() {
    _searchResults = [];
    _searchErrorMessage = null;
    notifyListeners();
  }

  /// Memilih lokasi dari hasil pencarian, favorit, atau riwayat
  Future<void> selectLocation(LocationModel location) async {
    // Tambahkan ke riwayat pencarian
    await storageService.addToHistory(location);
    _searchHistory = storageService.getSearchHistory();
    clearSearchResults();

    // Muat cuaca untuk kota tersebut
    await fetchWeatherForLocation(location);
  }

  /// Toggle status favorit lokasi
  Future<void> toggleFavorite(LocationModel location) async {
    final alreadyFavorite = isFavorite(location);
    if (alreadyFavorite) {
      await storageService.removeFavorite(location);
    } else {
      await storageService.addFavorite(location);
    }
    _favoriteLocations = storageService.getFavorites();
    notifyListeners();
  }

  /// Menghapus lokasi dari daftar favorit
  Future<void> removeFavorite(LocationModel location) async {
    await storageService.removeFavorite(location);
    _favoriteLocations = storageService.getFavorites();
    notifyListeners();
  }

  /// Menghapus seluruh riwayat pencarian
  Future<void> clearHistory() async {
    await storageService.clearHistory();
    _searchHistory = [];
    notifyListeners();
  }
}
