import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/export_service.dart';
import '../../services/notification_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<StatisticsProvider>().loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _showExportDialog(context);
              } else if (value == 'check_overdue') {
                _checkOverdueBooks(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Laporan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'check_overdue',
                child: Row(
                  children: [
                    Icon(Icons.warning),
                    SizedBox(width: 8),
                    Text('Cek Buku Terlambat'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCards(provider),
                const SizedBox(height: 24),
                _buildMonthlyChart(provider),
                const SizedBox(height: 24),
                _buildPopularBooks(provider),
                const SizedBox(height: 24),
                _buildOverdueList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(StatisticsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Bulan Ini',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Dipinjam',
                '${provider.monthlySummary['borrowed'] ?? 0}',
                Icons.book,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Dikembalikan',
                '${provider.monthlySummary['returned'] ?? 0}',
                Icons.assignment_return,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Total Denda Terkumpul',
          'Rp ${NumberFormat('#,###').format(provider.totalFines)}',
          Icons.money,
          Colors.orange,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: fullWidth
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: fullWidth ? TextAlign.start : TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(StatisticsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaksi Bulanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<Map<String, int>>>(
                future: provider.getYearlyData(DateTime.now().year),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final yearlyData = snapshot.data!;
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxValue(yearlyData) + 5,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'Mei',
                                'Jun',
                                'Jul',
                                'Agu',
                                'Sep',
                                'Okt',
                                'Nov',
                                'Des',
                              ];
                              if (value.toInt() >= 0 &&
                                  value.toInt() < months.length) {
                                return Text(
                                  months[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _createBarGroups(yearlyData),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Dipinjam', Colors.blue),
                const SizedBox(width: 24),
                _buildLegend('Dikembalikan', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue(List<Map<String, int>> data) {
    double max = 0;
    for (final month in data) {
      final borrowed = (month['borrowed'] ?? 0).toDouble();
      final returned = (month['returned'] ?? 0).toDouble();
      if (borrowed > max) max = borrowed;
      if (returned > max) max = returned;
    }
    return max;
  }

  List<BarChartGroupData> _createBarGroups(List<Map<String, int>> data) {
    return List.generate(data.length, (index) {
      final borrowed = (data[index]['borrowed'] ?? 0).toDouble();
      final returned = (data[index]['returned'] ?? 0).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: borrowed, color: Colors.blue, width: 8),
          BarChartRodData(toY: returned, color: Colors.green, width: 8),
        ],
      );
    });
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildPopularBooks(StatisticsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buku Paling Populer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (provider.popularBooks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Belum ada data',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...provider.popularBooks.take(5).map((book) {
                return ListTile(
                  leading: const Icon(
                    Icons.book,
                    size: 40,
                    color: Colors.indigo,
                  ),
                  title: Text(book['title'] ?? 'Unknown'),
                  subtitle: Text(book['author'] ?? 'Unknown Author'),
                  trailing: Chip(
                    label: Text('${book['borrow_count']} kali'),
                    backgroundColor: Colors.indigo[100],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Buku Terlambat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.warning, color: Colors.red[700]),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder(
              future: context
                  .read<StatisticsProvider>()
                  .getOverdueTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Tidak ada buku terlambat',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final overdueTransactions = snapshot.data!;
                return Column(
                  children: overdueTransactions.map((transaction) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: context
                          .read<TransactionProvider>()
                          .getTransactionWithDetails(transaction.id!),
                      builder: (context, detailSnapshot) {
                        if (!detailSnapshot.hasData) {
                          return const ListTile(title: Text('Memuat...'));
                        }

                        final data = detailSnapshot.data!;
                        final book = data['book'];
                        final member = data['member'];

                        return ListTile(
                          leading: const Icon(Icons.warning, color: Colors.red),
                          title: Text(book?.title ?? 'Buku tidak ditemukan'),
                          subtitle: Text(
                            '${member?.name ?? "Anggota tidak ditemukan"}\n'
                            'Terlambat ${transaction.daysOverdue} hari',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            'Rp ${transaction.calculateFine().toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExportDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Laporan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Export Semua Buku'),
              onTap: () async {
                Navigator.pop(context);
                await _exportData('books');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Export Semua Member'),
              onTap: () async {
                Navigator.pop(context);
                await _exportData('members');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Export Transaksi'),
              onTap: () async {
                Navigator.pop(context);
                await _exportData('transactions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Export Buku Terlambat'),
              onTap: () async {
                Navigator.pop(context);
                await _exportData('overdue');
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Export Buku Populer'),
              onTap: () async {
                Navigator.pop(context);
                await _exportData('popular');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Export Laporan Lengkap'),
              onTap: () async {
                Navigator.pop(context);
                await _exportData('comprehensive');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(String type) async {
    try {
      String filePath;

      switch (type) {
        case 'books':
          filePath = await ExportService.instance.exportBooks();
          break;
        case 'members':
          filePath = await ExportService.instance.exportMembers();
          break;
        case 'transactions':
          filePath = await ExportService.instance.exportTransactions();
          break;
        case 'overdue':
          filePath = await ExportService.instance.exportOverdueReport();
          break;
        case 'popular':
          filePath = await ExportService.instance.exportPopularBooksReport();
          break;
        case 'comprehensive':
          filePath = await ExportService.instance.exportComprehensiveReport();
          break;
        default:
          throw Exception('Unknown export type');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File berhasil di-export:\n$filePath'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saat export: $e')));
      }
    }
  }

  Future<void> _checkOverdueBooks(BuildContext context) async {
    final overdueTransactions = await context
        .read<StatisticsProvider>()
        .getOverdueTransactions();

    if (overdueTransactions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada buku terlambat')),
        );
      }
      return;
    }

    // Send notifications for all overdue books
    for (final transaction in overdueTransactions) {
      final details = await context
          .read<TransactionProvider>()
          .getTransactionWithDetails(transaction.id!);

      await NotificationService.instance.showOverdueNotification(
        transaction,
        details['book_title'] ?? 'Unknown',
        details['member_name'] ?? 'Unknown',
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ditemukan ${overdueTransactions.length} buku terlambat. '
            'Notifikasi telah dikirim.',
          ),
        ),
      );
    }
  }
}
