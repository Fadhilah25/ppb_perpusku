import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/member_provider.dart';
import '../../models/book.dart';
import '../../models/member.dart';
import '../../services/qr_scanner_service.dart';
import '../../services/notification_service.dart';

class BorrowBookScreen extends StatefulWidget {
  const BorrowBookScreen({super.key});

  @override
  State<BorrowBookScreen> createState() => _BorrowBookScreenState();
}

class _BorrowBookScreenState extends State<BorrowBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Book? _selectedBook;
  Member? _selectedMember;
  int _borrowDays = 7;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _borrowBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih buku yang akan dipinjam')),
      );
      return;
    }

    if (_selectedMember == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih anggota peminjam')));
      return;
    }

    if (!_selectedBook!.isAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Buku tidak tersedia')));
      return;
    }

    try {
      final transaction = await context.read<TransactionProvider>().borrowBook(
        bookId: _selectedBook!.id!,
        memberId: _selectedMember!.id!,
        borrowDays: _borrowDays,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // Send notifications
      final dueDate = DateTime.now().add(Duration(days: _borrowDays));
      await NotificationService.instance.showBorrowSuccessNotification(
        _selectedBook!.title,
        _selectedMember!.name,
        dueDate,
      );
      await NotificationService.instance.scheduleReturnReminder(
        transaction,
        _selectedBook!.title,
        _selectedMember!.name,
      );

      // Reload books to update stock
      if (mounted) {
        await context.read<BookProvider>().loadBooks();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Buku berhasil dipinjam')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _scanBookQR() async {
    final scannedCode = await QRScannerService.scanQRCode(context);

    if (scannedCode != null && mounted) {
      // Try to find book by ID
      final bookProvider = context.read<BookProvider>();
      try {
        final bookId = int.parse(scannedCode);
        final book = bookProvider.books.firstWhere(
          (b) => b.id == bookId,
          orElse: () => throw Exception('Buku tidak ditemukan'),
        );

        setState(() {
          _selectedBook = book;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Buku "${book.title}" dipilih')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.now().add(Duration(days: _borrowDays));
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(title: const Text('Pinjam Buku')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Pilih Buku',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildBookSelector()),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _scanBookQR,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Pilih Anggota',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildMemberSelector(),
            const SizedBox(height: 24),
            const Text(
              'Durasi Peminjaman',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jumlah Hari:'),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _borrowDays > 1
                                  ? () {
                                      setState(() {
                                        _borrowDays--;
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              '$_borrowDays hari',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _borrowDays < 30
                                  ? () {
                                      setState(() {
                                        _borrowDays++;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jatuh Tempo:'),
                        Text(
                          dateFormat.format(dueDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                prefixIcon: Icon(Icons.note),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _borrowBook,
              icon: const Icon(Icons.book),
              label: const Text('Pinjam Buku'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSelector() {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        final availableBooks = provider.books
            .where((book) => book.isAvailable)
            .toList();

        return Card(
          child: ListTile(
            leading: const Icon(Icons.book),
            title: Text(
              _selectedBook?.title ?? 'Pilih Buku',
              style: TextStyle(
                color: _selectedBook == null ? Colors.grey : null,
              ),
            ),
            subtitle: _selectedBook != null
                ? Text('Stok: ${_selectedBook!.stock}')
                : null,
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () async {
              final book = await showDialog<Book>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Pilih Buku'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: availableBooks.isEmpty
                        ? const Text('Tidak ada buku tersedia')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: availableBooks.length,
                            itemBuilder: (context, index) {
                              final book = availableBooks[index];
                              return ListTile(
                                title: Text(book.title),
                                subtitle: Text(
                                  '${book.author} - Stok: ${book.stock}',
                                ),
                                onTap: () => Navigator.pop(context, book),
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ],
                ),
              );

              if (book != null) {
                setState(() {
                  _selectedBook = book;
                });
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMemberSelector() {
    return Consumer<MemberProvider>(
      builder: (context, provider, child) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              _selectedMember?.name ?? 'Pilih Anggota',
              style: TextStyle(
                color: _selectedMember == null ? Colors.grey : null,
              ),
            ),
            subtitle: _selectedMember != null
                ? Text('ID: ${_selectedMember!.memberId}')
                : null,
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () async {
              final member = await showDialog<Member>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Pilih Anggota'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: provider.members.isEmpty
                        ? const Text('Tidak ada anggota terdaftar')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: provider.members.length,
                            itemBuilder: (context, index) {
                              final member = provider.members[index];
                              return ListTile(
                                title: Text(member.name),
                                subtitle: Text('ID: ${member.memberId}'),
                                onTap: () => Navigator.pop(context, member),
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ],
                ),
              );

              if (member != null) {
                setState(() {
                  _selectedMember = member;
                });
              }
            },
          ),
        );
      },
    );
  }
}
