class AppStrings {
  // App
  static const String appName = 'PerpusKu';
  static const String appDescription = 'Mini Library Management System';

  // Navigation
  static const String books = 'Buku';
  static const String members = 'Anggota';
  static const String transactions = 'Transaksi';
  static const String statistics = 'Statistik';

  // Book module
  static const String bookList = 'Daftar Buku';
  static const String bookDetail = 'Detail Buku';
  static const String addBook = 'Tambah Buku';
  static const String editBook = 'Edit Buku';
  static const String deleteBook = 'Hapus Buku';
  static const String bookTitle = 'Judul Buku';
  static const String bookAuthor = 'Pengarang';
  static const String bookISBN = 'ISBN';
  static const String bookCategory = 'Kategori';
  static const String bookStock = 'Stok';
  static const String bookCover = 'Cover Buku';
  static const String searchBook = 'Cari Buku...';
  static const String filterByCategory = 'Filter Kategori';
  static const String allCategories = 'Semua Kategori';
  static const String available = 'Tersedia';
  static const String notAvailable = 'Tidak Tersedia';

  // Member module
  static const String memberList = 'Daftar Anggota';
  static const String memberDetail = 'Detail Anggota';
  static const String addMember = 'Tambah Anggota';
  static const String editMember = 'Edit Anggota';
  static const String deleteMember = 'Hapus Anggota';
  static const String memberName = 'Nama Lengkap';
  static const String memberID = 'ID Anggota';
  static const String memberPhone = 'No. Telepon';
  static const String memberPhoto = 'Foto Anggota';
  static const String registrationDate = 'Tanggal Daftar';
  static const String searchMember = 'Cari Anggota...';

  // Transaction module
  static const String borrowBook = 'Pinjam Buku';
  static const String returnBook = 'Kembalikan Buku';
  static const String transactionHistory = 'Riwayat Transaksi';
  static const String borrowDate = 'Tanggal Pinjam';
  static const String dueDate = 'Jatuh Tempo';
  static const String returnDate = 'Tanggal Kembali';
  static const String fine = 'Denda';
  static const String status = 'Status';
  static const String borrowed = 'Dipinjam';
  static const String returned = 'Dikembalikan';
  static const String overdue = 'Terlambat';
  static const String fineCalculation = 'Perhitungan Denda';
  static const String finePerDay = 'Denda per Hari';
  static const String totalFine = 'Total Denda';
  static const String daysLate = 'Hari Terlambat';

  // Statistics module
  static const String popularBooks = 'Buku Populer';
  static const String borrowingFrequency = 'Frekuensi Peminjaman';
  static const String overdueBooks = 'Buku Terlambat';
  static const String monthlySummary = 'Ringkasan Bulanan';
  static const String totalBooks = 'Total Buku';
  static const String totalMembers = 'Total Anggota';
  static const String activeTransactions = 'Transaksi Aktif';
  static const String totalBorrows = 'Total Peminjaman';
  static const String viewDetails = 'Lihat Detail';

  // Common
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String search = 'Cari';
  static const String filter = 'Filter';
  static const String sort = 'Urutkan';
  static const String clear = 'Bersihkan';
  static const String submit = 'Kirim';
  static const String ok = 'OK';
  static const String yes = 'Ya';
  static const String no = 'Tidak';
  static const String confirm = 'Konfirmasi';
  static const String back = 'Kembali';
  static const String next = 'Selanjutnya';
  static const String done = 'Selesai';
  static const String loading = 'Memuat...';
  static const String noData = 'Tidak ada data';
  static const String error = 'Terjadi kesalahan';
  static const String success = 'Berhasil';
  static const String warning = 'Peringatan';
  static const String info = 'Informasi';
  static const String takePicture = 'Ambil Foto';
  static const String chooseFromGallery = 'Pilih dari Galeri';
  static const String removeImage = 'Hapus Gambar';

  // Validation messages
  static const String fieldRequired = 'Field ini wajib diisi';
  static const String invalidEmail = 'Email tidak valid';
  static const String invalidPhone = 'Nomor telepon tidak valid';
  static const String invalidISBN = 'ISBN tidak valid';
  static const String stockMustBePositive = 'Stok harus lebih dari 0';

  // Confirmation messages
  static const String confirmDelete = 'Apakah Anda yakin ingin menghapus?';
  static const String confirmBorrow = 'Konfirmasi peminjaman buku ini?';
  static const String confirmReturn = 'Konfirmasi pengembalian buku ini?';

  // Success messages
  static const String bookAddedSuccess = 'Buku berhasil ditambahkan';
  static const String bookUpdatedSuccess = 'Buku berhasil diperbarui';
  static const String bookDeletedSuccess = 'Buku berhasil dihapus';
  static const String memberAddedSuccess = 'Anggota berhasil ditambahkan';
  static const String memberUpdatedSuccess = 'Anggota berhasil diperbarui';
  static const String memberDeletedSuccess = 'Anggota berhasil dihapus';
  static const String borrowSuccess = 'Peminjaman berhasil';
  static const String returnSuccess = 'Pengembalian berhasil';

  // Error messages
  static const String errorLoadingData = 'Gagal memuat data';
  static const String errorSavingData = 'Gagal menyimpan data';
  static const String errorDeletingData = 'Gagal menghapus data';
  static const String errorBookNotAvailable = 'Buku tidak tersedia';
  static const String errorMemberNotFound = 'Anggota tidak ditemukan';
  static const String errorTransactionNotFound = 'Transaksi tidak ditemukan';
}
