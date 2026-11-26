import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, WeatherViewModel viewModel) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      viewModel.searchCity(query);
    });
  }

  void _handleLocationSelected(LocationModel location, WeatherViewModel viewModel) {
    viewModel.selectLocation(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeatherViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lokasi'),
      ),
      body: Column(
        children: [
          // Input Pencarian Kota
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Ketik nama kota (misal: Bandung, Tokyo)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.clearSearchResults();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() {});
                _onSearchChanged(val, viewModel);
              },
              onSubmitted: (val) {
                _debounce?.cancel();
                viewModel.searchCity(val);
              },
            ),
          ),

          // Content Area
          Expanded(
            child: _buildContent(context, viewModel, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WeatherViewModel viewModel,
    bool isDark,
  ) {
    if (viewModel.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Mencari lokasi melalui Open-Meteo API...'),
          ],
        ),
      );
    }

    // Jika sedang dalam mode hasil pencarian
    if (_searchController.text.trim().isNotEmpty) {
      if (viewModel.searchErrorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_rounded,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.searchErrorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (viewModel.searchResults.isNotEmpty) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: viewModel.searchResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final loc = viewModel.searchResults[index];
            final isFav = viewModel.isFavorite(loc);

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  loc.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  [
                    if (loc.admin1 != null && loc.admin1!.isNotEmpty) loc.admin1,
                    if (loc.country != null && loc.country!.isNotEmpty) loc.country,
                    '(${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)})',
                  ].join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFav ? Colors.amber : Colors.grey,
                  ),
                  tooltip: isFav ? 'Hapus Favorit' : 'Simpan Favorit',
                  onPressed: () {
                    viewModel.toggleFavorite(loc);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFav
                              ? '${loc.name} dihapus dari favorit.'
                              : '${loc.name} disimpan ke favorit.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                onTap: () => _handleLocationSelected(loc, viewModel),
              ),
            );
          },
        );
      }
    }

    // Default View ketika input pencarian kosong: Tampilkan Favorit & Riwayat
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // ================= SEKSI FAVORIT =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Lokasi Favorit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Text(
              '${viewModel.favoriteLocations.length} Kota',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (viewModel.favoriteLocations.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Belum ada lokasi favorit yang disimpan.\nCari kota dan tekan ikon bintang untuk menyimpannya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...viewModel.favoriteLocations.map((fav) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.location_city_rounded, color: Colors.amber),
                title: Text(
                  fav.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  fav.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'Hapus dari Favorit',
                  onPressed: () {
                    viewModel.removeFavorite(fav);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${fav.name} dihapus dari favorit.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                onTap: () => _handleLocationSelected(fav, viewModel),
              ),
            );
          }),

        const SizedBox(height: 24),

        // ================= SEKSI RIWAYAT =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded, color: Color(0xFF1E88E5), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Riwayat Pencarian',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            if (viewModel.searchHistory.isNotEmpty)
              TextButton(
                onPressed: () => viewModel.clearHistory(),
                child: const Text('Hapus Semua', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (viewModel.searchHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Belum ada riwayat pencarian.',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...viewModel.searchHistory.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.history_toggle_off_rounded, color: Colors.blueGrey),
                title: Text(item.name),
                subtitle: Text(
                  item.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => _handleLocationSelected(item, viewModel),
              ),
            );
          }),
      ],
    );
  }
}
