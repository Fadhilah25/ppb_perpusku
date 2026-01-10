import 'package:flutter/foundation.dart';
import 'package:perpusku/features/transactions/models/transaction.dart';
import 'package:perpusku/core/database/database_helper.dart';
import 'package:perpusku/core/services/notification_service.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  List<Transaction> get activeTransactions => _transactions
      .where((t) => t.status == 'borrowed' || t.status == 'overdue')
      .toList();
  List<Transaction> get overdueTransactions => _transactions
      .where((t) => t.isOverdue && t.status != 'returned')
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _dbHelper.getAllTransactions();
      _transactions = result;
      _updateOverdueStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> borrowBook(int bookId, int memberId, int durationDays) async {
    try {
      final borrowDate = DateTime.now();
      final dueDate = borrowDate.add(Duration(days: durationDays));

      // Get book info for notification
      final book = await _dbHelper.getBookById(bookId);

      final transaction = Transaction(
        bookId: bookId,
        memberId: memberId,
        borrowDate: borrowDate,
        dueDate: dueDate,
        status: 'borrowed',
      );

      final id = await _dbHelper.insertTransaction(transaction);

      // Schedule return reminder notification (1 day before due date)
      if (book != null) {
        await NotificationService().scheduleReturnReminder(
          id,
          book.title,
          dueDate,
        );
      }

      // Update book stock
      if (book != null && book.stock > 0) {
        await _dbHelper.updateBookStock(bookId, book.stock - 1);
      }

      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> returnBook(int transactionId) async {
    try {
      final transaction = await _dbHelper.getTransactionById(transactionId);
      if (transaction == null) {
        throw Exception('Transaction not found');
      }

      final returnDate = DateTime.now();
      final fine = transaction.copyWith(returnDate: returnDate).calculateFine();

      final updatedTransaction = transaction.copyWith(
        returnDate: returnDate,
        fine: fine,
        status: 'returned',
      );

      await _dbHelper.updateTransaction(updatedTransaction);

      // Cancel scheduled notification for this transaction
      await NotificationService().cancelNotification(transactionId + 1000);

      // Update book stock
      final book = await _dbHelper.getBookById(transaction.bookId);
      if (book != null) {
        await _dbHelper.updateBookStock(transaction.bookId, book.stock + 1);
      }

      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Transaction>> getTransactionsByMember(int memberId) async {
    try {
      final result = await _dbHelper.getTransactionsByMember(memberId);
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Transaction>> getTransactionsByBook(int bookId) async {
    try {
      final result = await _dbHelper.getTransactionsByBook(bookId);
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _updateOverdueStatus() {
    // Update status to 'overdue' for borrowed books past due date
    for (var transaction in _transactions) {
      if (transaction.isOverdue && transaction.status == 'borrowed') {
        transaction = transaction.copyWith(status: 'overdue');
        _dbHelper.updateTransaction(transaction);
      }
    }
  }

  double calculateFine(DateTime dueDate, DateTime? returnDate) {
    final referenceDate = returnDate ?? DateTime.now();
    if (referenceDate.isAfter(dueDate)) {
      final daysLate = referenceDate.difference(dueDate).inDays;
      return daysLate * Transaction.finePerDay;
    }
    return 0.0;
  }

  int calculateDaysLate(DateTime dueDate, DateTime? returnDate) {
    final referenceDate = returnDate ?? DateTime.now();
    if (referenceDate.isAfter(dueDate)) {
      return referenceDate.difference(dueDate).inDays;
    }
    return 0;
  }
}
