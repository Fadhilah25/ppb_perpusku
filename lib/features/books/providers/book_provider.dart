import 'package:flutter/foundation.dart';
import 'package:perpusku/features/books/models/book.dart';
import 'package:perpusku/core/database/database_helper.dart';

class BookProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  List<Book> get books => _filteredBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _dbHelper.getAllBooks();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBook(Book book) async {
    try {
      final id = await _dbHelper.insertBook(book);
      final newBook = book.copyWith(id: id);
      _books.add(newBook);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await _dbHelper.updateBook(book);
      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = book;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      await _dbHelper.deleteBook(id);
      _books.removeWhere((b) => b.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Book?> getBookById(int id) async {
    try {
      return await _dbHelper.getBookById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> updateBookStock(int bookId, int newStock) async {
    try {
      await _dbHelper.updateBookStock(bookId, newStock);
      final index = _books.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        _books[index] = _books[index].copyWith(stock: newStock);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
    notifyListeners();
  }

  Future<List<String>> getCategories() async {
    try {
      return await _dbHelper.getAllCategories();
    } catch (e) {
      return [];
    }
  }

  void _applyFilters() {
    _filteredBooks = _books;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredBooks = _filteredBooks.where((book) {
        final query = _searchQuery.toLowerCase();
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            book.isbn.toLowerCase().contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _filteredBooks = _filteredBooks
          .where((book) => book.category == _selectedCategory)
          .toList();
    }
  }
}
