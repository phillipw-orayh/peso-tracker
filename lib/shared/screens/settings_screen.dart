import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peso_tracker/core/services/navigation_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/gamification_provider.dart';
import '../../features/challenge/screens/challenge_screen.dart';
import 'user_management_screen.dart';

/// Full‑screen Settings page (replaces the narrow dialog UI).
/// Hook up each onTap to your real flows/routes as you wire them in.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Settings',
              onPressed: () {
                NavigationService.goToHome();
              }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // ====== CURRENT USER ======
          _buildCurrentUserCard(),

          const SizedBox(height: AppConstants.largePadding),

          // ====== ACCOUNT ======
          SectionHeader(title: 'Account', icon: Icons.manage_accounts),
          Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Profile'),
                    subtitle: const Text('Name, avatar, preferences'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChallengeScreen()),
                      );
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.group_outlined),
                    title: const Text('User Management'),
                    subtitle: const Text('Manage local users / accounts'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UserManagementScreen()),
                      );
                    },
                  ),
                ],
              )),

          const SizedBox(height: AppConstants.largePadding),

          // ====== APP SETTINGS ======
          SectionHeader(title: 'App', icon: Icons.app_settings_alt),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.translate_outlined),
                  title: const Text('Language'),
                  subtitle: const Text('Filipino / English'),
                  onTap: () {
                    _showLanguagePicker(context);
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  subtitle: const Text('System default'),
                  onTap: () {
                    _showThemePicker(context);
                  },
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.notifications_none),
                  title: const Text('Notifications'),
                  value: true, // TODO: bind to real setting
                  onChanged: (v) {
                    // TODO: persist
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Notifications ${v ? 'enabled' : 'disabled'}')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.largePadding),

          // ====== DATA ======
          SectionHeader(title: 'Data', icon: Icons.storage_outlined),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined),
                  title: const Text('Export data'),
                  onTap: () {
                    // TODO: implement export (e.g., to JSON)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export started…')),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Import data'),
                  onTap: () {
                    // TODO: implement import
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import flow…')),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Clear all local data'),
                  titleTextStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () => _confirmClearData(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.largePadding),

          // ====== ABOUT ======
          SectionHeader(title: 'About', icon: Icons.info_outline),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About PesoTracker'),
                  subtitle: const Text('Version 1.0.0'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'PesoTracker',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.savings_outlined),
                      children: const [
                        Text(
                            'A Filipino-focused finance tracker with gamification.'),
                      ],
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Licenses'),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'PesoTracker',
                    applicationVersion: '1.0.0',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.largePadding),
        ],
      ),
    );
  }

  // -------- Helpers --------

  void _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will remove all locally stored expenses, goals, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: call your data clearing service(s) here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All local data cleared.')),
      );
    }
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Choose language',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Filipino (Tagalog)'),
              onTap: () {
                // TODO: integrate with LocaleProvider
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language set to Filipino')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('English'),
              onTap: () {
                // TODO: integrate with LocaleProvider
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language set to English')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title:
                  Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            RadioListTile<String>(
              value: 'system',
              groupValue: 'system', // TODO: bind to real setting
              title: const Text('Use system setting'),
              onChanged: (_) {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme: System')),
                );
              },
            ),
            RadioListTile<String>(
              value: 'light',
              groupValue: 'system',
              title: const Text('Light'),
              onChanged: (_) {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme: Light')),
                );
              },
            ),
            RadioListTile<String>(
              value: 'dark',
              groupValue: 'system',
              title: const Text('Dark'),
              onChanged: (_) {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme: Dark')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentUserCard() {
    return Consumer<GamificationProvider>(
      builder: (context, gamificationProvider, child) {
        final userData = gamificationProvider.currentUser;
        
        if (userData == null) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade400,
                    radius: 24,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No User',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Please create or select a user',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(
              color: AppConstants.primaryColor,
              width: 2,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppConstants.primaryColor,
                  radius: 24,
                  child: Text(
                    userData.name.isNotEmpty ? userData.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userData.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Current',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${gamificationProvider.currentLevel} • ${userData.currentStreak} day streak',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (userData.monthlyIncome > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Monthly Income: ₱${userData.monthlyIncome.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserManagementScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
