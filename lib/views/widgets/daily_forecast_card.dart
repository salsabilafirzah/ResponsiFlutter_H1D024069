import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_code_helper.dart';
import '../../models/weather_model.dart';

class DailyForecastCard extends StatelessWidget {
  final DailyForecast daily;

  const DailyForecastCard({super.key, required this.daily});

  String _formatDate(String rawDate, int index) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';

    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('EEEE, d MMM', 'id_ID').format(parsed);
    } catch (_) {
      try {
        final parsed = DateTime.parse(rawDate);
        return DateFormat('EEE, d MMM').format(parsed);
      } catch (_) {
        return rawDate;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Perkiraan Cuaca Harian',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${daily.count} Hari',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.count,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final item = daily.getItem(index);
              final dayLabel = _formatDate(item.date, index);
              final icon = WeatherCodeHelper.getIcon(item.weatherCode);
              final iconColor = WeatherCodeHelper.getColor(item.weatherCode);
              final desc = WeatherCodeHelper.getDescription(item.weatherCode);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Tanggal & Cuaca
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: index == 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: index == 0
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Icon Cuaca
                    Icon(
                      icon,
                      color: iconColor,
                      size: 26,
                    ),
                    const SizedBox(width: 14),
                    // Peluang Hujan
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 14,
                            color: Colors.blue.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.rainProbability}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Suhu Maks & Min
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${item.maxTemp.round()}°',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.minTemp.round()}°',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
