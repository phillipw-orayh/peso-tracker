import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('tl', 'PH');
  
  Locale get currentLocale => _currentLocale;
  
  String get currentLanguageCode => _currentLocale.languageCode;
  
  bool get isFilipino => _currentLocale.languageCode == 'tl';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  LocaleProvider() {
    // Defer initialization to avoid calling notifyListeners during provider creation
    Future.microtask(() => _loadSavedLocale());
  }

  void _loadSavedLocale() {
    final savedLanguage = DatabaseService.getSetting<String>('language', defaultValue: 'tl');
    if (savedLanguage != null) {
      setLocale(savedLanguage);
    }
  }

  Future<void> setLocale(String languageCode) async {
    Locale newLocale;
    
    switch (languageCode) {
      case 'en':
        newLocale = const Locale('en', 'US');
        break;
      case 'tl':
      default:
        newLocale = const Locale('tl', 'PH');
        break;
    }
    
    if (newLocale != _currentLocale) {
      _currentLocale = newLocale;
      await DatabaseService.saveSetting('language', languageCode);
      notifyListeners();
    }
  }

  Future<void> toggleLanguage() async {
    final newLanguageCode = isFilipino ? 'en' : 'tl';
    await setLocale(newLanguageCode);
  }

  String getLocalizedText(String key) {
    final Map<String, Map<String, String>> translations = {
      'home': {
        'en': 'Home',
        'tl': 'Home',
      },
      'expenses': {
        'en': 'Expenses',
        'tl': 'Mga Gastos',
      },
      'goals': {
        'en': 'Goals',
        'tl': 'Goals',
      },
      'my_goals': {
        'en': 'My Goals',
        'tl': 'My Goals',
      },
      'profile': {
        'en': 'Profile',
        'tl': 'Profile',
      },
      'add_expense': {
        'en': 'Add Expense',
        'tl': 'Add Gastos',
      },
      'amount': {
        'en': 'Amount',
        'tl': 'Amount',
      },
      'category': {
        'en': 'Category',
        'tl': 'Category',
      },
      'description': {
        'en': 'Description',
        'tl': 'Description',
      },
      'save': {
        'en': 'Save',
        'tl': 'Save',
      },
      'cancel': {
        'en': 'Cancel',
        'tl': 'Cancel',
      },
      'total_expenses': {
        'en': 'Total Expenses',
        'tl': 'Total Gastos',
      },
      'this_month': {
        'en': 'This Month',
        'tl': 'This Month',
      },
      'today': {
        'en': 'Today',
        'tl': 'Today',
      },
      'savings_goals': {
        'en': 'Savings Goals',
        'tl': 'Savings Goals',
      },
      'current_streak': {
        'en': 'Current Streak',
        'tl': 'Current Streak',
      },
      'days': {
        'en': 'days',
        'tl': 'days',
      },
      'congratulations': {
        'en': 'Congratulations!',
        'tl': 'Congrats!',
      },
      'keep_it_up': {
        'en': 'Keep it up!',
        'tl': 'Keep it up!',
      },
      'good_job': {
        'en': 'Good job!',
        'tl': 'Good job!',
      },
      'pagkain': {
        'en': 'Food',
        'tl': 'Food',
      },
      'transportasyon': {
        'en': 'Transportation',
        'tl': 'Transportation',
      },
      'bills': {
        'en': 'Bills',
        'tl': 'Bills',
      },
      'shopping': {
        'en': 'Shopping',
        'tl': 'Shopping',
      },
      'entertainment': {
        'en': 'Entertainment',
        'tl': 'Entertainment',
      },
      'others': {
        'en': 'Others',
        'tl': 'Others',
      },
      'quick_actions': {
        'en': 'Quick Actions',
        'tl': 'Quick Actions',
      },
      'new_goal': {
        'en': 'New Goal',
        'tl': 'New Goal',
      },
      'recent_expenses': {
        'en': 'Recent Expenses',
        'tl': 'Recent Gastos',
      },
      'see_all': {
        'en': 'See All',
        'tl': 'See All',
      },
      'no_expenses_yet': {
        'en': 'No expenses recorded yet',
        'tl': 'Walang gastos pa',
      },
      'expense_summary': {
        'en': 'Expense Summary',
        'tl': 'Gastos Summary',
      },
      'no_expenses_this_month': {
        'en': 'No expenses this month',
        'tl': 'Walang gastos this month',
      },
      'top_categories': {
        'en': 'Top Categories',
        'tl': 'Top Categories',
      },
      'no_goals_yet': {
        'en': 'No savings goals yet',
        'tl': 'Walang savings goals pa',
      },
      'create_first_goal': {
        'en': 'Create First Goal',
        'tl': 'Create First Goal',
      },
      'total_progress': {
        'en': 'Total Progress',
        'tl': 'Total Progress',
      },
      'best': {
        'en': 'Best',
        'tl': 'Best',
      },
    };

    final languageCode = _currentLocale.languageCode;
    return translations[key]?[languageCode] ?? key;
  }

  String getCurrencySymbol() {
    return '₱';
  }

  String formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  String getEncouragingMessage() {
    final messages = isFilipino ? [
      'Ang galing mo! Keep it up!',
      'Good job! Tuloy lang!',
      'Proud ako sa\'yo!',
      'Kaya mo yan!',
      'Great work! Sipag mo!',
      'Nice! Ang husay mo!',
      'Perfect! Galing mo talaga!'
    ] : [
      'You\'re doing great!',
      'Keep up the good work!',
      'Excellent progress!',
      'You can do it!',
      'Amazing effort!',
    ];
    
    messages.shuffle();
    return messages.first;
  }

  String getGentleReminder() {
    return isFilipino 
        ? 'Psst, hindi ka pa nag-log ng gastos today'
        : 'Hey, you haven\'t logged any expenses today';
  }
}