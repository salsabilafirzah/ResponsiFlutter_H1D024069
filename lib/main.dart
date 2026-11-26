import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'utils/app_theme.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi local storage (SharedPreferences)
  final localStorageService = await LocalStorageService.init();
  final apiService = ApiService();

  // Inisialisasi ViewModel
  final weatherViewModel = WeatherViewModel(
    apiService: apiService,
    storageService: localStorageService,
  );

  // Load state awal (lokasi terakhir/default, favorit, dan riwayat)
  await weatherViewModel.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>.value(value: weatherViewModel),
      ],
      child: const ResponsiWeatherApp(),
    ),
  );
}

class ResponsiWeatherApp extends StatelessWidget {
  const ResponsiWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsi Cuaca Open-Meteo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
