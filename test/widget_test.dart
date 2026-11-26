import 'package:flutter_test/flutter_test.dart';
import 'package:responsi_flutter/models/location_model.dart';
import 'package:responsi_flutter/models/weather_code_helper.dart';
import 'package:responsi_flutter/models/weather_model.dart';

void main() {
  group('LocationModel Tests', () {
    test('JSON serialization & deserialization', () {
      final jsonSample = {
        'id': 1642911,
        'name': 'Jakarta',
        'latitude': -6.21462,
        'longitude': 106.84513,
        'country': 'Indonesia',
        'admin1': 'Jakarta',
        'country_code': 'ID',
      };

      final location = LocationModel.fromJson(jsonSample);
      expect(location.name, 'Jakarta');
      expect(location.latitude, -6.21462);
      expect(location.longitude, 106.84513);
      expect(location.country, 'Indonesia');
      expect(location.admin1, 'Jakarta');
      expect(location.displayName, contains('Jakarta'));

      final encoded = location.toJson();
      expect(encoded['name'], 'Jakarta');
    });
  });

  group('WeatherModel Tests', () {
    test('Parse Open-Meteo current and daily forecast', () {
      final mockJson = {
        'latitude': -6.2,
        'longitude': 106.8,
        'elevation': 15.0,
        'timezone': 'Asia/Jakarta',
        'current': {
          'time': '2026-11-26T01:00',
          'temperature_2m': 27.5,
          'relative_humidity_2m': 85,
          'apparent_temperature': 31.2,
          'precipitation': 0.0,
          'weather_code': 2,
          'wind_speed_10m': 8.6,
        },
        'daily': {
          'time': ['2026-11-26', '2026-11-27', '2026-11-28'],
          'weather_code': [2, 61, 80],
          'temperature_2m_max': [32.0, 31.5, 30.0],
          'temperature_2m_min': [24.0, 23.5, 23.0],
          'precipitation_probability_max': [40, 75, 60],
        }
      };

      final weather = WeatherModel.fromJson(mockJson);

      // Current weather checks
      expect(weather.current.temperature, 27.5);
      expect(weather.current.relativeHumidity, 85);
      expect(weather.current.apparentTemperature, 31.2);
      expect(weather.current.precipitation, 0.0);
      expect(weather.current.weatherCode, 2);
      expect(weather.current.windSpeed, 8.6);

      // Daily forecast checks
      expect(weather.daily.count, 3);
      final item0 = weather.daily.getItem(0);
      expect(item0.maxTemp, 32.0);
      expect(item0.minTemp, 24.0);
      expect(item0.rainProbability, 40);
      expect(item0.weatherCode, 2);
    });
  });

  group('WeatherCodeHelper Tests', () {
    test('Check WMO code description & icons', () {
      expect(WeatherCodeHelper.getDescription(0), 'Cerah');
      expect(WeatherCodeHelper.getDescription(61), 'Hujan Ringan');
      expect(WeatherCodeHelper.getDescription(95), 'Badai Petir');
      expect(WeatherCodeHelper.getIcon(0), isNotNull);
      expect(WeatherCodeHelper.getColor(0), isNotNull);
    });
  });
}
