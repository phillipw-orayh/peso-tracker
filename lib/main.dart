import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/services/database_service.dart';
import 'core/services/database_test.dart';
import 'core/services/navigation_service.dart';
import 'shared/providers/expense_provider.dart';
import 'shared/providers/goal_provider.dart';
import 'shared/providers/gamification_provider.dart';
import 'shared/providers/challenge_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/models/expense.dart';
import 'shared/models/savings_goal.dart';
import 'shared/models/user_data.dart';
import 'shared/models/challenge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(GoalTypeAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());
  Hive.registerAdapter(UserDataAdapter());
  Hive.registerAdapter(ChallengeTypeAdapter());
  Hive.registerAdapter(ChallengeCategoryAdapter());
  Hive.registerAdapter(ChallengeAdapter());
  Hive.registerAdapter(UserChallengeAdapter());
  Hive.registerAdapter(BadgeAdapter());
  
  await DatabaseService.init();
  
  // Run database tests in debug mode
  if (kDebugMode) {
    try {
      await DatabaseTest.runTests();
      debugPrint('🎉 Database is working correctly!');
    } catch (e) {
      debugPrint('⚠️ Database test failed: $e');
      // Continue running the app even if tests fail
    }
  }
  
  runApp(const PesoTrackerApp());
}

class PesoTrackerApp extends StatelessWidget {
  const PesoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp.router(
            title: 'PesoTracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstants.primaryColor,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            locale: localeProvider.currentLocale,
            routerConfig: NavigationService.router,
          );
        },
      ),
    );
  }
}