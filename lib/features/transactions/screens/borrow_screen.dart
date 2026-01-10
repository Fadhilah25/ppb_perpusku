import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpusku/features/books/providers/book_provider.dart';
import 'package:perpusku/features/members/providers/member_provider.dart';
import 'package:perpusku/features/transactions/providers/transaction_provider.dart';
import 'package:perpusku/features/books/models/book.dart';
import 'package:perpusku/features/members/models/member.dart';
import 'package:perpusku/core/constants/app_strings.dart';

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  Book? _selectedBook;
  Member? _selectedMember;
  int _duration = 7; // Default 7 days
  bool _isLoading = false;

  List<Book> _books = [];
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<BookProvider>().loadBooks();
    await context.read<MemberProvider>().loadMembers();

    setState(() {
      _books = context
          .read<BookProvider>()
          .books
          .where((b) => b.isAvailable)
          .toList();
      _members = context.read<MemberProvider>().members;
    });
  }

  Future<void> _submitBorrow() async {
    if (_selectedBook == null || _selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih buku dan anggota terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TransactionProvider>().borrowBook(
        _selectedBook!.id!,
        _selectedMember!.id!,
        _duration,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.borrowSuccess)));
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
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.borrowBook)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Select book
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(_selectedBook?.title ?? 'Pilih Buku'),
                      subtitle: _selectedBook != null
                          ? Text(
                              '${_selectedBook!.author} (Stok: ${_selectedBook!.stock})',
                            )
                          : null,
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () => _showBookPicker(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Select member
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(_selectedMember?.name ?? 'Pilih Anggota'),
                      subtitle: _selectedMember != null
                          ? Text('ID: ${_selectedMember!.memberId}')
                          : null,
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () => _showMemberPicker(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Duration
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Durasi Peminjaman',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: Text('$_duration hari')),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _duration > 1
                                    ? () => setState(() => _duration--)
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _duration < 30
                                    ? () => setState(() => _duration++)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Submit button
                  ElevatedButton(
                    onPressed: _submitBorrow,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Pinjam Buku'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showBookPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return ListTile(
            leading: const Icon(Icons.book),
            title: Text(book.title),
            subtitle: Text('${book.author} (Stok: ${book.stock})'),
            onTap: () {
              setState(() {
                _selectedBook = book;
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _showMemberPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(member.name),
            subtitle: Text('ID: ${member.memberId}'),
            onTap: () {
              setState(() {
                _selectedMember = member;
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
