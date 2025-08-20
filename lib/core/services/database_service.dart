import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../shared/models/expense.dart';
import '../../shared/models/savings_goal.dart';
import '../../shared/models/user_data.dart';

class DatabaseService {
  static const String expenseBoxName = 'expenses';
  static const String goalBoxName = 'goals';
  static const String userBoxName = 'user_data';
  static const String settingsBoxName = 'settings';

  static late Box<Expense> _expenseBox;
  static late Box<SavingsGoal> _goalBox;
  static late Box<UserData> _userBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    _expenseBox = await Hive.openBox<Expense>(expenseBoxName);
    _goalBox = await Hive.openBox<SavingsGoal>(goalBoxName);
    _userBox = await Hive.openBox<UserData>(userBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  static Box<Expense> get expenseBox => _expenseBox;
  static Box<SavingsGoal> get goalBox => _goalBox;
  static Box<UserData> get userBox => _userBox;
  static Box get settingsBox => _settingsBox;

  static Future<void> addExpense(Expense expense) async {
    try {
      await _expenseBox.put(expense.id, expense);
      
      // Verify the expense was saved correctly
      final savedExpense = _expenseBox.get(expense.id);
      if (savedExpense == null) {
        throw Exception('Failed to save expense - not found after save operation');
      }
      
      if (savedExpense.amount != expense.amount || 
          savedExpense.category != expense.category) {
        throw Exception('Failed to save expense - data corruption detected');
      }
      
      debugPrint('✅ Expense saved successfully: ${expense.id}');
    } catch (e) {
      debugPrint('❌ Error saving expense: $e');
      rethrow;
    }
  }

  static Future<void> updateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  static Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }

  static List<Expense> getAllExpenses() {
    return _expenseBox.values.toList();
  }

  static List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenseBox.values
        .where((expense) =>
            expense.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.dateTime.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  static List<Expense> getExpensesByCategory(String category) {
    return _expenseBox.values
        .where((expense) => expense.category == category)
        .toList();
  }

  static Future<void> addGoal(SavingsGoal goal) async {
    try {
      await _goalBox.put(goal.id, goal);
      
      // Verify the goal was saved correctly
      final savedGoal = _goalBox.get(goal.id);
      if (savedGoal == null) {
        throw Exception('Failed to save goal - not found after save operation');
      }
      
      if (savedGoal.targetAmount != goal.targetAmount || 
          savedGoal.title != goal.title) {
        throw Exception('Failed to save goal - data corruption detected');
      }
      
      debugPrint('✅ Goal saved successfully: ${goal.id}');
    } catch (e) {
      debugPrint('❌ Error saving goal: $e');
      rethrow;
    }
  }

  static Future<void> updateGoal(SavingsGoal goal) async {
    await _goalBox.put(goal.id, goal);
  }

  static Future<void> deleteGoal(String id) async {
    await _goalBox.delete(id);
  }

  static List<SavingsGoal> getAllGoals() {
    return _goalBox.values.toList();
  }

  static List<SavingsGoal> getActiveGoals() {
    return _goalBox.values.where((goal) => !goal.isCompleted).toList();
  }

  static List<SavingsGoal> getCompletedGoals() {
    return _goalBox.values.where((goal) => goal.isCompleted).toList();
  }

  static Future<void> saveUserData(UserData userData) async {
    await _userBox.put(userData.id, userData);
    await setCurrentUser(userData.id);
  }

  static UserData? getCurrentUser() {
    final currentUserId = getCurrentUserId();
    if (currentUserId != null && currentUserId.isNotEmpty) {
      return getUserById(currentUserId);
    }
    return null;
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> clearAllData() async {
    await _expenseBox.clear();
    await _goalBox.clear();
    await _userBox.clear();
    await _settingsBox.clear();
  }

  static Future<String?> exportData() async {
    try {
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'expenses': getAllExpenses().map((e) => e.toMap()).toList(),
        'goals': getAllGoals().map((g) => g.toMap()).toList(),
        'userData': getCurrentUser()?.toMap(),
        'settings': {
          'language': getSetting('language'),
        },
      };
      
      return backupData.toString();
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return null;
    }
  }

  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      if (data['expenses'] != null) {
        final expensesData = data['expenses'] as List;
        for (final expenseMap in expensesData) {
          final expense = Expense.fromMap(expenseMap);
          await addExpense(expense);
        }
      }

      if (data['goals'] != null) {
        final goalsData = data['goals'] as List;
        for (final goalMap in goalsData) {
          final goal = SavingsGoal.fromMap(goalMap);
          await addGoal(goal);
        }
      }

      if (data['userData'] != null) {
        final userData = UserData.fromMap(data['userData']);
        await saveUserData(userData);
      }

      if (data['settings'] != null) {
        final settings = data['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          if (entry.value != null) {
            await saveSetting(entry.key, entry.value);
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  // User Management Methods
  static Future<void> createUser(UserData user) async {
    try {
      await _userBox.put(user.id, user);
      debugPrint('✅ User created successfully: ${user.name}');
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      rethrow;
    }
  }

  static Future<void> updateUser(UserData user) async {
    try {
      await _userBox.put(user.id, user);
      debugPrint('✅ User updated successfully: ${user.name}');
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      rethrow;
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await _userBox.delete(userId);
      debugPrint('✅ User deleted successfully: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      rethrow;
    }
  }

  static List<UserData> getAllUsers() {
    try {
      return _userBox.values.toList();
    } catch (e) {
      debugPrint('❌ Error getting all users: $e');
      return [];
    }
  }

  static UserData? getUserById(String userId) {
    try {
      return _userBox.get(userId);
    } catch (e) {
      debugPrint('❌ Error getting user by ID: $e');
      return null;
    }
  }

  static Future<void> setCurrentUser(String userId) async {
    try {
      await _settingsBox.put('current_user_id', userId);
      debugPrint('✅ Current user set to: $userId');
    } catch (e) {
      debugPrint('❌ Error setting current user: $e');
      rethrow;
    }
  }

  static String? getCurrentUserId() {
    try {
      return _settingsBox.get('current_user_id') as String?;
    } catch (e) {
      debugPrint('❌ Error getting current user ID: $e');
      return null;
    }
  }

  /// Performs a comprehensive health check on the database
  static Future<DatabaseHealthCheck> performHealthCheck() async {
    final healthCheck = DatabaseHealthCheck();
    
    try {
      debugPrint('🏥 Performing database health check...');
      
      // Check if boxes are open and accessible
      healthCheck.areBoxesOpen = _expenseBox.isOpen && 
                                  _goalBox.isOpen && 
                                  _userBox.isOpen && 
                                  _settingsBox.isOpen;
      
      // Count total records
      healthCheck.totalExpenses = _expenseBox.length;
      healthCheck.totalGoals = _goalBox.length;
      healthCheck.hasUserData = _userBox.isNotEmpty;
      healthCheck.totalSettings = _settingsBox.length;
      
      // Test basic operations
      final testExpenseId = 'health_check_expense_${DateTime.now().millisecondsSinceEpoch}';
      final testExpense = Expense(
        id: testExpenseId,
        amount: 1.0,
        category: 'Test',
        description: 'Health check test expense',
        dateTime: DateTime.now(),
      );
      
      // Test write operation
      await addExpense(testExpense);
      
      // Test read operation
      final retrievedExpense = _expenseBox.get(testExpenseId);
      healthCheck.canReadWrite = retrievedExpense != null;
      
      // Clean up test data
      await deleteExpense(testExpenseId);
      
      // Check for data corruption
      int corruptedExpenses = 0;
      for (final expense in _expenseBox.values) {
        try {
          // Try to access all fields to test for corruption
          expense.amount + 0;
          expense.dateTime.millisecondsSinceEpoch;
        } catch (e) {
          corruptedExpenses++;
        }
      }
      healthCheck.corruptedRecords = corruptedExpenses;
      
      // Calculate storage usage (approximate)
      healthCheck.estimatedStorageKB = 
          (_expenseBox.length * 0.5) + // ~0.5KB per expense
          (_goalBox.length * 0.3) +    // ~0.3KB per goal
          (_settingsBox.length * 0.1); // ~0.1KB per setting
      
      debugPrint('✅ Database health check completed');
      debugPrint('📊 Health Check Results:');
      debugPrint('  - Boxes Open: ${healthCheck.areBoxesOpen}');
      debugPrint('  - Can Read/Write: ${healthCheck.canReadWrite}');
      debugPrint('  - Total Records: ${healthCheck.totalExpenses + healthCheck.totalGoals}');
      debugPrint('  - Corrupted Records: ${healthCheck.corruptedRecords}');
      debugPrint('  - Estimated Storage: ${healthCheck.estimatedStorageKB.toStringAsFixed(1)}KB');
      
    } catch (e) {
      debugPrint('❌ Database health check failed: $e');
      healthCheck.error = e.toString();
    }
    
    return healthCheck;
  }
}

class DatabaseHealthCheck {
  bool areBoxesOpen = false;
  bool canReadWrite = false;
  int totalExpenses = 0;
  int totalGoals = 0;
  bool hasUserData = false;
  int totalSettings = 0;
  int corruptedRecords = 0;
  double estimatedStorageKB = 0.0;
  String? error;
  
  bool get isHealthy => 
      areBoxesOpen && 
      canReadWrite && 
      corruptedRecords == 0 && 
      error == null;
      
  String get status {
    if (error != null) return 'Error';
    if (!isHealthy) return 'Unhealthy';
    return 'Healthy';
  }
}