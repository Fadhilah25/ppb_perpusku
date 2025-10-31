class AppConstants {
  // App Info
  static const String appName = 'PerpusKu';
  static const String appVersion = '1.0.0';

  // Fine Settings
  static const double finePerDay = 1000.0;
  static const int maxBorrowDays = 30;
  static const int defaultBorrowDays = 7;

  // Database
  static const String databaseName = 'perpusku.db';
  static const int databaseVersion = 1;

  // Image Settings
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 1200;
  static const int imageQuality = 85;

  // Member ID Format
  static const String memberIdPrefix = 'M';
  static const int memberIdLength = 4;

  // Book Categories
  static const List<String> bookCategories = [
    'Fiksi',
    'Non-Fiksi',
    'Sains',
    'Teknologi',
    'Sejarah',
    'Biografi',
    'Anak-anak',
    'Komik',
    'Lainnya',
  ];

  // Transaction Status
  static const String statusBorrowed = 'borrowed';
  static const String statusReturned = 'returned';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Colors (can be used for custom theming)
  static const int primaryColorValue = 0xFF3F51B5; // Indigo
  static const int accentColorValue = 0xFF00BCD4; // Cyan

  // Chart Settings
  static const int topBooksLimit = 10;
  static const int popularBooksDisplayLimit = 5;

  // Pagination
  static const int itemsPerPage = 20;

  // Messages
  static const String emptyBooksMessage = 'Belum ada buku';
  static const String emptyMembersMessage = 'Belum ada anggota';
  static const String emptyTransactionsMessage = 'Belum ada transaksi';
  static const String emptyStatsMessage = 'Belum ada data statistik';

  // Error Messages
  static const String errorLoadingData = 'Gagal memuat data';
  static const String errorSavingData = 'Gagal menyimpan data';
  static const String errorDeletingData = 'Gagal menghapus data';
  static const String errorNoInternet = 'Tidak ada koneksi internet';
}
