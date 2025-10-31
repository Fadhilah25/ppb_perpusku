import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import 'borrow_book_screen.dart';
import 'return_book_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Peminjaman'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Riwayat'),
            Tab(text: 'Terlambat'),
          ],
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadTransactions(),
            child: _buildTabContent(provider),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'borrow',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BorrowBookScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'return',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReturnBookScreen(),
                ),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.assignment_return),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(TransactionProvider provider) {
    switch (_selectedTab) {
      case 0:
        return _buildTransactionList(
          provider.activeTransactions,
          'Tidak ada transaksi aktif',
        );
      case 1:
        return _buildTransactionList(
          provider.transactions,
          'Belum ada riwayat transaksi',
        );
      case 2:
        return _buildTransactionList(
          provider.overdueTransactions,
          'Tidak ada peminjaman terlambat',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTransactionList(List transactions, String emptyMessage) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return FutureBuilder<Map<String, dynamic>>(
          future: context.read<TransactionProvider>().getTransactionWithDetails(
            transactions[index].id!,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Card(
                child: ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Memuat...'),
                ),
              );
            }

            final data = snapshot.data!;
            final transaction = data['transaction'];
            final book = data['book'];
            final member = data['member'];

            return _buildTransactionCard(transaction, book, member);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(
    dynamic transaction,
    dynamic book,
    dynamic member,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isOverdue = transaction.isOverdue;
    final isReturned = transaction.status == 'returned';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          isReturned
              ? Icons.check_circle
              : (isOverdue ? Icons.warning : Icons.access_time),
          color: isReturned
              ? Colors.green
              : (isOverdue ? Colors.red : Colors.orange),
          size: 32,
        ),
        title: Text(
          book?.title ?? 'Buku tidak ditemukan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(member?.name ?? 'Anggota tidak ditemukan'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('ID Transaksi', '#${transaction.id}'),
                _buildInfoRow(
                  'Tanggal Pinjam',
                  dateFormat.format(transaction.borrowDate),
                ),
                _buildInfoRow(
                  'Jatuh Tempo',
                  dateFormat.format(transaction.dueDate),
                ),
                if (transaction.returnDate != null)
                  _buildInfoRow(
                    'Tanggal Kembali',
                    dateFormat.format(transaction.returnDate),
                  ),
                if (isOverdue && !isReturned)
                  _buildInfoRow(
                    'Keterlambatan',
                    '${transaction.daysOverdue} hari',
                    color: Colors.red,
                  ),
                if (transaction.fine > 0)
                  _buildInfoRow(
                    'Denda',
                    'Rp ${transaction.fine.toStringAsFixed(0)}',
                    color: Colors.red,
                  ),
                _buildInfoRow(
                  'Status',
                  isReturned ? 'Dikembalikan' : 'Dipinjam',
                  color: isReturned ? Colors.green : Colors.orange,
                ),
                if (transaction.notes != null)
                  _buildInfoRow('Catatan', transaction.notes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, color: color)),
          ),
        ],
      ),
    );
  }
}
