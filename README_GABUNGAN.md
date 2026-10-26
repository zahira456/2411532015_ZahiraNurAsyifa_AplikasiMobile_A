# Expense Tracker Final — gabungan Praktikum 1–5

Proyek ini disusun dengan memakai proyek Praktikum 5 sebagai dasar agar tampilan Dashboard, warna merah, tombol tambah amber, navigasi bawah, Profil, dan Detail Transaksi tetap dekat dengan kode awal.

## Isi yang digabungkan

- Praktikum 1: konsep state dan toggle untuk menyembunyikan/menampilkan saldo.
- Praktikum 2: layout scroll dan daftar transaksi.
- Praktikum 3: validasi form, pilihan kategori, serta pemilih tanggal.
- Praktikum 4: navigasi dan passing data ke halaman detail.
- Praktikum 5: Dashboard Keuangan, tombol tambah, navigasi Beranda/Riwayat/Profil.
- Tambahan tugas akhir: Login/Register, SQLite untuk akun dan transaksi, serta sesi login lokal.

## Cara menjalankan

1. Ekstrak folder proyek ini.
2. Buka folder yang berisi `pubspec.yaml` di VS Code.
3. Pastikan Flutter dan Android SDK sudah terpasang.
4. Di terminal folder proyek, jalankan:

   ```powershell
   flutter pub get
   flutter analyze
   flutter run
   ```

5. Jalankan aplikasi, pilih **Register**, isi nama, email, dan kata sandi minimal 8 karakter. Setelah registrasi berhasil, login menggunakan akun tadi.
6. Tekan tombol `+` untuk menyimpan transaksi. Pilih jenis Pemasukan/Pengeluaran, kategori, nominal, dan tanggal.
7. Periksa saldo di Beranda dan daftar pada Riwayat. Tutup dan buka kembali aplikasi untuk memeriksa bahwa data masih tersimpan.

## Membuat APK

Setelah `flutter pub get` dan pengujian berhasil, jalankan:

```powershell
flutter build apk --release
```

APK biasanya dibuat pada `build\app\outputs\flutter-apk\app-release.apk`.

## Catatan

- Akun dan transaksi disimpan di SQLite pada perangkat. Sesi login disimpan menggunakan SharedPreferences.
- Kata sandi tidak disimpan sebagai teks biasa; kode menggunakan PBKDF2 dengan salt acak.
- Setiap transaksi terhubung ke ID pengguna yang membuatnya, sehingga riwayat antar akun dipisahkan.
- Akun baru mulai dengan saldo Rp 0 dan riwayat kosong. Masukkan transaksi pemasukan untuk menambah saldo, lalu pengeluaran untuk menguranginya.
- File `android/local.properties`, cache build, `.dart_tool`, dan file proyek IDE lokal tidak disertakan agar tidak membawa path komputer lain.
- Kode ini ditujukan untuk Android APK karena menggunakan `sqflite`; jangan menganggap database SQLite ini berjalan langsung di Chrome/Web.

## Struktur file Dart

```text
lib/
├── main.dart
├── main_screen.dart
├── dashboard_screen.dart
├── add_transaction_screen.dart
├── transaction_detail_screen.dart
├── profile_screen.dart
├── login_screen.dart
├── register_screen.dart
├── history_screen.dart
├── database/
│   └── database_helper.dart
├── models/
│   ├── user_model.dart
│   └── transaction_model.dart
└── services/
    └── session_service.dart
```
