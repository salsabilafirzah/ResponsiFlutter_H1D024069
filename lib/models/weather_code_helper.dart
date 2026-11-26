import 'package:flutter/material.dart';

class WeatherCodeHelper {
  static String getDescription(int? code) {
    if (code == null) return 'Tidak Diketahui';
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Sebagian Besar Cerah';
      case 2:
        return 'Sebagian Berawan';
      case 3:
        return 'Berawan Tebal';
      case 45:
        return 'Berkabut';
      case 48:
        return 'Kabut Tebal Berembun';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
      case 57:
        return 'Gerimis Dingin Membeku';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Dingin Membeku';
      case 71:
        return 'Hujan Salju Ringan';
      case 73:
        return 'Hujan Salju Sedang';
      case 75:
        return 'Hujan Salju Lebat';
      case 77:
        return 'Butiran Salju';
      case 80:
        return 'Hujan Rintik-Rintik';
      case 81:
        return 'Hujan Deras Lokal';
      case 82:
        return 'Hujan Badai Sangat Deras';
      case 85:
      case 86:
        return 'Hujan Salju Lebat Sesaat';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir Disertai Hujan Es';
      default:
        return 'Cuaca $code';
    }
  }

  static IconData getIcon(int? code) {
    if (code == null) return Icons.help_outline_rounded;
    switch (code) {
      case 0:
        return Icons.wb_sunny_rounded;
      case 1:
      case 2:
        return Icons.wb_cloudy_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.cloud_queue_rounded;
      case 51:
      case 53:
      case 55:
        return Icons.grain_rounded;
      case 56:
      case 57:
        return Icons.ac_unit_rounded;
      case 61:
      case 63:
        return Icons.water_drop_rounded;
      case 65:
        return Icons.umbrella_rounded;
      case 66:
      case 67:
        return Icons.severe_cold_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit_rounded;
      case 80:
      case 81:
      case 82:
        return Icons.water_drop_rounded;
      case 85:
      case 86:
        return Icons.snowing;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.cloud_rounded;
    }
  }

  static Color getColor(int? code) {
    if (code == null) return Colors.blueGrey;
    switch (code) {
      case 0:
        return const Color(0xFFFFA000); // Amber
      case 1:
      case 2:
        return const Color(0xFF4FC3F7); // Light blue
      case 3:
        return const Color(0xFF78909C); // Gray blue
      case 45:
      case 48:
        return const Color(0xFF90A4AE); // Foggy gray
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 80:
      case 81:
        return const Color(0xFF29B6F6); // Rain blue
      case 65:
      case 82:
        return const Color(0xFF0288D1); // Deep rain blue
      case 95:
      case 96:
      case 99:
        return const Color(0xFF5E35B1); // Thunder purple
      default:
        return const Color(0xFF26A69A);
    }
  }
}
