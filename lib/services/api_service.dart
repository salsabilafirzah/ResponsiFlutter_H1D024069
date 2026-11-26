import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  /// Mengambil data cuaca terkini dan prakiraan harian dari Open-Meteo API
  Future<WeatherModel> fetchWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
    };

    final uri = Uri.parse(_forecastBaseUrl).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw ApiException(
          'Gagal mengambil data cuaca dari server (Status: ${response.statusCode}). Silakan coba lagi nanti.',
        );
      }
    } on SocketException {
      throw ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.',
      );
    } on TimeoutException {
      throw ApiException(
        'Waktu permintaan habis (timeout). Periksa koneksi internet Anda.',
      );
    } on FormatException {
      throw ApiException('Format data cuaca tidak valid dari server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }

  /// Mencari lokasi kota berdasarkan input teks dari Open-Meteo Geocoding API
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    final queryParams = {
      'name': trimmedQuery,
      'count': '10',
      'language': 'id',
      'format': 'json',
    };

    final uri = Uri.parse(_geocodingBaseUrl).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('results') && data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results
              .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw ApiException(
          'Gagal mencari lokasi (Status: ${response.statusCode}).',
        );
      }
    } on SocketException {
      throw ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw ApiException(
        'Waktu pencarian lokasi habis. Periksa koneksi Anda.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal mencari kota: ${e.toString()}');
    }
  }
}
