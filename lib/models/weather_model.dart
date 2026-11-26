class WeatherModel {
  final CurrentWeather current;
  final DailyForecast daily;
  final String timezone;
  final double elevation;

  WeatherModel({
    required this.current,
    required this.daily,
    required this.timezone,
    required this.elevation,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      daily: DailyForecast.fromJson(json['daily'] as Map<String, dynamic>),
      timezone: json['timezone'] as String? ?? 'UTC',
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CurrentWeather {
  final String time;
  final double temperature; // current.temperature_2m
  final int relativeHumidity; // current.relative_humidity_2m
  final double apparentTemperature; // current.apparent_temperature
  final double precipitation; // current.precipitation
  final int weatherCode; // current.weather_code
  final double windSpeed; // current.wind_speed_10m

  CurrentWeather({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: json['time'] as String? ?? '',
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyForecast {
  final List<String> times;
  final List<int> weatherCodes;
  final List<double> maxTemperatures; // daily.temperature_2m_max
  final List<double> minTemperatures; // daily.temperature_2m_min
  final List<int> precipitationProbabilityMax; // daily.precipitation_probability_max

  DailyForecast({
    required this.times,
    required this.weatherCodes,
    required this.maxTemperatures,
    required this.minTemperatures,
    required this.precipitationProbabilityMax,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final times = (json['time'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final weatherCodes = (json['weather_code'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [];
    final maxTemps = (json['temperature_2m_max'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];
    final minTemps = (json['temperature_2m_min'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];
    final precipProbs =
        (json['precipitation_probability_max'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [];

    return DailyForecast(
      times: times,
      weatherCodes: weatherCodes,
      maxTemperatures: maxTemps,
      minTemperatures: minTemps,
      precipitationProbabilityMax: precipProbs,
    );
  }

  int get count => times.length;

  DailyForecastItem getItem(int index) {
    return DailyForecastItem(
      date: index < times.length ? times[index] : '',
      weatherCode: index < weatherCodes.length ? weatherCodes[index] : 0,
      maxTemp: index < maxTemperatures.length ? maxTemperatures[index] : 0.0,
      minTemp: index < minTemperatures.length ? minTemperatures[index] : 0.0,
      rainProbability: index < precipitationProbabilityMax.length
          ? precipitationProbabilityMax[index]
          : 0,
    );
  }
}

class DailyForecastItem {
  final String date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final int rainProbability;

  DailyForecastItem({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.rainProbability,
  });
}
