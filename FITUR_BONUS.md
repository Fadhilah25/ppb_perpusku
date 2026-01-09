# PerpusKu - Fitur Bonus

## 🎉 Fitur Bonus yang Telah Diimplementasi

### 1. 📱 QR/Barcode Scanner

**Lokasi File:** `lib/services/qr_scanner_service.dart`

#### Fitur:

- ✅ Scan QR Code untuk memilih buku saat peminjaman
- ✅ Generate QR Code untuk setiap buku
- ✅ Toggle flash dan switch camera
- ✅ UI scanner dengan overlay guide

#### Cara Penggunaan:

1. **Scan Buku (Borrow Screen)**

   - Buka menu "Pinjam Buku"
   - Klik tombol "Scan" di sebelah pemilih buku
   - Arahkan kamera ke QR Code buku
   - Buku otomatis terpilih

2. **Generate QR Code (Book Detail)**
   - Buka detail buku
   - Klik icon QR Code di AppBar
   - QR Code akan ditampilkan dan bisa di-screenshot

#### Dependencies:

```yaml
mobile_scanner: ^3.5.5
qr_flutter: ^4.1.0
```

---

### 2. 🔔 Push Notifications

**Lokasi File:** `lib/services/notification_service.dart`

#### Fitur:

- ✅ Notifikasi saat peminjaman berhasil
- ✅ Notifikasi saat pengembalian berhasil
- ✅ Reminder 1 hari sebelum jatuh tempo
- ✅ Notifikasi untuk buku terlambat
- ✅ Daily check otomatis jam 9 pagi

#### Jenis Notifikasi:

1. **Borrow Success Notification**

   ```
   Judul: "Peminjaman Berhasil!"
   Isi: "{Member} meminjam "{Buku}". Jatuh tempo: {Tanggal}"
   ```

2. **Return Reminder**

   ```
   Judul: "Reminder: Pengembalian Buku"
   Isi: "{Member}, jangan lupa kembalikan "{Buku}" besok!"
   Trigger: 1 hari sebelum due date
   ```

3. **Overdue Notification**

   ```
   Judul: "Buku Terlambat!"
   Isi: "{Member} terlambat mengembalikan "{Buku}". Terlambat {X} hari. Denda: Rp {Y}"
   ```

4. **Return Success**
   ```
   Judul: "Pengembalian Berhasil!"
   Isi: "{Member} mengembalikan "{Buku}". [Tepat waktu! / Denda: Rp {X}]"
   ```

#### Cara Kerja:

- Otomatis diinisialisasi saat app start (`main.dart`)
- Notifikasi dijadwalkan saat peminjaman buku
- Daily check dijadwalkan saat home screen dimuat
- Notifikasi dibatalkan saat buku dikembalikan

#### Dependencies:

```yaml
flutter_local_notifications: ^16.3.0
timezone: ^0.9.2
```

#### Permissions (Android):

Tambahkan di `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

---

### 3. 📊 Export Data ke CSV

**Lokasi File:** `lib/services/export_service.dart`

#### Fitur Export:

- ✅ Export semua buku
- ✅ Export semua member
- ✅ Export transaksi (dengan filter)
- ✅ Export buku terlambat
- ✅ Export buku populer
- ✅ Export laporan bulanan
- ✅ Export laporan komprehensif

#### Cara Penggunaan:

1. Buka menu "Statistik"
2. Klik icon menu (3 titik) di AppBar
3. Pilih "Export Laporan"
4. Pilih jenis laporan yang ingin di-export
5. File CSV akan tersimpan di Documents folder

#### Format File:

```
Nama File: {type}_{timestamp}.csv
Contoh: books_20231210_143052.csv

Lokasi: /storage/emulated/0/Documents/ (Android)
        ~/Documents/ (Desktop)
```

#### Isi File CSV:

**Books Export:**

```csv
ID,Judul,Pengarang,ISBN,Kategori,Stok,Tanggal Dibuat
1,Laskar Pelangi,Andrea Hirata,978-123,Fiksi,5,2023-12-10
```

**Transactions Export:**

```csv
ID,Book ID,Member ID,Tanggal Pinjam,Jatuh Tempo,Tanggal Kembali,Denda,Status,Catatan
1,5,3,2023-12-01 10:00,2023-12-08 10:00,2023-12-09 14:30,1000,returned,-
```

**Overdue Report:**

```csv
ID Transaksi,Book ID,Member ID,Tanggal Pinjam,Jatuh Tempo,Hari Terlambat,Denda
10,7,4,2023-11-20,2023-11-27,13,13000
```

**Comprehensive Report:**

```csv
LAPORAN PERPUSTAKAAN LENGKAP
Tanggal Export,2023-12-10 14:30
[empty row]
RINGKASAN
Total Buku,150
Total Member,75
Total Transaksi,320
Total Denda Terkumpul,Rp 45000
...
```

#### Dependencies:

```yaml
csv: ^5.1.1
path_provider: ^2.1.1
```

---

## 🚀 Instalasi & Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Setup Android Permissions

**File:** `android/app/src/main/AndroidManifest.xml`

Tambahkan permissions:

```xml
<!-- Untuk Camera/QR Scanner -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />

<!-- Untuk Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

<!-- Untuk File Export -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### 3. Setup iOS Permissions

**File:** `ios/Runner/Info.plist`

Tambahkan:

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk scan QR Code buku</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses foto untuk menyimpan cover buku</string>
```

---

## 📱 Penggunaan Fitur

### QR Scanner di Borrow Book Screen

1. Buka "Transaksi" → "Pinjam Buku"
2. Klik tombol "Scan" di bagian "Pilih Buku"
3. Scan QR Code buku (bisa lihat QR di detail buku)
4. Buku otomatis terpilih

### Notifikasi Otomatis

- Notifikasi peminjaman/pengembalian: Otomatis
- Reminder: Dijadwalkan 1 hari sebelum due date
- Daily check: Setiap jam 9 pagi
- Manual check: Statistik → Menu → "Cek Buku Terlambat"

### Export Laporan

1. Buka "Statistik"
2. Klik icon ⋮ (menu) di kanan atas
3. Pilih "Export Laporan"
4. Pilih jenis laporan
5. File tersimpan di Documents folder
6. Buka dengan Excel/Google Sheets

---

## 🎯 Integrasi dengan Modul Inti

### Module 1: Book Catalog

- ✅ QR Code generation di book detail
- ✅ Export daftar buku

### Module 2: Borrowing System

- ✅ QR Scanner untuk memilih buku
- ✅ Notifikasi peminjaman & pengembalian
- ✅ Reminder otomatis
- ✅ Export transaksi

### Module 3: Statistics

- ✅ Export statistik buku populer
- ✅ Export laporan buku terlambat
- ✅ Manual trigger notifikasi overdue
- ✅ Export laporan komprehensif

---

## 🔧 Troubleshooting

### QR Scanner tidak berfungsi

- Pastikan camera permission sudah di-grant
- Cek AndroidManifest.xml sudah ada permission CAMERA
- Test di real device (emulator kadang tidak support)

### Notifikasi tidak muncul

- Android 13+: Request permission di runtime
- Cek notification settings di device
- Pastikan app tidak di-battery optimization
- Timezone package sudah terinstall

### Export gagal

- Pastikan permission WRITE_EXTERNAL_STORAGE di-grant
- Cek storage space cukup
- Path provider sudah terinstall

---

## 📝 Catatan Penting

1. **QR Scanner**: Hanya berfungsi di physical device (tidak di emulator)
2. **Notifications**: Android 13+ butuh runtime permission
3. **Export**: File disimpan di app documents directory
4. **Timezone**: Diperlukan untuk scheduled notifications

---

## 🎨 Fitur Tambahan yang Bisa Dikembangkan

- [ ] Barcode scanner untuk ISBN
- [ ] Share QR Code via WhatsApp/Email
- [ ] Export ke PDF
- [ ] Cloud backup
- [ ] Email notification
- [ ] Push notification via FCM
- [ ] Batch QR Code printing
- [ ] Export dengan custom date range

---

## 📚 Dependencies Lengkap

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  provider: ^6.1.1

  # Database
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3

  # Media
  image_picker: ^1.0.5

  # Date & Time
  intl: ^0.19.0
  timezone: ^0.9.2

  # Charts
  fl_chart: ^0.65.0

  # QR/Barcode (BONUS)
  qr_flutter: ^4.1.0
  mobile_scanner: ^3.5.5

  # Export (BONUS)
  csv: ^5.1.1

  # Notifications (BONUS)
  flutter_local_notifications: ^16.3.0

  # UI
  google_fonts: ^6.1.0
  cupertino_icons: ^1.0.8
```

---

## ✅ Checklist Implementasi

- [x] QR Scanner Service
- [x] QR Code Generator
- [x] Scanner UI dengan overlay
- [x] Integrasi scanner di borrow screen
- [x] QR Code display di book detail
- [x] Notification Service
- [x] Borrow success notification
- [x] Return reminder notification
- [x] Overdue notification
- [x] Daily check scheduling
- [x] Return success notification
- [x] Export Service
- [x] Export books
- [x] Export members
- [x] Export transactions
- [x] Export overdue report
- [x] Export popular books
- [x] Export monthly report
- [x] Export comprehensive report
- [x] UI integration di statistics screen
- [x] Timezone package integration
- [x] Main.dart initialization
- [x] Documentation

**Status: ✅ SEMUA FITUR BONUS TELAH DIIMPLEMENTASI!**
