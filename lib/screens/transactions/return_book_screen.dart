import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/book_provider.dart';
import '../../models/transaction.dart';

class ReturnBookScreen extends StatefulWidget {
  const ReturnBookScreen({super.key});

  @override
  State<ReturnBookScreen> createState() => _ReturnBookScreenState();
}

class _ReturnBookScreenState extends State<ReturnBookScreen> {
  BorrowTransaction? _selectedTransaction;
  final _fineController = TextEditingController();
  bool _useCustomFine = false;
  double _finePerDay = 1000.0;

  @override
  void dispose() {
    _fineController.dispose();
    super.dispose();
  }

  Future<void> _returnBook() async {
    if (_selectedTransaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih transaksi yang akan dikembalikan')),
      );
      return;
    }

    double? customFine;
    if (_useCustomFine) {
      final fineValue = double.tryParse(_fineController.text);
      if (fineValue == null || fineValue < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denda harus berupa angka positif')),
        );
        return;
      }
      customFine = fineValue;
    }

    try {
      await context.read<TransactionProvider>().returnBook(
        transactionId: _selectedTransaction!.id!,
        customFine: customFine,
      );

      // Reload books to update stock
      if (mounted) {
        await context.read<BookProvider>().loadBooks();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil dikembalikan')),
        );
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Kembalikan Buku')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pilih Transaksi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildTransactionSelector(),
          if (_selectedTransaction != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Tanggal Pinjam',
                      dateFormat.format(_selectedTransaction!.borrowDate),
                    ),
                    _buildDetailRow(
                      'Jatuh Tempo',
                      dateFormat.format(_selectedTransaction!.dueDate),
                    ),
                    _buildDetailRow(
                      'Tanggal Kembali',
                      dateFormat.format(DateTime.now()),
                    ),
                    const Divider(height: 24),
                    if (_selectedTransaction!.isOverdue) ...[
                      _buildDetailRow(
                        'Keterlambatan',
                        '${_selectedTransaction!.daysOverdue} hari',
                        valueColor: Colors.red,
                      ),
                      _buildDetailRow(
                        'Denda Otomatis',
                        'Rp ${_selectedTransaction!.calculateFine(finePerDay: _finePerDay).toStringAsFixed(0)}',
                        valueColor: Colors.red,
                      ),
                    ] else ...[
                      const Text(
                        'Tidak ada keterlambatan',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _useCustomFine,
                          onChanged: (value) {
                            setState(() {
                              _useCustomFine = value ?? false;
                              if (!_useCustomFine) {
                                _fineController.clear();
                              }
                            });
                          },
                        ),
                        const Text('Gunakan denda kustom'),
                      ],
                    ),
                    if (_useCustomFine) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _fineController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Denda (Rp)',
                          prefixIcon: Icon(Icons.money),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _returnBook,
              icon: const Icon(Icons.assignment_return),
              label: const Text('Kembalikan Buku'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionSelector() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final activeTransactions = provider.activeTransactions;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: Text(
              _selectedTransaction != null
                  ? 'Transaksi #${_selectedTransaction!.id}'
                  : 'Pilih Transaksi',
              style: TextStyle(
                color: _selectedTransaction == null ? Colors.grey : null,
              ),
            ),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () async {
              final transaction = await showDialog<BorrowTransaction>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Pilih Transaksi'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: activeTransactions.isEmpty
                        ? const Text('Tidak ada transaksi aktif')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: activeTransactions.length,
                            itemBuilder: (context, index) {
                              final trans = activeTransactions[index];
                              return FutureBuilder<Map<String, dynamic>>(
                                future: provider.getTransactionWithDetails(
                                  trans.id!,
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const ListTile(
                                      title: Text('Memuat...'),
                                    );
                                  }

                                  final data = snapshot.data!;
                                  final book = data['book'];
                                  final member = data['member'];

                                  return ListTile(
                                    title: Text(
                                      book?.title ?? 'Buku tidak ditemukan',
                                    ),
                                    subtitle: Text(
                                      '${member?.name ?? "Anggota tidak ditemukan"}\n'
                                      '${trans.isOverdue ? "⚠️ Terlambat ${trans.daysOverdue} hari" : "Tepat waktu"}',
                                    ),
                                    isThreeLine: true,
                                    leading: Icon(
                                      trans.isOverdue
                                          ? Icons.warning
                                          : Icons.access_time,
                                      color: trans.isOverdue
                                          ? Colors.red
                                          : Colors.orange,
                                    ),
                                    onTap: () => Navigator.pop(context, trans),
                                  );
                                },
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

              if (transaction != null) {
                setState(() {
                  _selectedTransaction = transaction;
                });
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: valueColor)),
        ],
      ),
    );
  }
}
