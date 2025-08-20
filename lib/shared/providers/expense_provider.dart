import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../../core/services/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  double get totalExpensesThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _expenses
        .where((expense) => 
            expense.dateTime.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            expense.dateTime.isBefore(endOfMonth.add(const Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get totalExpensesToday {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _expenses
        .where((expense) => 
            expense.dateTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            expense.dateTime.isBefore(endOfDay))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> categoryTotals = {};
    
    for (final expense in _expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryTotals;
  }

  List<Expense> getExpensesForDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) => 
            expense.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.dateTime.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = DatabaseService.getAllExpenses();
      _expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await DatabaseService.addExpense(expense);
      _expenses.insert(0, expense);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await DatabaseService.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await DatabaseService.deleteExpense(id);
      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  void filterExpensesByCategory(String? category) {
    if (category == null) {
      loadExpenses();
      return;
    }
    
    _expenses = DatabaseService.getExpensesByCategory(category);
    _expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
  }
}