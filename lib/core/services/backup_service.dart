import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';
import '../../shared/models/expense.dart';
import '../../shared/models/savings_goal.dart';
import '../../shared/models/user_data.dart';

class BackupService {
  static const String backupFileExtension = '.pesotracker';
  
  static Future<Map<String, dynamic>> createBackupData() async {
    final expenses = DatabaseService.getAllExpenses();
    final goals = DatabaseService.getAllGoals();
    final userData = DatabaseService.getCurrentUser();
    
    return {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'goals': goals.map((g) => g.toMap()).toList(),
      'userData': userData?.toMap(),
      'settings': {
        'language': DatabaseService.getSetting('language'),
      },
    };
  }

  static Future<String?> exportToFile() async {
    try {
      final backupData = await createBackupData();
      final jsonString = jsonEncode(backupData);
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'pesotracker_backup_$timestamp$backupFileExtension';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      debugPrint('Error exporting backup: $e');
      return null;
    }
  }

  static Future<bool> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pesotracker', 'json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
        
        return await _restoreFromBackupData(backupData);
      }
      
      return false;
    } catch (e) {
      debugPrint('Error importing backup: $e');
      return false;
    }
  }

  static Future<bool> _restoreFromBackupData(Map<String, dynamic> backupData) async {
    try {
      if (!_isValidBackupData(backupData)) {
        debugPrint('Invalid backup data format');
        return false;
      }

      if (backupData['expenses'] != null) {
        final expensesData = backupData['expenses'] as List;
        for (final expenseMap in expensesData) {
          try {
            final expense = Expense.fromMap(expenseMap);
            await DatabaseService.addExpense(expense);
          } catch (e) {
            debugPrint('Error restoring expense: $e');
          }
        }
      }

      if (backupData['goals'] != null) {
        final goalsData = backupData['goals'] as List;
        for (final goalMap in goalsData) {
          try {
            final goal = SavingsGoal.fromMap(goalMap);
            await DatabaseService.addGoal(goal);
          } catch (e) {
            debugPrint('Error restoring goal: $e');
          }
        }
      }

      if (backupData['userData'] != null) {
        try {
          final userData = UserData.fromMap(backupData['userData']);
          await DatabaseService.saveUserData(userData);
        } catch (e) {
          debugPrint('Error restoring user data: $e');
        }
      }

      if (backupData['settings'] != null) {
        final settings = backupData['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          if (entry.value != null) {
            await DatabaseService.saveSetting(entry.key, entry.value);
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return false;
    }
  }

  static bool _isValidBackupData(Map<String, dynamic> data) {
    return data.containsKey('version') &&
           data.containsKey('timestamp') &&
           (data.containsKey('expenses') || 
            data.containsKey('goals') || 
            data.containsKey('userData'));
  }

  static Future<String> getBackupInfo() async {
    final expenses = DatabaseService.getAllExpenses();
    final goals = DatabaseService.getAllGoals();
    final userData = DatabaseService.getCurrentUser();
    
    return '''
Backup Information:
• ${expenses.length} expenses
• ${goals.length} savings goals
• User profile: ${userData?.name ?? 'Not set'}
• Created: ${DateTime.now().toString()}
    ''';
  }
}