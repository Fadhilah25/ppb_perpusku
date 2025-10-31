import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../models/transaction.dart';
import '../../providers/member_provider.dart';
import '../../providers/transaction_provider.dart';
import 'add_edit_member_screen.dart';

class MemberDetailScreen extends StatelessWidget {
  final Member member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Anggota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditMemberScreen(member: member),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Anggota',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.badge, 'ID Anggota', member.memberId),
                  if (member.phone != null)
                    _buildInfoRow(Icons.phone, 'Telepon', member.phone!),
                  if (member.email != null)
                    _buildInfoRow(Icons.email, 'Email', member.email!),
                  const SizedBox(height: 24),
                  const Text(
                    'Riwayat Peminjaman',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildTransactionHistory(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.indigo,
            child: Text(
              member.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            member.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    return FutureBuilder<List<BorrowTransaction>>(
      future: context.read<TransactionProvider>().getTransactionsByMember(
        member.id!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Belum ada riwayat peminjaman',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final transactions = snapshot.data!;
        return Column(
          children: transactions.map((transaction) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  transaction.status == 'returned'
                      ? Icons.check_circle
                      : Icons.access_time,
                  color: transaction.status == 'returned'
                      ? Colors.green
                      : (transaction.isOverdue ? Colors.red : Colors.orange),
                ),
                title: Text('Book ID: ${transaction.bookId}'),
                subtitle: Text(
                  'Pinjam: ${_formatDate(transaction.borrowDate)}\n'
                  'Kembali: ${transaction.returnDate != null ? _formatDate(transaction.returnDate!) : "Belum dikembalikan"}',
                ),
                trailing: transaction.fine > 0
                    ? Text(
                        'Denda: Rp ${transaction.fine.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Anggota'),
        content: Text('Apakah Anda yakin ingin menghapus "${member.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<MemberProvider>().deleteMember(member.id!);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close detail screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anggota berhasil dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
