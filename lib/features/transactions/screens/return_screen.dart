import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpusku/features/transactions/providers/transaction_provider.dart';
import 'package:perpusku/features/transactions/models/transaction.dart';
import 'package:perpusku/core/constants/app_strings.dart';
import 'package:perpusku/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class ReturnScreen extends StatefulWidget {
  final int transactionId;

  const ReturnScreen({super.key, required this.transactionId});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  Transaction? _transaction;
  bool _isLoading = true;
  double _fine = 0;
  int _daysLate = 0;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final transactions = context.read<TransactionProvider>().transactions;
    final transaction = transactions.firstWhere(
      (t) => t.id == widget.transactionId,
    );

    final fine = transaction.calculateFine();
    final daysLate = transaction.daysLate;

    setState(() {
      _transaction = transaction;
      _fine = fine;
      _daysLate = daysLate;
      _isLoading = false;
    });
  }

  Future<void> _submitReturn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TransactionProvider>().returnBook(
        widget.transactionId,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.returnSuccess)));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.returnBook)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.returnBook)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _transaction!.bookTitle ?? 'Unknown Book',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _transaction!.memberName ?? 'Unknown Member',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      'Tanggal Pinjam',
                      DateFormat(
                        'dd MMMM yyyy',
                      ).format(_transaction!.borrowDate),
                    ),
                    _buildInfoRow(
                      'Tanggal Jatuh Tempo',
                      DateFormat('dd MMMM yyyy').format(_transaction!.dueDate),
                    ),
                    _buildInfoRow(
                      'Tanggal Kembali',
                      DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_daysLate > 0) ...[
              Card(
                color: AppColors.error.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(
                            'Terlambat',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('Hari Terlambat', '$_daysLate hari'),
                      _buildInfoRow(
                        'Denda per Hari',
                        'Rp ${NumberFormat('#,###').format(Transaction.finePerDay)}',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Total Denda',
                        'Rp ${NumberFormat('#,###').format(_fine)}',
                        valueColor: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                color: AppColors.success.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Text(
                        'Pengembalian tepat waktu',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitReturn,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Konfirmasi Pengembalian'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
