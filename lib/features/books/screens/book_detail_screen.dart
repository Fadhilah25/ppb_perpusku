import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:perpusku/features/books/models/book.dart';
import 'package:perpusku/features/books/providers/book_provider.dart';
import 'package:perpusku/features/books/screens/book_form_screen.dart';
import 'package:perpusku/core/constants/app_strings.dart';
import 'package:perpusku/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Book? _book;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<BookProvider>();
    final book = await provider.getBookById(widget.bookId);

    setState(() {
      _book = book;
      _isLoading = false;
    });
  }

  Future<void> _deleteBook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text(
          'Apakah Anda yakin ingin menghapus buku "${_book!.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<BookProvider>().deleteBook(widget.bookId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.bookDeletedSuccess)),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _editBook() async {
    if (_book == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookFormScreen(book: _book)),
    );

    if (result == true) {
      _loadBook();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.bookDetail)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.bookDetail)),
        body: const Center(child: Text('Buku tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bookDetail),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editBook),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteBook),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover photo
            _buildCoverImage(),
            // Book details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _book!.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Author
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _book!.author,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // ISBN
                  _buildInfoRow(Icons.qr_code, 'ISBN', _book!.isbn),
                  const SizedBox(height: 12),
                  // Category
                  _buildInfoRow(
                    Icons.category,
                    AppStrings.bookCategory,
                    _book!.category,
                  ),
                  const SizedBox(height: 12),
                  // Stock
                  _buildInfoRow(
                    Icons.inventory,
                    AppStrings.bookStock,
                    '${_book!.stock}',
                  ),
                  const SizedBox(height: 12),
                  // Availability
                  _buildInfoRow(
                    _book!.isAvailable ? Icons.check_circle : Icons.cancel,
                    AppStrings.status,
                    _book!.isAvailable
                        ? AppStrings.available
                        : AppStrings.notAvailable,
                    valueColor: _book!.isAvailable
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  // Created date
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Ditambahkan',
                    DateFormat('dd MMM yyyy, HH:mm').format(_book!.createdAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (_book!.coverPhoto != null && _book!.coverPhoto!.isNotEmpty) {
      return Image.file(
        File(_book!.coverPhoto!),
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 300,
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.book, size: 80, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
