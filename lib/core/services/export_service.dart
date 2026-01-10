import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../features/transactions/models/transaction.dart' as app;
import '../../features/books/models/book.dart';
import '../../features/members/models/member.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // ============ CSV EXPORT ============

  Future<File> exportTransactionsToCSV(
    List<app.Transaction> transactions,
  ) async {
    final List<List<dynamic>> rows = [
      [
        'ID',
        'Buku',
        'Anggota',
        'Tanggal Pinjam',
        'Jatuh Tempo',
        'Tanggal Kembali',
        'Denda',
        'Status',
      ],
    ];

    for (var transaction in transactions) {
      rows.add([
        transaction.id,
        transaction.bookTitle ?? '-',
        transaction.memberName ?? '-',
        _dateFormat.format(transaction.borrowDate),
        _dateFormat.format(transaction.dueDate),
        transaction.returnDate != null
            ? _dateFormat.format(transaction.returnDate!)
            : '-',
        _currencyFormat.format(transaction.fine),
        transaction.status,
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/transactions_$timestamp.csv');

    return await file.writeAsString(csv);
  }

  Future<File> exportBooksToCSV(List<Book> books) async {
    final List<List<dynamic>> rows = [
      ['ID', 'Judul', 'Pengarang', 'ISBN', 'Kategori', 'Stok', 'Ditambahkan'],
    ];

    for (var book in books) {
      rows.add([
        book.id,
        book.title,
        book.author,
        book.isbn,
        book.category,
        book.stock,
        _dateFormat.format(book.createdAt),
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/books_$timestamp.csv');

    return await file.writeAsString(csv);
  }

  Future<File> exportMembersToCSV(List<Member> members) async {
    final List<List<dynamic>> rows = [
      ['ID', 'Nama', 'ID Anggota', 'Telepon', 'Tanggal Registrasi'],
    ];

    for (var member in members) {
      rows.add([
        member.id,
        member.name,
        member.memberId,
        member.phone,
        _dateFormat.format(member.registrationDate),
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/members_$timestamp.csv');

    return await file.writeAsString(csv);
  }

  // ============ PDF EXPORT ============

  Future<File> exportTransactionsToPDF(
    List<app.Transaction> transactions,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Laporan Transaksi Peminjaman',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Tanggal Export: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: [
              'No',
              'Buku',
              'Anggota',
              'Pinjam',
              'Kembali',
              'Denda',
              'Status',
            ],
            data: transactions.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final t = entry.value;
              return [
                idx.toString(),
                t.bookTitle ?? '-',
                t.memberName ?? '-',
                _dateFormat.format(t.borrowDate),
                t.returnDate != null ? _dateFormat.format(t.returnDate!) : '-',
                _currencyFormat.format(t.fine),
                t.status,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Total Transaksi: ${transactions.length}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Total Denda: ${_currencyFormat.format(transactions.fold(0.0, (sum, t) => sum + t.fine))}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/transactions_$timestamp.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> exportBooksToPDF(List<Book> books) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Daftar Koleksi Buku',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Tanggal Export: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['No', 'Judul', 'Pengarang', 'ISBN', 'Kategori', 'Stok'],
            data: books.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final b = entry.value;
              return [
                idx.toString(),
                b.title,
                b.author,
                b.isbn,
                b.category,
                b.stock.toString(),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Total Buku: ${books.length}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Total Stok: ${books.fold(0, (sum, b) => sum + b.stock)}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/books_$timestamp.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Share or preview PDF
  Future<void> sharePDF(File file) async {
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: file.path.split('/').last,
    );
  }

  Future<void> printPDF(File file) async {
    await Printing.layoutPdf(onLayout: (format) async => file.readAsBytes());
  }
}
