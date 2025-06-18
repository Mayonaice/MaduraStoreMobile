# Madura Store Mobile

Aplikasi mobile untuk dashboard e-commerce Madura Store, dikembangkan menggunakan Flutter.

## Fitur

- Autentikasi pengguna (Login dan Register)
- Dashboard dengan ringkasan transaksi
- Daftar transaksi dan detail transaksi
- Profil pengguna

## Teknologi

- Flutter untuk pengembangan UI
- Provider untuk state management
- HTTP untuk komunikasi dengan API
- Shared Preferences untuk penyimpanan lokal
- FL Chart untuk visualisasi data

## Persyaratan Sistem

- Flutter SDK

## Pengaturan Proyek

1. Pastikan Flutter SDK sudah terpasang dengan benar
2. Clone repositori ini
3. Jalankan `flutter pub get` untuk menginstal semua dependensi
4. Update URL API di `lib/services/api_service.dart` sesuai dengan URL server ASP.NET Anda
5. Jalankan aplikasi dengan salah satu metode yang dijelaskan di bawah

## Menjalankan Aplikasi Tanpa Android SDK & JDK

Ada beberapa cara untuk menjalankan aplikasi Flutter tanpa perlu menginstal Android SDK dan JDK:

### 1. Flutter Web

Cara termudah adalah menjalankan aplikasi sebagai aplikasi web:

```bash
# Aktifkan dukungan web jika belum
flutter config --enable-web

# Jalankan aplikasi di browser


```

### 2. Flutter Desktop (Windows)

Untuk menjalankan sebagai aplikasi desktop:

```bash
# Aktifkan dukungan Windows jika belum
flutter config --enable-windows-desktop

# Jalankan aplikasi di Windows
flutter run -d windows
```

### 3. Menggunakan Flutter DevTools

Flutter DevTools menyediakan emulator ringan:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Kemudian buka browser dan jalankan aplikasi dengan:

```bash
flutter run --web-renderer html
```

### 4. Menggunakan Emulator Online

Beberapa layanan online yang dapat digunakan:

- [DartPad](https://dartpad.dev) - untuk kode sederhana
- [Flutter Studio](https://flutterstudio.app)
- [CodePen](https://codepen.io)

## Struktur Proyek

```
lib/
  ├── main.dart                 # Entry point aplikasi
  ├── models/                   # Model data
  │   ├── transaction.dart      # Model transaksi
  │   ├── transaction_detail.dart # Model detail transaksi
  │   ├── transaction_summary.dart # Model ringkasan transaksi
  │   └── user.dart             # Model pengguna
  ├── screens/                  # Halaman UI
  │   ├── dashboard_screen.dart  # Halaman dashboard
  │   ├── login_screen.dart     # Halaman login
  │   ├── profile_screen.dart   # Halaman profil
  │   ├── register_screen.dart  # Halaman registrasi
  │   ├── splash_screen.dart    # Halaman splash screen
  │   ├── transaction_detail_screen.dart # Halaman detail transaksi
  │   └── transaction_list_screen.dart # Halaman daftar transaksi
  ├── services/                 # Layanan
  │   ├── api_service.dart      # Layanan komunikasi dengan API
  │   ├── auth_service.dart     # Layanan autentikasi
  │   └── transaction_service.dart # Layanan transaksi
  ├── theme/                    # Tema aplikasi
  │   └── app_theme.dart        # Konfigurasi tema
  └── widgets/                  # Widget kustom
      └── loading_overlay.dart  # Widget overlay loading
```

## Komunikasi dengan Backend

Aplikasi ini berkomunikasi dengan backend ASP.NET VB menggunakan HTTP API. Endpoint yang digunakan:

- `auth.ashx` - Untuk autentikasi (login, register, validasi token)
- `transactions.ashx` - Untuk data transaksi (daftar, detail, ringkasan)

## Kontak

Untuk pertanyaan atau dukungan, silakan hubungi developer melalui email di [developer@madurastore.com](mailto:developer@madurastore.com). 