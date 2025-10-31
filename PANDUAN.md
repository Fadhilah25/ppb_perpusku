# Panduan Penggunaan PerpusKu

## Daftar Isi

1. [Memulai](#memulai)
2. [Modul Katalog Buku](#modul-katalog-buku)
3. [Modul Anggota](#modul-anggota)
4. [Modul Transaksi](#modul-transaksi)
5. [Modul Statistik](#modul-statistik)

## Memulai

### Instalasi

1. Pastikan Flutter sudah terinstall di komputer Anda
2. Clone atau download project ini
3. Jalankan `flutter pub get` untuk install dependencies
4. Jalankan `flutter run` untuk menjalankan aplikasi

### Navigasi Utama

Aplikasi memiliki 4 menu utama di bottom navigation:

- **Katalog**: Manajemen buku
- **Transaksi**: Peminjaman dan pengembalian
- **Anggota**: Manajemen anggota perpustakaan
- **Statistik**: Laporan dan analisis

## Modul Katalog Buku

### Menambah Buku Baru

1. Klik tombol "Tambah Buku" (floating action button)
2. Tap area foto untuk menambahkan cover buku
3. Pilih sumber: Galeri atau Kamera
4. Isi form:
   - Judul Buku (wajib)
   - Pengarang (wajib)
   - ISBN (opsional)
   - Kategori (wajib) - pilih dari dropdown
   - Stok (wajib)
   - Deskripsi (opsional)
5. Klik "Simpan Buku"

### Mencari Buku

1. Gunakan search bar di atas
2. Ketik judul, nama pengarang, atau ISBN
3. Hasil akan muncul secara real-time

### Filter Buku

1. Scroll horizontal pada chip kategori di bawah search bar
2. Pilih kategori yang diinginkan
3. Klik "Semua" untuk reset filter

### Melihat Detail Buku

1. Tap card buku yang ingin dilihat
2. Di halaman detail, Anda bisa:
   - Melihat semua informasi buku
   - Edit buku (tombol edit di app bar)
   - Hapus buku (tombol delete di app bar)

### Mengedit Buku

1. Buka detail buku
2. Klik icon edit di app bar
3. Ubah informasi yang diperlukan
4. Klik "Perbarui Buku"

### Menghapus Buku

1. Buka detail buku
2. Klik icon delete di app bar
3. Konfirmasi penghapusan
4. Buku akan dihapus dari database

## Modul Anggota

### Mendaftarkan Anggota Baru

1. Klik tombol "Tambah Anggota"
2. Tap avatar untuk menambahkan foto anggota
3. Pilih sumber: Galeri atau Kamera
4. Isi form:
   - Nama Lengkap (wajib)
   - ID Anggota (auto-generate, tidak bisa diubah)
   - Nomor Telepon (opsional)
   - Email (opsional)
5. Klik "Simpan Anggota"

### ID Anggota

- Format: M + tahun (2 digit) + nomor urut (4 digit)
- Contoh: M250001 (anggota pertama tahun 2025)
- Auto-generate dan unique

### Melihat Detail Anggota

1. Tap card anggota
2. Di halaman detail, Anda bisa:
   - Melihat informasi anggota
   - Melihat riwayat peminjaman
   - Edit anggota
   - Hapus anggota

### Mengedit Anggota

1. Buka detail anggota
2. Klik icon edit
3. Ubah informasi (ID tidak bisa diubah)
4. Klik "Perbarui Anggota"

## Modul Transaksi

### Tab Transaksi

- **Aktif**: Buku yang sedang dipinjam
- **Riwayat**: Semua transaksi
- **Terlambat**: Peminjaman yang melewati jatuh tempo

### Meminjam Buku

1. Klik tombol floating action button biru (+)
2. Pilih buku yang tersedia
3. Pilih anggota peminjam
4. Atur durasi peminjaman (1-30 hari)
   - Default: 7 hari
   - Gunakan tombol - dan + untuk mengatur
5. Tambahkan catatan (opsional)
6. Klik "Pinjam Buku"

### Mengembalikan Buku

1. Klik tombol floating action button hijau (return icon)
2. Pilih transaksi yang akan dikembalikan
3. Sistem akan menampilkan:
   - Tanggal pinjam
   - Jatuh tempo
   - Keterlambatan (jika ada)
   - Denda otomatis (Rp 1.000/hari)
4. Opsi menggunakan denda kustom (centang checkbox)
5. Klik "Kembalikan Buku"

### Sistem Denda

- Denda otomatis: Rp 1.000 per hari
- Denda dihitung dari hari melewati jatuh tempo
- Dapat menggunakan denda kustom jika diperlukan
- Denda akan tercatat di transaksi

### Detail Transaksi

1. Tap kartu transaksi untuk expand
2. Informasi yang ditampilkan:
   - ID Transaksi
   - Tanggal pinjam
   - Jatuh tempo
   - Tanggal kembali (jika sudah dikembalikan)
   - Keterlambatan
   - Denda
   - Status
   - Catatan

## Modul Statistik

### Ringkasan

Menampilkan 3 card utama:

- **Dipinjam**: Total buku dipinjam bulan ini
- **Dikembalikan**: Total buku dikembalikan bulan ini
- **Total Denda**: Total denda yang terkumpul

### Chart Transaksi Bulanan

- Bar chart menampilkan data 12 bulan
- Biru: Jumlah peminjaman
- Hijau: Jumlah pengembalian
- Dapat di-scroll horizontal

### Buku Paling Populer

- Menampilkan top 5 buku
- Diurutkan berdasarkan jumlah peminjaman
- Menampilkan cover, judul, pengarang
- Badge jumlah peminjaman

### Buku Terlambat

- List peminjaman yang melewati jatuh tempo
- Menampilkan:
  - Judul buku
  - Nama peminjam
  - Jumlah hari terlambat
  - Denda yang akan dikenakan
- Warning icon merah

### Refresh Data

- Pull to refresh pada list
- Klik icon refresh di app bar
- Data akan dimuat ulang dari database

## Tips & Trik

### Best Practices

1. **Foto Buku**: Gunakan foto cover yang jelas untuk memudahkan identifikasi
2. **Foto Anggota**: Foto anggota membantu verifikasi saat transaksi
3. **Kategori**: Pilih kategori yang tepat untuk memudahkan pencarian
4. **Deskripsi**: Tambahkan deskripsi singkat untuk informasi tambahan
5. **Stok**: Update stok secara berkala

### Manajemen Stok

- Stok otomatis berkurang saat buku dipinjam
- Stok otomatis bertambah saat buku dikembalikan
- Buku dengan stok 0 ditandai "Tidak Tersedia"
- Tidak bisa meminjam buku dengan stok 0

### Durasi Peminjaman

- Standar: 7 hari
- Maksimal: 30 hari
- Minimal: 1 hari
- Sesuaikan dengan kebijakan perpustakaan

### Denda

- Denda default: Rp 1.000/hari
- Bisa diubah di kode (constants.dart)
- Gunakan denda kustom untuk kasus khusus
- Denda hanya untuk peminjaman terlambat

## Troubleshooting

### Foto Tidak Muncul

- Pastikan permission kamera/galeri sudah diberikan
- Cek path penyimpanan foto
- Restart aplikasi

### Data Tidak Muncul

- Pull to refresh
- Restart aplikasi
- Cek apakah data tersimpan di database

### Error Saat Transaksi

- Pastikan buku masih tersedia (stok > 0)
- Pastikan anggota sudah terdaftar
- Cek koneksi database

### Stok Tidak Update

- Pastikan transaksi berhasil
- Refresh halaman katalog
- Cek riwayat transaksi

## Kontak & Support

Jika menemukan bug atau memiliki saran:

1. Buat issue di repository
2. Atau hubungi developer

---

**Selamat menggunakan PerpusKu! 📚**
