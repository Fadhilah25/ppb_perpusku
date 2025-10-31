import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';

class StatisticsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _popularBooks = [];
  Map<String, int> _monthlySummary = {};
  double _totalFines = 0.0;
  bool _isLoading = false;

  List<Map<String, dynamic>> get popularBooks => _popularBooks;
  Map<String, int> get monthlySummary => _monthlySummary;
  double get totalFines => _totalFines;
  bool get isLoading => _isLoading;

  Future<void> loadStatistics() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadPopularBooks(),
      _loadMonthlySummary(),
      _loadTotalFines(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadPopularBooks() async {
    _popularBooks = await DatabaseHelper.instance.getPopularBooks(limit: 10);
  }

  Future<void> _loadMonthlySummary() async {
    final now = DateTime.now();
    _monthlySummary = await DatabaseHelper.instance
        .getMonthlyTransactionSummary(now.year, now.month);
  }

  Future<void> _loadTotalFines() async {
    _totalFines = await DatabaseHelper.instance.getTotalFinesCollected();
  }

  Future<List<BorrowTransaction>> getOverdueTransactions() async {
    return await DatabaseHelper.instance.getOverdueTransactions();
  }

  Future<Map<String, int>> getMonthlyData(int year, int month) async {
    return await DatabaseHelper.instance.getMonthlyTransactionSummary(
      year,
      month,
    );
  }

  Future<List<Map<String, int>>> getYearlyData(int year) async {
    List<Map<String, int>> yearlyData = [];
    for (int month = 1; month <= 12; month++) {
      final data = await DatabaseHelper.instance.getMonthlyTransactionSummary(
        year,
        month,
      );
      yearlyData.add(data);
    }
    return yearlyData;
  }
}
