# 📚 PerpusKu - Mini Library Management System

Aplikasi perpustakaan sederhana untuk sekolah/komunitas berbasis Flutter dengan fitur lengkap!

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-3.0+-orange)
![Status](https://img.shields.io/badge/Status-Production%20Ready-green)

---

## ✨ Fitur Utama

### 📖 Module 1: Book Catalog

- ✅ CRUD buku lengkap (Create, Read, Update, Delete)
- ✅ Upload foto cover buku dari kamera/galeri
- ✅ Detail buku (judul, pengarang, kategori, ISBN, deskripsi)
- ✅ Search & filter buku berdasarkan kategori
- ✅ Status ketersediaan buku (tersedia/dipinjam)
- ✅ **BONUS: QR Code Generator** untuk setiap buku

### 👥 Module 2: Borrowing System

- ✅ Registrasi member dengan foto
- ✅ Transaksi peminjaman buku
- ✅ Transaksi pengembalian dengan kalkulator denda otomatis
- ✅ History peminjaman per member
- ✅ Perhitungan tanggal jatuh tempo
- ✅ **BONUS: QR Scanner** untuk memilih buku
- ✅ **BONUS: Notifikasi** peminjaman & pengembalian

### 📊 Module 3: Statistics & Reports

- ✅ Chart buku populer (top 10 most borrowed)
- ✅ Visualisasi frekuensi peminjaman bulanan
- ✅ List buku terlambat dengan reminder
- ✅ Summary transaksi bulanan
- ✅ Total denda terkumpul
- ✅ **BONUS: Export ke CSV** (berbagai jenis laporan)

---

## 🎁 Fitur Bonus

### 1. 📱 QR/Barcode Scanner

- Scan QR Code untuk memilih buku saat peminjaman
- Generate QR Code untuk setiap buku
- UI scanner profesional dengan overlay guide
- Toggle flash dan switch camera

**Cara Pakai:**

- Detail Buku → Icon QR → Screenshot
- Pinjam Buku → Tombol "Scan" → Scan QR

### 2. 🔔 Push Notifications

- Notifikasi saat berhasil meminjam buku
- Notifikasi saat berhasil mengembalikan buku
- Reminder otomatis 1 hari sebelum jatuh tempo
- Notifikasi untuk buku yang terlambat
- Daily check otomatis jam 9 pagi

**Jenis Notifikasi:**

- ✅ Borrow Success
- ✅ Return Success
- ✅ Return Reminder (scheduled)
- ✅ Overdue Alert
- ✅ Daily Check

### 3. 📊 Export Data (CSV)

- Export semua buku
- Export semua member
- Export transaksi (dengan filter)
- Export buku terlambat
- Export buku populer
- Export laporan bulanan
- Export laporan komprehensif

**Lokasi Export:**

- Android: `/storage/Documents/`
- Desktop: `~/Documents/`

File format: `{type}_{timestamp}.csv`

---

## 🗄️ Database Schema

### Books Table

```sql
- id: INTEGER PRIMARY KEY
- title: TEXT NOT NULL
- author: TEXT NOT NULL
- isbn: TEXT
- category: TEXT NOT NULL
- stock: INTEGER NOT NULL
- cover_photo: TEXT
- description: TEXT
- created_at: TEXT
```

### Members Table

```sql
- id: INTEGER PRIMARY KEY
- name: TEXT NOT NULL
- member_id: TEXT UNIQUE NOT NULL
- phone: TEXT
- photo: TEXT
- email: TEXT
- created_at: TEXT
```

### Transactions Table

```sql
- id: INTEGER PRIMARY KEY
- book_id: INTEGER NOT NULL (FK)
- member_id: INTEGER NOT NULL (FK)
- borrow_date: TEXT NOT NULL
- due_date: TEXT NOT NULL
- return_date: TEXT
- fine: REAL DEFAULT 0
- status: TEXT NOT NULL (borrowed/returned)
- notes: TEXT
```

---

## 🛠️ Tech Stack

### Framework & Language

- **Flutter**: ^3.9.2
- **Dart**: ^3.9.2

### State Management

- **Provider**: ^6.1.1

### Database

- **SQLite**: sqflite ^2.3.0
- **Path Provider**: ^2.1.1

### Media & Image

- **Image Picker**: ^1.0.5 (Camera & Gallery)

### Charts & Visualization

- **FL Chart**: ^0.65.0

### QR/Barcode (Bonus)

- **QR Flutter**: ^4.1.0 (Generate QR)
- **Mobile Scanner**: ^3.5.5 (Scan QR)

### Notifications (Bonus)

- **Flutter Local Notifications**: ^16.3.0
- **Timezone**: ^0.9.2

### Export (Bonus)

- **CSV**: ^5.1.1

### UI/UX

- **Google Fonts**: ^6.1.0
- **Material 3**: ✅ Enabled
- **Intl**: ^0.19.0 (Date formatting)

---

## 🚀 Instalasi & Setup

### Prerequisites

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.0
- Android Studio / VS Code
- Android SDK (untuk Android)
- Xcode (untuk iOS)

### 1. Clone Repository

```bash
git clone https://github.com/username/perpusku.git
cd perpusku
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Permissions

#### Android

File: `android/app/src/main/AndroidManifest.xml` (sudah dikonfigurasi)

```xml
<!-- Camera untuk QR Scanner -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

<!-- Storage untuk Export -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

#### iOS

File: `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk scan QR Code buku</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses foto untuk menyimpan cover buku</string>
```

### 4. Run App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device-id>
```

---

## 📱 Platform Support

| Platform | Status             | Notes                    |
| -------- | ------------------ | ------------------------ |
| Android  | ✅ Fully Supported | Min SDK 21 (Android 5.0) |
| iOS      | ✅ Supported       | Min iOS 11.0             |
| Web      | ⚠️ Limited         | QR Scanner tidak support |
| Windows  | ✅ Supported       | Desktop mode             |
| macOS    | ✅ Supported       | Desktop mode             |
| Linux    | ✅ Supported       | Desktop mode             |

**Catatan:** QR Scanner hanya berfungsi di physical device (Android/iOS), tidak di emulator atau web.

---

## 📂 Struktur Project

```
perpusku/
├── lib/
│   ├── main.dart
│   ├── database/
│   │   └── database_helper.dart
│   ├── models/
│   │   ├── book.dart
│   │   ├── member.dart
│   │   └── transaction.dart
│   ├── providers/
│   │   ├── book_provider.dart
│   │   ├── member_provider.dart
│   │   ├── transaction_provider.dart
│   │   └── statistics_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── books/
│   │   │   ├── book_list_screen.dart
│   │   │   ├── book_detail_screen.dart
│   │   │   └── add_edit_book_screen.dart
│   │   ├── members/
│   │   │   ├── member_list_screen.dart
│   │   │   ├── member_detail_screen.dart
│   │   │   └── add_edit_member_screen.dart
│   │   ├── transactions/
│   │   │   ├── transaction_list_screen.dart
│   │   │   ├── borrow_book_screen.dart
│   │   │   └── return_book_screen.dart
│   │   └── statistics/
│   │       └── statistics_screen.dart
│   ├── services/ (BONUS)
│   │   ├── qr_scanner_service.dart
│   │   ├── notification_service.dart
│   │   └── export_service.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   ├── helpers.dart
│   │   └── seed_data.dart
│   └── widgets/
│       └── common_widgets.dart
├── assets/
│   └── images/
├── android/
├── ios/
├── web/
├── pubspec.yaml
├── README.md
├── FITUR_BONUS.md
└── IMPLEMENTASI_SUMMARY.md
```

---

## 🎯 Cara Penggunaan

### 1. Manajemen Buku

1. Buka tab "Katalog"
2. Klik tombol "+" untuk tambah buku baru
3. Isi detail buku (foto, judul, pengarang, kategori, ISBN, stok)
4. Klik "Simpan"
5. Untuk melihat QR Code: Buka detail buku → Icon QR

### 2. Manajemen Member

1. Buka tab "Anggota"
2. Klik tombol "+" untuk tambah member
3. Isi data member (foto, nama, ID member, telepon)
4. Klik "Simpan"

### 3. Peminjaman Buku

1. Buka tab "Transaksi"
2. Klik "Pinjam Buku"
3. Pilih buku (manual atau scan QR)
4. Pilih member
5. Atur durasi peminjaman
6. Klik "Pinjam Buku"
7. Notifikasi otomatis terkirim

### 4. Pengembalian Buku

1. Buka tab "Transaksi"
2. Klik "Kembalikan Buku"
3. Pilih transaksi yang akan dikembalikan
4. Sistem otomatis hitung denda (jika ada)
5. Klik "Kembalikan Buku"
6. Notifikasi otomatis terkirim

### 5. Statistik & Export

1. Buka tab "Statistik"
2. Lihat chart dan summary
3. Untuk export: Menu (⋮) → "Export Laporan"
4. Pilih jenis laporan
5. File tersimpan di Documents folder

---

## 📊 Screenshots

### Home & Book Catalog

- Bottom Navigation dengan 4 tabs
- Book list dengan cover images
- Search & filter functionality
- Book details dengan QR Code

### Transactions

- Borrow book dengan QR Scanner
- Return book dengan fine calculator
- Transaction history

### Statistics

- Monthly chart
- Popular books
- Overdue list
- Export menu

---

## 🧪 Testing

### Unit Tests

```bash
flutter test
```

### Integration Tests

```bash
flutter test integration_test
```

### Manual Testing Checklist

- [ ] CRUD buku
- [ ] CRUD member
- [ ] Peminjaman buku
- [ ] Pengembalian buku
- [ ] Kalkulasi denda
- [ ] Search & filter
- [ ] QR Scanner
- [ ] QR Generator
- [ ] Notifications
- [ ] Export CSV

---

## 🐛 Troubleshooting

### QR Scanner tidak berfungsi

- Pastikan testing di real device (bukan emulator)
- Check camera permission di settings
- Verify AndroidManifest.xml

### Notifikasi tidak muncul

- Android 13+: Request runtime permission
- Check notification settings di device
- Disable battery optimization untuk app

### Export gagal

- Check storage permission
- Verify path_provider installation
- Pastikan ada space storage cukup

### Build error

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📈 Roadmap

### Version 1.1 (Future)

- [ ] Barcode scanner untuk ISBN
- [ ] Cloud backup (Firebase)
- [ ] Email notifications
- [ ] Export to PDF
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Batch operations

### Version 2.0 (Future)

- [ ] Online sync
- [ ] User authentication
- [ ] Role-based access
- [ ] Advanced analytics
- [ ] Mobile & Web dashboard

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Project by:** [Your Name]
**Email:** [your.email@example.com]
**GitHub:** [@yourusername](https://github.com/yourusername)

---

## 🙏 Acknowledgments

- Flutter Team untuk framework yang amazing
- Material Design untuk design guidelines
- Community plugins yang digunakan
- Stack Overflow untuk problem solving

---

## 📚 Documentation

Untuk dokumentasi lebih lengkap:

- [FITUR_BONUS.md](FITUR_BONUS.md) - Detail fitur bonus
- [IMPLEMENTASI_SUMMARY.md](IMPLEMENTASI_SUMMARY.md) - Summary implementasi

---

## 📞 Support

Jika ada pertanyaan atau issue:

1. Check documentation terlebih dahulu
2. Open issue di GitHub
3. Contact developer

---

**Made with ❤️ using Flutter**

**Status: ✅ Production Ready**
**Version: 1.0.0+bonus**
**Last Updated: December 10, 2025**
