import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/navigation_service.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) => _onItemTapped(index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: locale.getLocalizedText('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: locale.getLocalizedText('expenses'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.flag_outlined),
              activeIcon: const Icon(Icons.flag),
              label: locale.getLocalizedText('goals'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events_outlined),
              activeIcon: const Icon(Icons.emoji_events),
              label: locale.isFilipino ? 'Hamon' : 'Challenges',
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        NavigationService.goToHome();
        break;
      case 1:
        NavigationService.goToExpenses();
        break;
      case 2:
        NavigationService.goToGoals();
        break;
      case 3:
        NavigationService.goToChallenges();
        break;
    }
  }
}