import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

class WeatherDetailCard extends StatelessWidget {
  final CurrentWeather current;

  const WeatherDetailCard({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Informasi Tambahan Cuaca',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildDetailTile(
                context,
                icon: Icons.thermostat_rounded,
                iconColor: const Color(0xFFFF7043),
                title: 'Suhu Dirasakan',
                value: '${current.apparentTemperature.toStringAsFixed(1)} °C',
                subtitle: 'Apparent Temp',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailTile(
                context,
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF42A5F5),
                title: 'Kelembapan',
                value: '${current.relativeHumidity} %',
                subtitle: 'Relative Humidity',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailTile(
                context,
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF26A69A),
                title: 'Kecepatan Angin',
                value: '${current.windSpeed.toStringAsFixed(1)} km/h',
                subtitle: 'Wind Speed (10m)',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailTile(
                context,
                icon: Icons.cloud_download_rounded,
                iconColor: const Color(0xFF5C6BC0),
                title: 'Curah Hujan',
                value: '${current.precipitation.toStringAsFixed(1)} mm',
                subtitle: 'Precipitation',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
