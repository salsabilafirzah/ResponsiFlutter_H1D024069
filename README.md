# RESPONSI PRAKTIKUM PEMROGRAMAN MOBILE
## APLIKASI CUACA MENGGUNAKAN FLUTTER DAN OPEN-METEO

- **Nama**: Salsabila Firzah
- **NIM**: H1D024069
- **Shift Awal**: H
- **Shift Akhir**: D

---

## 1. Struktur Aplikasi

Aplikasi dibangun menggunakan bahasa pemrograman Dart dan framework Flutter dengan struktur proyek yang memisahkan tanggung jawab antarkomponen:

```text
lib/
|-- main.dart                          # Titik masuk aplikasi, inisialisasi LocalStorage dan MultiProvider
|-- models/
|   |-- location_model.dart            # Model data lokasi kota, koordinat, dan serialisasi JSON
|   |-- weather_model.dart             # Model data cuaca saat ini (current) dan prakiraan harian (daily)
|   `-- weather_code_helper.dart       # Helper pemetaan kode cuaca WMO ke teks, warna, dan ikon
|-- services/
|   |-- api_service.dart               # Service HTTP GET untuk Forecast API dan Geocoding API Open-Meteo
|   `-- local_storage_service.dart     # Service penyimpanan lokal (SharedPreferences) untuk riwayat & favorit
|-- utils/
|   `-- app_theme.dart                 # Konfigurasi tema aplikasi berbasis Material Design (Light dan Dark)
|-- viewmodels/
|   `-- weather_viewmodel.dart         # Pengelola state aplikasi (ChangeNotifier) dan logika bisnis
`-- views/
    |-- home_screen.dart               # Tampilan layar utama informasi cuaca
    |-- search_screen.dart             # Tampilan layar pencarian kota, daftar favorit, dan riwayat
    `-- widgets/
        |-- current_weather_card.dart  # Komponen kartu cuaca terkini dan suhu saat ini
        |-- weather_detail_card.dart   # Komponen informasi tambahan (kelembapan, angin, suhu terasa, presipitasi)
        `-- daily_forecast_card.dart   # Komponen daftar perkiraan cuaca beberapa hari ke depan
```

---

## 2. Implementasi API

Aplikasi mengambil data secara dinamis dari REST API resmi Open-Meteo menggunakan metode HTTP GET:

### A. Weather Forecast API
- **Endpoint**: `https://api.open-meteo.com/v1/forecast`
- **Parameter yang digunakan**:
  - `latitude` dan `longitude`: Koordinat lokasi yang dipilih pengguna.
  - `current`: Mengambil data suhu saat ini (`temperature_2m`), kelembapan udara (`relative_humidity_2m`), suhu yang dirasakan (`apparent_temperature`), curah hujan (`precipitation`), kode cuaca WMO (`weather_code`), dan kecepatan angin (`wind_speed_10m`).
  - `daily`: Mengambil data kode cuaca harian (`weather_code`), suhu maksimum harian (`temperature_2m_max`), suhu minimum harian (`temperature_2m_min`), serta peluang hujan maksimum (`precipitation_probability_max`).
  - `timezone`: Ditetapkan ke `auto` agar data cuaca menyesuaikan zona waktu lokal lokasi tersebut.

### B. Geocoding API
- **Endpoint**: `https://geocoding-api.open-meteo.com/v1/search`
- **Parameter yang digunakan**:
  - `name`: Kata kunci pencarian kota dari input pengguna.
  - `count`: Dibatasi maksimal 10 hasil pencarian.
  - `language`: Bahasa Indonesia (`id`).
  - `format`: Format respons data JSON (`json`).

### C. Pengolahan Data dan Penanganan Kondisi (State & Error Handling)
- Respons API berupa JSON diolah secara terstruktur menjadi Dart model (`WeatherModel` dan `LocationModel`).
- **Loading State**: Menampilkan indikator pemuatan melingkar saat memuat data dari API.
- **Error State**: Menampilkan pesan kesalahan dan tombol coba lagi (*retry*) ketika terjadi kegagalan jaringan atau server tidak merespons.
- **Data Kosong / Empty State**: Menampilkan pemberitahuan yang jelas jika hasil pencarian kota tidak ditemukan atau riwayat pencarian masih kosong.

---

## 3. Penerapan Arsitektur MVVM (Model-View-ViewModel)

Aplikasi menerapkan pola arsitektur MVVM untuk memisahkan antarmuka pengguna, logika bisnis, dan model data:

1. **Model** (`lib/models/`):
   - Bertanggung jawab sebagai representasi data dan mengonversi respons API dari format JSON menjadi objek Dart melalui `fromJson` serta serialisasi ke format penyimpanan melalui `toJson`.
2. **ViewModel** (`lib/viewmodels/weather_viewmodel.dart`):
   - Mewarisi kelas `ChangeNotifier`.
   - Mengelola seluruh state aplikasi, seperti `currentLocation`, `weatherData`, `isLoading`, `errorMessage`, `favoriteLocations`, dan `searchHistory`.
   - Menghubungkan View dengan Service untuk memanggil API cuaca dan menyimpan data ke penyimpanan lokal (*SharedPreferences*).
   - Memanggil `notifyListeners()` untuk memperbarui tampilan antarmuka setiap kali state data mengalami perubahan.
3. **View** (`lib/views/`):
   - Terdiri dari `HomeScreen` dan `SearchScreen` beserta widget pendukungnya.
   - Bersifat pasif dan hanya bertugas menampilkan data yang disediakan oleh `WeatherViewModel` menggunakan `Provider` (`context.watch<WeatherViewModel>()`).
   - Meneruskan aksi atau interaksi pengguna (seperti mencari kota, menyegarkan cuaca, atau memilih lokasi favorit) ke fungsi yang ada di ViewModel.

---

## 4. Screenshot Aplikasi

Penjelasan singkat:

* **Home / Weather Screen**: Menampilkan seluruh informasi cuaca utama dalam satu layar, mencakup nama kota yang sedang dipilih, kondisi cuaca terkini dengan ikon representatif, suhu saat ini, kartu informasi tambahan (suhu yang dirasakan, kelembapan udara, kecepatan angin, curah hujan), serta daftar perkiraan cuaca harian 7 hari ke depan.
* **Search / Location Screen**: Menyediakan input pencarian kota berbasis Open-Meteo Geocoding API secara real-time, menampilkan daftar hasil pencarian lokasi lengkap dengan koordinat, serta daftar lokasi favorit dan riwayat pencarian yang tersimpan di penyimpanan lokal (*SharedPreferences*).
* **Kondisi Khusus (Loading & Error State)**: Menampilkan visual indikator pemuatan (*loading indicator*) saat mengambil data dari API dan antarmuka penanganan kesalahan (*error state*) saat koneksi internet terputus disertai tombol coba lagi (*retry*).

| Home / Weather Screen | Search / Location Screen | Kondisi Loading & Error State |
| :---: | :---: | :---: |
| *(Tampilkan Screenshot Home Screen)* | *(Tampilkan Screenshot Search Screen)* | *(Tampilkan Screenshot Loading/Error)* |
