// lib/shared/widgets/settings_launcher.dart
import 'package:flutter/material.dart';

// Adjust the path below if your dialog lives elsewhere
import '../screens/settings_screen.dart';

/// Centralized way to open the Settings popup from anywhere.
/// - Prevents multiple stacked dialogs
/// - Works with either a BuildContext or a navigatorKey (to avoid passing context around)
class SettingsLauncher {
  SettingsLauncher._(); // no instances

  static bool _isOpen = false;

  /// Show the Settings dialog.
  ///
  /// Usage:
  ///   SettingsLauncher.show(context: context);
  /// or:
  ///   SettingsLauncher.show(navigatorKey: NavigationService.navigatorKey);
  static Future<void> show({
    BuildContext? context,
    GlobalKey<NavigatorState>? navigatorKey,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) async {
    // Resolve context: prefer the explicit BuildContext; fallback to navigatorKey
    final ctx = context ?? navigatorKey?.currentContext;
    if (ctx == null) {
      debugPrint(
          'SettingsLauncher.show: No context or navigatorKey available.');
      return;
    }

    // Prevent stacking multiple Settings dialogs
    if (_isOpen) return;

    _isOpen = true;
    try {
      await showDialog(
        context: ctx,
        barrierDismissible: barrierDismissible,
        useRootNavigator: useRootNavigator,
        builder: (_) => const SettingsScreen(),
      );
    } finally {
      _isOpen = false;
    }
  }

  /// Ready-made AppBar action button.
  ///
  /// Usage in any AppBar:
  ///   actions: [
  ///     SettingsLauncher.appBarAction(context: context),
  ///   ],
  static Widget appBarAction({
    BuildContext? context,
    GlobalKey<NavigatorState>? navigatorKey,
    String tooltip = 'Settings',
    IconData icon = Icons.settings,
  }) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () => SettingsLauncher.show(
        context: context,
        navigatorKey: navigatorKey,
      ),
    );
  }
}
