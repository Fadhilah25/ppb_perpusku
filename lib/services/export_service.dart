import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/book.dart';
import '../models/member.dart';
import '../models/transaction.dart';

class ExportService {
  static final ExportService instance = ExportService._init();
  ExportService._init();

  // Export semua buku ke CSV
  Future<String> exportBooks() async {
    final books = await DatabaseHelper.instance.readAllBooks();

    final List<List<dynamic>> rows = [
      [
        'ID',
        'Judul',
        'Pengarang',
        'ISBN',
        'Kategori',
        'Stok',
        'Tanggal Dibuat',
      ],
    ];

    for (final book in books) {
      rows.add([
        book.id,
        book.title,
        book.author,
        book.isbn ?? '-',
        book.category,
        book.stock,
        book.createdAt ?? '-',
      ]);
    }

    return await _saveCSV('books', rows);
  }

  // Export semua member ke CSV
  Future<String> exportMembers() async {
    final members = await DatabaseHelper.instance.readAllMembers();

    final List<List<dynamic>> rows = [
      ['ID', 'Nama', 'Member ID', 'Telepon', 'Email', 'Tanggal Daftar'],
    ];

    for (final member in members) {
      rows.add([
        member.id,
        member.name,
        member.memberId,
        member.phone ?? '-',
        member.email ?? '-',
        member.createdAt ?? '-',
      ]);
    }

    return await _saveCSV('members', rows);
  }

  // Export transaksi dengan filter
  Future<String> exportTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    final transactions = await DatabaseHelper.instance.readAllTransactions();

    // Filter transaksi
    var filteredTransactions = transactions.where((t) {
      bool matchDate = true;
      bool matchStatus = true;

      if (startDate != null) {
        matchDate =
            t.borrowDate.isAfter(startDate) ||
            t.borrowDate.isAtSameMomentAs(startDate);
      }
      if (endDate != null) {
        matchDate =
            matchDate &&
            (t.borrowDate.isBefore(endDate) ||
                t.borrowDate.isAtSameMomentAs(endDate));
      }
      if (status != null) {
        matchStatus = t.status == status;
      }

      return matchDate && matchStatus;
    }).toList();

    final List<List<dynamic>> rows = [
      [
        'ID',
        'Book ID',
        'Member ID',
        'Tanggal Pinjam',
        'Jatuh Tempo',
        'Tanggal Kembali',
        'Denda',
        'Status',
        'Catatan',
      ],
    ];

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    for (final transaction in filteredTransactions) {
      rows.add([
        transaction.id,
        transaction.bookId,
        transaction.memberId,
        dateFormat.format(transaction.borrowDate),
        dateFormat.format(transaction.dueDate),
        transaction.returnDate != null
            ? dateFormat.format(transaction.returnDate!)
            : '-',
        transaction.fine,
        transaction.status,
        transaction.notes ?? '-',
      ]);
    }

    return await _saveCSV('transactions', rows);
  }

  // Export laporan buku terlambat
  Future<String> exportOverdueReport() async {
    final overdueTransactions = await DatabaseHelper.instance
        .getOverdueTransactions();

    final List<List<dynamic>> rows = [
      [
        'ID Transaksi',
        'Book ID',
        'Member ID',
        'Tanggal Pinjam',
        'Jatuh Tempo',
        'Hari Terlambat',
        'Denda',
      ],
    ];

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final transaction in overdueTransactions) {
      rows.add([
        transaction.id,
        transaction.bookId,
        transaction.memberId,
        dateFormat.format(transaction.borrowDate),
        dateFormat.format(transaction.dueDate),
        transaction.daysOverdue,
        transaction.calculateFine(),
      ]);
    }

    return await _saveCSV('overdue_report', rows);
  }

  // Export statistik buku populer
  Future<String> exportPopularBooksReport() async {
    final popularBooks = await DatabaseHelper.instance.getPopularBooks(
      limit: 50,
    );

    final List<List<dynamic>> rows = [
      ['Book ID', 'Judul', 'Pengarang', 'Jumlah Peminjaman'],
    ];

    for (final book in popularBooks) {
      rows.add([
        book['id'],
        book['title'],
        book['author'],
        book['borrow_count'],
      ]);
    }

    return await _saveCSV('popular_books', rows);
  }

  // Export laporan bulanan
  Future<String> exportMonthlyReport(int year, int month) async {
    final summary = await DatabaseHelper.instance.getMonthlyTransactionSummary(
      year,
      month,
    );
    final transactions = await DatabaseHelper.instance.readAllTransactions();

    // Filter transaksi bulan tersebut
    final monthTransactions = transactions.where((t) {
      return t.borrowDate.year == year && t.borrowDate.month == month;
    }).toList();

    final List<List<dynamic>> rows = [
      ['LAPORAN BULANAN - ${_getMonthName(month)} $year'],
      [],
      ['Total Peminjaman', summary['borrowed']],
      ['Total Pengembalian', summary['returned']],
      [],
      ['DETAIL TRANSAKSI'],
      ['ID', 'Book ID', 'Member ID', 'Tanggal Pinjam', 'Status', 'Denda'],
    ];

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final transaction in monthTransactions) {
      rows.add([
        transaction.id,
        transaction.bookId,
        transaction.memberId,
        dateFormat.format(transaction.borrowDate),
        transaction.status,
        transaction.fine,
      ]);
    }

    return await _saveCSV('monthly_report_${year}_${month}', rows);
  }

  // Export laporan lengkap (komprehensif)
  Future<String> exportComprehensiveReport() async {
    final books = await DatabaseHelper.instance.readAllBooks();
    final members = await DatabaseHelper.instance.readAllMembers();
    final transactions = await DatabaseHelper.instance.readAllTransactions();
    final totalFines = await DatabaseHelper.instance.getTotalFinesCollected();

    final List<List<dynamic>> rows = [
      ['LAPORAN PERPUSTAKAAN LENGKAP'],
      ['Tanggal Export', DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())],
      [],
      ['RINGKASAN'],
      ['Total Buku', books.length],
      ['Total Member', members.length],
      ['Total Transaksi', transactions.length],
      ['Total Denda Terkumpul', 'Rp $totalFines'],
      [],
      ['BUKU TERSEDIA'],
      ['Judul', 'Pengarang', 'Kategori', 'Stok'],
    ];

    for (final book in books.where((b) => b.stock > 0)) {
      rows.add([book.title, book.author, book.category, book.stock]);
    }

    return await _saveCSV('comprehensive_report', rows);
  }

  // Helper function untuk save CSV
  Future<String> _saveCSV(String filename, List<List<dynamic>> rows) async {
    final String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '${directory.path}/${filename}_$timestamp.csv';

    final File file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }
}
