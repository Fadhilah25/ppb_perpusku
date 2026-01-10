import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpusku/features/transactions/providers/transaction_provider.dart';
import 'package:perpusku/features/transactions/screens/borrow_screen.dart';
import 'package:perpusku/features/transactions/screens/return_screen.dart';
import 'package:perpusku/features/transactions/widgets/transaction_card.dart';
import 'package:perpusku/core/constants/app_strings.dart';
import 'package:perpusku/core/constants/app_colors.dart';
import 'package:perpusku/core/widgets/empty_state.dart';
import 'package:perpusku/core/services/export_service.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<TransactionProvider>().loadTransactions();
  }

  Future<void> _handleExport(String type) async {
    final provider = context.read<TransactionProvider>();
    if (provider.transactions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada data untuk diexport'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Menyiapkan export...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      if (type == 'csv') {
        final file = await ExportService().exportTransactionsToCSV(
          provider.transactions,
        );
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ CSV berhasil disimpan!\n${file.path}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (type == 'pdf') {
        final file = await ExportService().exportTransactionsToPDF(
          provider.transactions,
        );
        if (mounted) {
          Navigator.pop(context); // Close loading
          await ExportService().sharePDF(file);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactionHistory),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            onSelected: _handleExport,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Export to CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Export to PDF'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.transactions.isEmpty) {
            return EmptyState(
              icon: Icons.swap_horiz_outlined,
              title: AppStrings.noData,
              message: 'Belum ada transaksi.\nMulai peminjaman buku!',
              action: ElevatedButton.icon(
                onPressed: () => _navigateToBorrow(context),
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.borrowBook),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.transactions[index];
                return TransactionCard(
                  transaction: transaction,
                  onReturn: transaction.status != 'returned'
                      ? () => _navigateToReturn(context, transaction.id!)
                      : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToBorrow(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToBorrow(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BorrowScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToReturn(BuildContext context, int transactionId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReturnScreen(transactionId: transactionId),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }
}
