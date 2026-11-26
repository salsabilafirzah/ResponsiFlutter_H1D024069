import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import '../../models/weather_code_helper.dart';
import '../../models/weather_model.dart';

class CurrentWeatherCard extends StatelessWidget {
  final LocationModel location;
  final CurrentWeather current;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const CurrentWeatherCard({
    super.key,
    required this.location,
    required this.current,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final weatherDesc = WeatherCodeHelper.getDescription(current.weatherCode);
    final weatherIcon = WeatherCodeHelper.getIcon(current.weatherCode);
    final weatherColor = WeatherCodeHelper.getColor(current.weatherCode);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            weatherColor,
            weatherColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: weatherColor.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle weather icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              weatherIcon,
              size: 160,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  location.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (location.admin1 != null || location.country != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 26, top: 2),
                              child: Text(
                                [location.admin1, location.country]
                                    .where((e) => e != null && e.isNotEmpty)
                                    .join(', '),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isFavorite ? Colors.amberAccent : Colors.white,
                        size: 30,
                      ),
                      tooltip: isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                      onPressed: onToggleFavorite,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Suhu Saat Ini
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${current.temperature.round()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 68,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            const Text(
                              '°C',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                weatherIcon,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                weatherDesc,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Weather big animated-like icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        weatherIcon,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
