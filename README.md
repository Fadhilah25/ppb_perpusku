# PerpusKu - Mini Library Management

Aplikasi perpustakaan sederhana untuk sekolah/komunitas yang dibangun dengan Flutter.

## 📚 Fitur Utama

### MODULE 1: BOOK CATALOG

- ✅ CRUD buku lengkap dengan foto cover
- ✅ Detail buku (judul, pengarang, kategori, ISBN)
- ✅ Pencarian dan filter buku berdasarkan kategori
- ✅ Status ketersediaan buku
- ✅ Manajemen stok buku

### MODULE 2: BORROWING SYSTEM

- ✅ Registrasi anggota dengan foto
- ✅ Transaksi peminjaman buku
- ✅ Transaksi pengembalian dengan kalkulator denda otomatis
- ✅ Riwayat peminjaman per anggota
- ✅ Denda otomatis untuk keterlambatan (Rp 1.000/hari)
- ✅ QR/Barcode support (library sudah terinstall)

### MODULE 3: STATISTICS

- ✅ Chart buku populer
- ✅ Visualisasi frekuensi peminjaman bulanan
- ✅ Daftar buku terlambat dengan warning
- ✅ Ringkasan transaksi bulanan
- ✅ Total denda terkumpul
- ✅ Export data (library CSV sudah terinstall)

## 🛠️ Teknologi yang Digunakan

- **Framework**: Flutter
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Image Handling**: image_picker
- **Charts**: fl_chart
- **Date Formatting**: intl
- **QR/Barcode**: qr_flutter, mobile_scanner
- **Export**: csv
- **Notifications**: flutter_local_notifications
- **UI**: Google Fonts, Material Design 3

## 📊 Database Schema

### Books Table

```sql
CREATE TABLE books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  isbn TEXT,
  category TEXT NOT NULL,
  stock INTEGER NOT NULL,
  cover_photo TEXT,
  description TEXT,
  created_at TEXT
)
```

### Members Table

```sql
CREATE TABLE members (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  member_id TEXT NOT NULL UNIQUE,
  phone TEXT,
  photo TEXT,
  email TEXT,
  created_at TEXT
)
```

### Transactions Table

```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER NOT NULL,
  member_id INTEGER NOT NULL,
  borrow_date TEXT NOT NULL,
  due_date TEXT NOT NULL,
  return_date TEXT,
  fine REAL NOT NULL DEFAULT 0,
  status TEXT NOT NULL,
  notes TEXT,
  FOREIGN KEY (book_id) REFERENCES books (id),
  FOREIGN KEY (member_id) REFERENCES members (id)
)
```

## 🚀 Cara Menjalankan

1. **Clone repository atau buka project**

   ```bash
   cd "d:\flutter v1\perpusku"
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 📱 Fitur Detail

### 1. Katalog Buku

- Tambah buku baru dengan foto cover dari galeri atau kamera
- Edit informasi buku
- Hapus buku
- Cari buku berdasarkan judul, pengarang, atau ISBN
- Filter buku berdasarkan kategori
- Lihat status ketersediaan buku

### 2. Anggota

- Registrasi anggota baru dengan foto
- Auto-generate ID anggota (format: M25XXXX)
- Edit informasi anggota
- Hapus anggota
- Lihat riwayat peminjaman per anggota

### 3. Transaksi Peminjaman

- Pinjam buku dengan durasi custom (1-30 hari)
- Sistem otomatis mengurangi stok buku
- Pengembalian buku dengan kalkulator denda
- Denda otomatis Rp 1.000/hari untuk keterlambatan
- Opsi denda kustom
- Filter transaksi: Aktif, Riwayat, Terlambat

### 4. Statistik & Laporan

- Ringkasan transaksi bulan ini
- Chart transaksi bulanan (12 bulan)
- Top 5 buku paling populer
- Daftar buku terlambat dengan notifikasi
- Total denda terkumpul

## 🎨 Kategori Buku

- Fiksi
- Non-Fiksi
- Sains
- Teknologi
- Sejarah
- Biografi
- Anak-anak
- Komik
- Lainnya

## 📝 Catatan

- Database disimpan secara lokal menggunakan SQLite
- Foto buku dan anggota disimpan di storage device
- Denda default: Rp 1.000 per hari keterlambatan
- ID Anggota auto-generate dengan format: M + tahun (2 digit) + nomor urut (4 digit)

## 🔜 Pengembangan Selanjutnya

- Implementasi QR/Barcode scanner untuk peminjaman cepat
- Notifikasi push untuk pengingat jatuh tempo
- Export laporan ke CSV/PDF
- Dashboard admin yang lebih lengkap
- Multi-user authentication
- Backup & restore database

## 📄 Lisensi

Project ini dibuat untuk keperluan edukasi dan pembelajaran Flutter.

---

**Dibuat dengan ❤️ menggunakan Flutter**
