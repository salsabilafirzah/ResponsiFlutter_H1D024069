import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/daily_forecast_card.dart';
import 'widgets/weather_detail_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeatherViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.cloud_sync_rounded,
              color: Color(0xFF1E88E5),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Aplikasi Cuaca',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cari Kota / Lokasi',
            icon: const Icon(Icons.search_rounded, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Perbarui Data Cuaca',
            icon: const Icon(Icons.refresh_rounded, size: 26),
            onPressed: viewModel.isLoading
                ? null
                : () => viewModel.refreshCurrentWeather(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel viewModel) {
    if (viewModel.isLoading && viewModel.weatherData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Mengambil informasi cuaca terkini...',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (viewModel.errorMessage != null && viewModel.weatherData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Gagal Memuat Cuaca',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => viewModel.refreshCurrentWeather(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                icon: const Icon(Icons.search_rounded),
                label: const Text('Cari Lokasi Lain'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.weatherData == null || viewModel.currentLocation == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_city_rounded, size: 70, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Belum ada lokasi yang dipilih',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              child: const Text('Pilih Kota'),
            ),
          ],
        ),
      );
    }

    final weather = viewModel.weatherData!;
    final location = viewModel.currentLocation!;

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshCurrentWeather(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // Favorite Quick Switch Chips (jika ada favorit)
          if (viewModel.favoriteLocations.isNotEmpty) ...[
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.favoriteLocations.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final fav = viewModel.favoriteLocations[index];
                  final isSelected = fav.name == location.name &&
                      fav.latitude == location.latitude &&
                      fav.longitude == location.longitude;

                  return FilterChip(
                    avatar: Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: isSelected ? Colors.amber : Colors.grey,
                    ),
                    label: Text(fav.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      viewModel.selectLocation(fav);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Banner loading kecil jika sedang refresh di background
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: LinearProgressIndicator(minHeight: 2),
            ),

          // 1. Current Weather Card
          CurrentWeatherCard(
            location: location,
            current: weather.current,
            isFavorite: viewModel.isCurrentFavorite,
            onToggleFavorite: () => viewModel.toggleFavorite(location),
          ),
          const SizedBox(height: 20),

          // 2. Weather Details (Apparent Temp, Humidity, Wind Speed, Precipitation)
          WeatherDetailCard(current: weather.current),
          const SizedBox(height: 20),

          // 3. Daily Forecast (Beberapa hari ke depan)
          DailyForecastCard(daily: weather.daily),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
