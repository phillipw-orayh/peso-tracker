import 'package:flutter/foundation.dart';
import '../../shared/models/expense.dart';
import '../../shared/models/savings_goal.dart';
import '../../shared/models/user_data.dart';
import 'database_service.dart';

class DatabaseTest {
  static Future<void> runTests() async {
    debugPrint('🧪 Starting Database Tests...');
    
    try {
      // First, perform a health check
      final healthCheck = await DatabaseService.performHealthCheck();
      if (!healthCheck.isHealthy) {
        debugPrint('⚠️ Database health check failed: ${healthCheck.status}');
        if (healthCheck.error != null) {
          debugPrint('   Error: ${healthCheck.error}');
        }
      }
      
      await _testExpenseOperations();
      await _testGoalOperations();
      await _testUserDataOperations();
      await _testSettingsOperations();
      
      // Final health check
      final finalHealthCheck = await DatabaseService.performHealthCheck();
      debugPrint('📊 Final Database Status: ${finalHealthCheck.status}');
      
      debugPrint('✅ All database tests passed!');
    } catch (e) {
      debugPrint('❌ Database test failed: $e');
      rethrow;
    }
  }
  
  static Future<void> _testExpenseOperations() async {
    debugPrint('Testing Expense operations...');
    
    // Test adding expense
    final testExpense = Expense(
      id: 'test_expense_${DateTime.now().millisecondsSinceEpoch}',
      amount: 150.50,
      category: 'Pagkain',
      description: 'Test lunch expense',
      dateTime: DateTime.now(),
    );
    
    await DatabaseService.addExpense(testExpense);
    debugPrint('✓ Expense added to database');
    
    // Test retrieving expenses
    final expenses = DatabaseService.getAllExpenses();
    final foundExpense = expenses.firstWhere(
      (e) => e.id == testExpense.id,
      orElse: () => throw Exception('Test expense not found in database'),
    );
    
    debugPrint('✓ Expense retrieved from database');
    debugPrint('  - Amount: ₱${foundExpense.amount}');
    debugPrint('  - Category: ${foundExpense.category}');
    debugPrint('  - Description: ${foundExpense.description}');
    
    // Test updating expense
    final updatedExpense = Expense(
      id: testExpense.id,
      amount: 200.75,
      category: 'Transportasyon',
      description: 'Updated test expense',
      dateTime: testExpense.dateTime,
    );
    
    await DatabaseService.updateExpense(updatedExpense);
    
    final expensesAfterUpdate = DatabaseService.getAllExpenses();
    final updatedFoundExpense = expensesAfterUpdate.firstWhere(
      (e) => e.id == testExpense.id,
      orElse: () => throw Exception('Updated expense not found'),
    );
    
    if (updatedFoundExpense.amount != 200.75) {
      throw Exception('Expense update failed');
    }
    
    debugPrint('✓ Expense updated successfully');
    
    // Test deleting expense
    await DatabaseService.deleteExpense(testExpense.id);
    
    final expensesAfterDelete = DatabaseService.getAllExpenses();
    final deletedExpense = expensesAfterDelete.where((e) => e.id == testExpense.id);
    
    if (deletedExpense.isNotEmpty) {
      throw Exception('Expense deletion failed');
    }
    
    debugPrint('✓ Expense deleted successfully');
  }
  
  static Future<void> _testGoalOperations() async {
    debugPrint('Testing Goal operations...');
    
    // Test adding goal
    final testGoal = SavingsGoal(
      id: 'test_goal_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Goal',
      description: 'This is a test savings goal',
      targetAmount: 50000.0,
      currentAmount: 10000.0,
      createdDate: DateTime.now(),
      targetDate: DateTime.now().add(const Duration(days: 180)),
      type: GoalType.mediumTerm,
    );
    
    await DatabaseService.addGoal(testGoal);
    debugPrint('✓ Goal added to database');
    
    // Test retrieving goals
    final goals = DatabaseService.getAllGoals();
    final foundGoal = goals.firstWhere(
      (g) => g.id == testGoal.id,
      orElse: () => throw Exception('Test goal not found in database'),
    );
    
    debugPrint('✓ Goal retrieved from database');
    debugPrint('  - Title: ${foundGoal.title}');
    debugPrint('  - Target: ₱${foundGoal.targetAmount}');
    debugPrint('  - Saved: ₱${foundGoal.currentAmount}');
    debugPrint('  - Progress: ${foundGoal.progressPercentage.toStringAsFixed(1)}%');
    
    // Test updating goal
    final updatedGoal = testGoal.copyWith(
      savedAmount: 25000.0,
      title: 'Updated Test Goal',
    );
    
    await DatabaseService.updateGoal(updatedGoal);
    
    final goalsAfterUpdate = DatabaseService.getAllGoals();
    final updatedFoundGoal = goalsAfterUpdate.firstWhere(
      (g) => g.id == testGoal.id,
      orElse: () => throw Exception('Updated goal not found'),
    );
    
    if (updatedFoundGoal.savedAmount != 25000.0) {
      throw Exception('Goal update failed');
    }
    
    debugPrint('✓ Goal updated successfully');
    debugPrint('  - New progress: ${updatedFoundGoal.progressPercentage.toStringAsFixed(1)}%');
    
    // Test deleting goal
    await DatabaseService.deleteGoal(testGoal.id);
    
    final goalsAfterDelete = DatabaseService.getAllGoals();
    final deletedGoal = goalsAfterDelete.where((g) => g.id == testGoal.id);
    
    if (deletedGoal.isNotEmpty) {
      throw Exception('Goal deletion failed');
    }
    
    debugPrint('✓ Goal deleted successfully');
  }
  
  static Future<void> _testUserDataOperations() async {
    debugPrint('Testing UserData operations...');
    
    // Test saving user data
    final testUserData = UserData(
      id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Juan Cruz',
      email: 'juan.cruz@email.com',
      monthlyIncome: 45000.0,
      monthlyBudget: 30000.0,
      preferredLanguage: 'tl',
      currentStreak: 5,
      longestStreak: 12,
      lastActiveDate: DateTime.now(),
      completedChallenges: ['save_1000', 'budget_week'],
      earnedBadges: ['first_expense', 'goal_setter'],
      totalPoints: 350,
      settings: {'darkMode': false, 'notifications': true},
    );
    
    await DatabaseService.saveUserData(testUserData);
    debugPrint('✓ UserData saved to database');
    
    // Test retrieving user data
    final retrievedUser = DatabaseService.getCurrentUser();
    
    if (retrievedUser == null) {
      throw Exception('User data not found in database');
    }
    
    debugPrint('✓ UserData retrieved from database');
    debugPrint('  - Name: ${retrievedUser.name}');
    debugPrint('  - Email: ${retrievedUser.email}');
    debugPrint('  - Monthly Income: ₱${retrievedUser.monthlyIncome}');
    debugPrint('  - Current Streak: ${retrievedUser.currentStreak} days');
    debugPrint('  - Total Points: ${retrievedUser.totalPoints}');
    debugPrint('  - Completed Challenges: ${retrievedUser.completedChallenges.length}');
    debugPrint('  - Earned Badges: ${retrievedUser.earnedBadges.length}');
  }
  
  static Future<void> _testSettingsOperations() async {
    debugPrint('Testing Settings operations...');
    
    // Test saving settings
    await DatabaseService.saveSetting('test_language', 'en');
    await DatabaseService.saveSetting('test_dark_mode', true);
    await DatabaseService.saveSetting('test_notifications', false);
    
    debugPrint('✓ Settings saved to database');
    
    // Test retrieving settings
    final language = DatabaseService.getSetting<String>('test_language');
    final darkMode = DatabaseService.getSetting<bool>('test_dark_mode');
    final notifications = DatabaseService.getSetting<bool>('test_notifications');
    
    if (language != 'en' || darkMode != true || notifications != false) {
      throw Exception('Settings retrieval failed');
    }
    
    debugPrint('✓ Settings retrieved successfully');
    debugPrint('  - Language: $language');
    debugPrint('  - Dark Mode: $darkMode');
    debugPrint('  - Notifications: $notifications');
  }
  
  static Future<void> _testBackupRestore() async {
    debugPrint('Testing Backup/Restore operations...');
    
    // Add some test data
    final testExpense = Expense(
      id: 'backup_test_expense',
      amount: 299.99,
      category: 'Shopping',
      description: 'Backup test purchase',
      dateTime: DateTime.now(),
    );
    
    final testGoal = SavingsGoal(
      id: 'backup_test_goal',
      title: 'Backup Test Goal',
      description: 'Testing backup functionality',
      targetAmount: 10000.0,
      currentAmount: 2500.0,
      createdDate: DateTime.now(),
      targetDate: DateTime.now().add(const Duration(days: 90)),
      type: GoalType.shortTerm,
    );
    
    await DatabaseService.addExpense(testExpense);
    await DatabaseService.addGoal(testGoal);
    
    // Test export
    final backupData = await DatabaseService.exportData();
    if (backupData == null) {
      throw Exception('Data export failed');
    }
    
    debugPrint('✓ Data exported successfully');
    debugPrint('  - Backup size: ${backupData.length} characters');
    
    // Clear data
    await DatabaseService.clearAllData();
    
    // Verify data is cleared
    if (DatabaseService.getAllExpenses().isNotEmpty || 
        DatabaseService.getAllGoals().isNotEmpty) {
      throw Exception('Data clearing failed');
    }
    
    debugPrint('✓ Data cleared successfully');
    
    // Note: Import test would require parsing the backup string back to Map
    // This is a simplified test focusing on the core database operations
  }
}