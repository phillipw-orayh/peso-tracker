import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'PesoTracker';
  
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFFFFC107);
  static const Color accentColor = Color(0xFFFF6B35);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  static const List<String> expenseCategories = [
    'Pagkain',
    'Transportasyon', 
    'Bills',
    'Shopping',
    'Entertainment',
    'Others'
  ];
  
  static const List<String> foodSubcategories = [
    'Breakfast',
    'Lunch', 
    'Dinner',
    'Merienda'
  ];
  
  static const List<String> transportationSubcategories = [
    'Jeepney',
    'Bus',
    'MRT/LRT',
    'Tricycle',
    'Grab/Taxi'
  ];
  
  static const List<String> billsSubcategories = [
    'Kuryente',
    'Tubig',
    'Internet',
    'Load',
    'Cable'
  ];
  
  static const String defaultCurrency = '₱';
  
  static const Map<String, String> filipinoTerms = {
    'expenses': 'Gastos',
    'savings': 'Savings',
    'budget': 'Budget',
    'goal': 'Goal',
    'streak': 'Streak',
  };
}