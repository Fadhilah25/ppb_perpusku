import 'package:flutter/material.dart';
import 'package:perpusku/features/transactions/models/transaction.dart';
import 'package:perpusku/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onReturn;

  const TransactionCard({super.key, required this.transaction, this.onReturn});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.bookTitle ?? 'Unknown Book',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.memberName ?? 'Unknown Member',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pinjam: ${DateFormat('dd/MM/yyyy').format(transaction.borrowDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Icon(Icons.event, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Tempo: ${DateFormat('dd/MM/yyyy').format(transaction.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (transaction.returnDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Kembali: ${DateFormat('dd/MM/yyyy').format(transaction.returnDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (transaction.fine > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Denda: Rp ${NumberFormat('#,###').format(transaction.fine)}',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onReturn != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onReturn,
                  icon: const Icon(Icons.assignment_return),
                  label: const Text('Kembalikan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case 'borrowed':
        return AppColors.warning;
      case 'overdue':
        return AppColors.error;
      case 'returned':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText() {
    switch (transaction.status) {
      case 'borrowed':
        return 'Dipinjam';
      case 'overdue':
        return 'Terlambat';
      case 'returned':
        return 'Dikembalikan';
      default:
        return transaction.status;
    }
  }
}
