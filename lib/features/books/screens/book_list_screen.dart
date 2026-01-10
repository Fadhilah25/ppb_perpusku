import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpusku/features/books/providers/book_provider.dart';
import 'package:perpusku/features/books/screens/book_form_screen.dart';
import 'package:perpusku/features/books/screens/book_detail_screen.dart';
import 'package:perpusku/features/books/widgets/book_card.dart';
import 'package:perpusku/core/constants/app_strings.dart';
import 'package:perpusku/core/constants/app_colors.dart';
import 'package:perpusku/core/widgets/empty_state.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<BookProvider>();
    await provider.loadBooks();
    final categories = await provider.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bookList),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchBook,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<BookProvider>().setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                context.read<BookProvider>().setSearchQuery(value);
              },
            ),
          ),
          // Category filter
          if (_categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: Consumer<BookProvider>(
                builder: (context, provider, child) {
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text(AppStrings.allCategories),
                          selected: provider.selectedCategory == null,
                          onSelected: (selected) {
                            if (selected) {
                              provider.setCategory(null);
                            }
                          },
                        ),
                      ),
                      ..._categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: provider.selectedCategory == category,
                            onSelected: (selected) {
                              provider.setCategory(selected ? category : null);
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          // Book list
          Expanded(
            child: Consumer<BookProvider>(
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

                if (provider.books.isEmpty) {
                  return EmptyState(
                    icon: Icons.book_outlined,
                    title: AppStrings.noData,
                    message:
                        'Belum ada buku yang ditambahkan.\nTambahkan buku pertama Anda!',
                    action: ElevatedButton.icon(
                      onPressed: () => _navigateToBookForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text(AppStrings.addBook),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.books.length,
                    itemBuilder: (context, index) {
                      final book = provider.books[index];
                      return BookCard(
                        book: book,
                        onTap: () => _navigateToBookDetail(context, book.id!),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToBookForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToBookForm(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookFormScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToBookDetail(BuildContext context, int bookId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookDetailScreen(bookId: bookId)),
    );
    if (result == true) {
      _loadData();
    }
  }
}
