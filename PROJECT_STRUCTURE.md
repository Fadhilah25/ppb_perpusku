# Struktur Project PerpusKu

## 📁 Struktur Folder

```
lib/
├── main.dart                          # Entry point aplikasi
├── database/
│   └── database_helper.dart          # SQLite database helper
├── models/
│   ├── book.dart                     # Model untuk buku
│   ├── member.dart                   # Model untuk anggota
│   └── transaction.dart              # Model untuk transaksi
├── providers/
│   ├── book_provider.dart            # State management untuk buku
│   ├── member_provider.dart          # State management untuk anggota
│   ├── transaction_provider.dart     # State management untuk transaksi
│   └── statistics_provider.dart      # State management untuk statistik
├── screens/
│   ├── home_screen.dart              # Home screen dengan bottom navigation
│   ├── books/
│   │   ├── book_list_screen.dart     # List buku dengan search & filter
│   │   ├── book_detail_screen.dart   # Detail buku
│   │   └── add_edit_book_screen.dart # Form tambah/edit buku
│   ├── members/
│   │   ├── member_list_screen.dart   # List anggota
│   │   ├── member_detail_screen.dart # Detail anggota & riwayat
│   │   └── add_edit_member_screen.dart # Form tambah/edit anggota
│   ├── transactions/
│   │   ├── transaction_list_screen.dart # List transaksi dengan tabs
│   │   ├── borrow_book_screen.dart      # Form pinjam buku
│   │   └── return_book_screen.dart      # Form kembalikan buku
│   └── statistics/
│       └── statistics_screen.dart    # Dashboard statistik & charts
├── utils/
│   ├── constants.dart                # Konstanta aplikasi
│   └── helpers.dart                  # Helper functions (date, currency, validator)
└── widgets/
    └── common_widgets.dart           # Reusable widgets

assets/
└── images/                           # Folder untuk gambar/foto uploads
```

## 📊 Database Tables

### books

- id (PRIMARY KEY)
- title
- author
- isbn
- category
- stock
- cover_photo
- description
- created_at

### members

- id (PRIMARY KEY)
- name
- member_id (UNIQUE)
- phone
- photo
- email
- created_at

### transactions

- id (PRIMARY KEY)
- book_id (FOREIGN KEY)
- member_id (FOREIGN KEY)
- borrow_date
- due_date
- return_date
- fine
- status
- notes

## 🎯 Fitur Per Modul

### MODULE 1: BOOK CATALOG ✅

- [x] CRUD buku dengan foto cover
- [x] Search buku (judul, pengarang, ISBN)
- [x] Filter berdasarkan kategori
- [x] Status ketersediaan buku
- [x] Grid view dengan card design
- [x] Image picker (camera & gallery)

### MODULE 2: MEMBERS & BORROWING ✅

- [x] Registrasi anggota dengan foto
- [x] Auto-generate member ID
- [x] Form peminjaman buku
- [x] Form pengembalian buku
- [x] Kalkulator denda otomatis
- [x] Riwayat peminjaman per anggota
- [x] Tab: Aktif, Riwayat, Terlambat

### MODULE 3: STATISTICS ✅

- [x] Ringkasan bulanan (pinjam, kembali, denda)
- [x] Bar chart transaksi 12 bulan
- [x] Top 5 buku populer
- [x] List buku terlambat
- [x] Data aggregation
- [x] Visual charts dengan fl_chart

## 🛠️ Teknologi & Package

### State Management

- provider: ^6.1.1

### Database

- sqflite: ^2.3.0
- path_provider: ^2.1.1

### Image

- image_picker: ^1.0.5

### UI Components

- google_fonts: ^6.1.0
- fl_chart: ^0.65.0

### Utilities

- intl: ^0.19.0 (date & currency formatting)
- csv: ^5.1.1 (export capability)

### Bonus Features (Library Ready)

- qr_flutter: ^4.1.0
- mobile_scanner: ^3.5.5
- flutter_local_notifications: ^16.3.0

## 📱 Screens Overview

### 1. Home Screen

- Bottom navigation dengan 4 tabs
- Auto-load data saat startup
- Material Design 3

### 2. Book Catalog

- Grid layout 2 kolom
- Search bar sticky
- Horizontal category filter
- Pull to refresh
- Floating action button untuk tambah

### 3. Book Form

- Image picker dengan preview
- Dropdown kategori
- Form validation
- Simpan ke SQLite

### 4. Member List

- List dengan avatar
- Member info card
- Search (coming soon)

### 5. Member Form

- Circular avatar picker
- Auto-generate ID
- Email & phone validation

### 6. Transaction List

- 3 tabs: Aktif, Riwayat, Terlambat
- Expansion tile untuk detail
- 2 FAB: Pinjam & Kembalikan
- Status badge

### 7. Borrow Book

- Dropdown selector buku & anggota
- Durasi slider (1-30 hari)
- Auto calculate due date
- Notes field

### 8. Return Book

- Dropdown transaksi aktif
- Auto calculate keterlambatan
- Auto calculate denda
- Custom denda option

### 9. Statistics

- Summary cards
- Bar chart interaktif
- Popular books list
- Overdue list dengan warning

## 🎨 Design System

### Colors

- Primary: Indigo (#3F51B5)
- Success: Green
- Warning: Orange
- Error: Red

### Typography

- Font: Poppins (Google Fonts)
- Material Design 3 text styles

### Components

- Rounded corners (12px)
- Card elevation (2)
- Consistent padding (16px)

## 📋 Constants & Configuration

### Denda Settings

- Default: Rp 1.000/hari
- Configurable di constants.dart

### Durasi Peminjaman

- Default: 7 hari
- Min: 1 hari
- Max: 30 hari

### Member ID Format

- Prefix: M
- Year: 2 digit (25)
- Number: 4 digit (0001)
- Example: M250001

### Kategori Buku

1. Fiksi
2. Non-Fiksi
3. Sains
4. Teknologi
5. Sejarah
6. Biografi
7. Anak-anak
8. Komik
9. Lainnya

## 🚀 Setup & Run

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## ✅ Checklist Fitur

### Core Features

- [x] Database SQLite
- [x] CRUD Buku
- [x] CRUD Anggota
- [x] CRUD Transaksi
- [x] Search & Filter
- [x] Image Upload
- [x] Denda Otomatis
- [x] Statistics
- [x] Charts
- [x] State Management

### UI/UX

- [x] Material Design 3
- [x] Bottom Navigation
- [x] Pull to Refresh
- [x] Loading States
- [x] Empty States
- [x] Error Handling
- [x] Form Validation
- [x] Responsive Layout

### Data Management

- [x] Local Database
- [x] Image Storage
- [x] Data Persistence
- [x] Transaction Integrity
- [x] Stock Management

## 📝 File Count

- Dart Files: 25+
- Total Lines: 5000+
- Models: 3
- Providers: 4
- Screens: 12
- Widgets: 1 (common widgets)
- Utils: 2

## 🎓 Learning Points

Aplikasi ini mencakup:

1. State Management dengan Provider
2. SQLite Database Operations
3. Image Handling
4. Form Validation
5. Data Visualization (Charts)
6. Navigation & Routing
7. Material Design 3
8. Clean Architecture
9. CRUD Operations
10. Business Logic (Fines Calculation)

---

**Project Complete! ✅**
Ready to run and test!
