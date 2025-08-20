import 'package:flutter/foundation.dart';
import '../../shared/models/expense.dart';
import '../../shared/models/savings_goal.dart';
import '../../shared/models/user_data.dart';
import 'database_service.dart';

class DataValidationService {
  static bool validateExpense(Expense expense) {
    try {
      // Check required fields
      if (expense.id.isEmpty) {
        debugPrint('❌ Invalid expense: Empty ID');
        return false;
      }

      if (expense.amount <= 0) {
        debugPrint('❌ Invalid expense: Amount must be greater than 0');
        return false;
      }

      if (expense.amount > 1000000) {
        debugPrint('⚠️ Warning: Very large expense amount: ₱${expense.amount}');
      }

      if (expense.category.isEmpty) {
        debugPrint('❌ Invalid expense: Empty category');
        return false;
      }

      if (expense.description.isEmpty) {
        debugPrint('❌ Invalid expense: Empty description');
        return false;
      }

      // Check date is not in the future (more than 1 day ahead)
      if (expense.dateTime
          .isAfter(DateTime.now().add(const Duration(days: 1)))) {
        debugPrint(
            '❌ Invalid expense: Date cannot be more than 1 day in the future');
        return false;
      }

      // Check date is not too far in the past (more than 10 years)
      if (expense.dateTime
          .isBefore(DateTime.now().subtract(const Duration(days: 3650)))) {
        debugPrint('⚠️ Warning: Very old expense date: ${expense.dateTime}');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Expense validation error: $e');
      return false;
    }
  }

  static bool validateSavingsGoal(SavingsGoal goal) {
    try {
      // Check required fields
      if (goal.id.isEmpty) {
        debugPrint('❌ Invalid goal: Empty ID');
        return false;
      }

      if (goal.title.isEmpty) {
        debugPrint('❌ Invalid goal: Empty title');
        return false;
      }

      if (goal.targetAmount <= 0) {
        debugPrint('❌ Invalid goal: Target amount must be greater than 0');
        return false;
      }

      if (goal.targetAmount > 100000000) {
        // 100 million
        debugPrint('⚠️ Warning: Very large goal amount: ₱${goal.targetAmount}');
      }

      if (goal.currentAmount < 0) {
        debugPrint('❌ Invalid goal: Current amount cannot be negative');
        return false;
      }

      if (goal.currentAmount > goal.targetAmount && !goal.isCompleted) {
        debugPrint(
            '⚠️ Warning: Current amount exceeds target but goal not marked completed');
      }

      // Check dates
      if (goal.targetDate.isBefore(goal.createdDate)) {
        debugPrint('❌ Invalid goal: Target date cannot be before created date');
        return false;
      }

      if (goal.createdDate
          .isAfter(DateTime.now().add(const Duration(days: 1)))) {
        debugPrint('❌ Invalid goal: Created date cannot be in the future');
        return false;
      }

      // Check completion logic
      if (goal.isCompleted && goal.currentAmount < goal.targetAmount) {
        debugPrint('⚠️ Warning: Goal marked completed but target not reached');
      }

      if (goal.isCompleted && goal.completedDate == null) {
        debugPrint(
            '⚠️ Warning: Goal marked completed but no completion date set');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Goal validation error: $e');
      return false;
    }
  }

  static bool validateUserData(UserData userData) {
    try {
      // Check required fields
      if (userData.id.isEmpty) {
        debugPrint('❌ Invalid user data: Empty ID');
        return false;
      }

      if (userData.name.isEmpty) {
        debugPrint('❌ Invalid user data: Empty name');
        return false;
      }

      if (userData.email.isEmpty || !_isValidEmail(userData.email)) {
        debugPrint('❌ Invalid user data: Invalid email format');
        return false;
      }

      // Check financial data
      if (userData.monthlyIncome < 0) {
        debugPrint('❌ Invalid user data: Monthly income cannot be negative');
        return false;
      }

      if (userData.monthlyBudget < 0) {
        debugPrint('❌ Invalid user data: Monthly budget cannot be negative');
        return false;
      }

      if (userData.monthlyBudget > userData.monthlyIncome &&
          userData.monthlyIncome > 0) {
        debugPrint('⚠️ Warning: Monthly budget exceeds monthly income');
      }

      // Check streaks
      if (userData.currentStreak < 0) {
        debugPrint('❌ Invalid user data: Current streak cannot be negative');
        return false;
      }

      if (userData.longestStreak < 0) {
        debugPrint('❌ Invalid user data: Longest streak cannot be negative');
        return false;
      }

      if (userData.currentStreak > userData.longestStreak) {
        debugPrint('⚠️ Warning: Current streak exceeds longest streak');
      }

      // Check points
      if (userData.totalPoints < 0) {
        debugPrint('❌ Invalid user data: Total points cannot be negative');
        return false;
      }

      // Check language
      if (!['en', 'tl'].contains(userData.preferredLanguage)) {
        debugPrint(
            '⚠️ Warning: Unsupported language: ${userData.preferredLanguage}');
      }

      return true;
    } catch (e) {
      debugPrint('❌ User data validation error: $e');
      return false;
    }
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  /// Validates all data in the database
  static Future<ValidationResult> validateAllData() async {
    debugPrint('🔍 Starting comprehensive data validation...');

    final result = ValidationResult();

    try {
      // Validate all expenses
      final expenses = DatabaseService.getAllExpenses();
      result.totalExpenses = expenses.length;

      for (final expense in expenses) {
        if (!validateExpense(expense)) {
          result.invalidExpenses.add(expense.id);
        } else {
          result.validExpenses++;
        }
      }

      // Validate all goals
      final goals = DatabaseService.getAllGoals();
      result.totalGoals = goals.length;

      for (final goal in goals) {
        if (!validateSavingsGoal(goal)) {
          result.invalidGoals.add(goal.id);
        } else {
          result.validGoals++;
        }
      }

      // Validate user data
      final userData = DatabaseService.getCurrentUser();
      if (userData != null) {
        result.hasUserData = true;
        result.isUserDataValid = validateUserData(userData);
      }

      debugPrint('✅ Data validation completed');
      debugPrint('📊 Validation Results:');
      debugPrint(
          '  - Expenses: ${result.validExpenses}/${result.totalExpenses} valid');
      debugPrint('  - Goals: ${result.validGoals}/${result.totalGoals} valid');
      debugPrint(
          '  - User Data: ${result.isUserDataValid ? "Valid" : "Invalid"}');

      if (result.invalidExpenses.isNotEmpty) {
        debugPrint('⚠️ Invalid expenses: ${result.invalidExpenses.join(", ")}');
      }

      if (result.invalidGoals.isNotEmpty) {
        debugPrint('⚠️ Invalid goals: ${result.invalidGoals.join(", ")}');
      }
    } catch (e) {
      debugPrint('❌ Data validation failed: $e');
      result.error = e.toString();
    }

    return result;
  }
}

class ValidationResult {
  int totalExpenses = 0;
  int validExpenses = 0;
  List<String> invalidExpenses = [];

  int totalGoals = 0;
  int validGoals = 0;
  List<String> invalidGoals = [];

  bool hasUserData = false;
  bool isUserDataValid = false;

  String? error;

  bool get isValid =>
      invalidExpenses.isEmpty &&
      invalidGoals.isEmpty &&
      (hasUserData ? isUserDataValid : true) &&
      error == null;

  double get expenseValidityRate =>
      totalExpenses > 0 ? validExpenses / totalExpenses : 1.0;

  double get goalValidityRate => totalGoals > 0 ? validGoals / totalGoals : 1.0;
}
