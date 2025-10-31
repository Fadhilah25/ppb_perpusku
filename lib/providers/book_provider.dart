import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../database/database_helper.dart';

class BookProvider extends ChangeNotifier {
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;

  List<Book> get books =>
      _filteredBooks.isEmpty &&
          _searchQuery.isEmpty &&
          _selectedCategory == null
      ? _books
      : _filteredBooks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  final List<String> categories = [
    'Fiksi',
    'Non-Fiksi',
    'Sains',
    'Teknologi',
    'Sejarah',
    'Biografi',
    'Anak-anak',
    'Komik',
    'Lainnya',
  ];

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();

    _books = await DatabaseHelper.instance.readAllBooks();
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    _isLoading = true;
    notifyListeners();

    await DatabaseHelper.instance.createBook(book);
    await loadBooks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateBook(Book book) async {
    _isLoading = true;
    notifyListeners();

    await DatabaseHelper.instance.updateBook(book);
    await loadBooks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteBook(int id) async {
    _isLoading = true;
    notifyListeners();

    await DatabaseHelper.instance.deleteBook(id);
    await loadBooks();

    _isLoading = false;
    notifyListeners();
  }

  void searchBooks(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _filteredBooks = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredBooks = _books;

    if (_searchQuery.isNotEmpty) {
      _filteredBooks = _filteredBooks.where((book) {
        return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (book.isbn?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    if (_selectedCategory != null) {
      _filteredBooks = _filteredBooks.where((book) {
        return book.category == _selectedCategory;
      }).toList();
    }
  }

  Future<void> updateBookStock(int bookId, int change) async {
    final book = _books.firstWhere((b) => b.id == bookId);
    final updatedBook = book.copy(stock: book.stock + change);
    await updateBook(updatedBook);
  }
}
