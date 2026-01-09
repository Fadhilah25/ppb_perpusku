import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  List<BorrowTransaction> _transactions = [];
  bool _isLoading = false;

  List<BorrowTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  List<BorrowTransaction> get activeTransactions =>
      _transactions.where((t) => t.status == 'borrowed').toList();

  List<BorrowTransaction> get overdueTransactions =>
      _transactions.where((t) => t.isOverdue).toList();

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await DatabaseHelper.instance.readAllTransactions();

    _isLoading = false;
    notifyListeners();
  }

  Future<BorrowTransaction> borrowBook({
    required int bookId,
    required int memberId,
    required int borrowDays,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final borrowDate = DateTime.now();
    final dueDate = borrowDate.add(Duration(days: borrowDays));

    final transaction = BorrowTransaction(
      bookId: bookId,
      memberId: memberId,
      borrowDate: borrowDate,
      dueDate: dueDate,
      status: 'borrowed',
      notes: notes,
    );

    final createdTransaction = await DatabaseHelper.instance.createTransaction(
      transaction,
    );

    // Update book stock
    final book = await DatabaseHelper.instance.readBook(bookId);
    if (book != null) {
      await DatabaseHelper.instance.updateBook(
        book.copy(stock: book.stock - 1),
      );
    }

    await loadTransactions();

    _isLoading = false;
    notifyListeners();

    return createdTransaction;
  }

  Future<void> returnBook({
    required int transactionId,
    double? customFine,
  }) async {
    _isLoading = true;
    notifyListeners();

    final transaction = await DatabaseHelper.instance.readTransaction(
      transactionId,
    );
    if (transaction != null) {
      final fine = customFine ?? transaction.calculateFine();
      final updatedTransaction = transaction.copy(
        returnDate: DateTime.now(),
        status: 'returned',
        fine: fine,
      );

      await DatabaseHelper.instance.updateTransaction(updatedTransaction);

      // Update book stock
      final book = await DatabaseHelper.instance.readBook(transaction.bookId);
      if (book != null) {
        await DatabaseHelper.instance.updateBook(
          book.copy(stock: book.stock + 1),
        );
      }

      await loadTransactions();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<BorrowTransaction>> getTransactionsByMember(int memberId) async {
    return await DatabaseHelper.instance.getTransactionsByMember(memberId);
  }

  Future<Map<String, dynamic>> getTransactionWithDetails(
    int transactionId,
  ) async {
    final transaction = await DatabaseHelper.instance.readTransaction(
      transactionId,
    );
    if (transaction == null) return {};

    final book = await DatabaseHelper.instance.readBook(transaction.bookId);
    final member = await DatabaseHelper.instance.readMember(
      transaction.memberId,
    );

    return {'transaction': transaction, 'book': book, 'member': member};
  }

  double calculateFine(
    BorrowTransaction transaction, {
    double finePerDay = 1000.0,
  }) {
    return transaction.calculateFine(finePerDay: finePerDay);
  }
}
