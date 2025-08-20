import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/providers/gamification_provider.dart';
import '../../../shared/models/user_data.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/database_service.dart';
import 'user_management_screen.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius * 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: AppConstants.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // User Management Section
            _buildSettingsSection(
              'User Management',
              Icons.person,
              [
                _buildSettingsItem(
                  'Manage Users',
                  'Create, edit, or switch users',
                  Icons.people,
                  () => _navigateToUserManagement(),
                ),
                _buildSettingsItem(
                  'Current User',
                  _getCurrentUserInfo(),
                  Icons.account_circle,
                  () => _showCurrentUserDetails(),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // App Settings Section
            _buildSettingsSection(
              'App Settings',
              Icons.tune,
              [
                _buildLanguageToggle(),
                _buildSettingsItem(
                  'Export Data',
                  'Backup your financial data',
                  Icons.download,
                  () => _showExportDialog(),
                ),
                _buildSettingsItem(
                  'Import Data',
                  'Restore from backup',
                  Icons.upload,
                  () => _showImportDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // About Section
            _buildSettingsSection(
              'About',
              Icons.info,
              [
                _buildSettingsItem(
                  'App Version',
                  '1.0.0',
                  Icons.apps,
                  null,
                ),
                _buildSettingsItem(
                  'Privacy Policy',
                  'Your data stays on your device',
                  Icons.privacy_tip,
                  () => _showPrivacyInfo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          color: onTap != null ? Colors.grey.shade50 : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: onTap != null ? AppConstants.primaryColor : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: onTap != null ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return InkWell(
          onTap: () => locale.toggleLanguage(),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        locale.isFilipino ? 'Filipino (Tagalog)' : 'English',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: locale.isFilipino,
                  onChanged: (_) => locale.toggleLanguage(),
                  activeThumbColor: AppConstants.primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getCurrentUserInfo() {
    final gamificationProvider = context.read<GamificationProvider>();
    final userData = gamificationProvider.currentUser;
    
    if (userData == null) {
      return 'No user selected';
    }
    
    return '${userData.name} (Level ${gamificationProvider.currentLevel})';
  }

  void _navigateToUserManagement() {
    Navigator.of(context).pop(); // Close settings dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserManagementScreen(),
      ),
    );
  }

  void _showCurrentUserDetails() {
    final gamificationProvider = context.read<GamificationProvider>();
    final userData = gamificationProvider.currentUser;
    
    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user selected')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${userData.name}\'s Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserDetailRow('Name', userData.name),
            _buildUserDetailRow('Level', '${gamificationProvider.currentLevel}'),
            _buildUserDetailRow('Total Points', '${gamificationProvider.totalPoints}'),
            _buildUserDetailRow('Current Streak', '${userData.currentStreak} days'),
            _buildUserDetailRow('Longest Streak', '${userData.longestStreak} days'),
            if (userData.monthlyIncome > 0)
              _buildUserDetailRow('Monthly Income', '₱${userData.monthlyIncome.toStringAsFixed(0)}'),
            if (userData.monthlyBudget > 0)
              _buildUserDetailRow('Monthly Budget', '₱${userData.monthlyBudget.toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'This will export all your expenses, goals, and user data to a JSON file. '
          'You can use this file to restore your data later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportData();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'This will import data from a previously exported JSON file. '
          'This may overwrite existing data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _importData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'PesoTracker is designed with privacy in mind:\n\n'
          '• All your data stays on your device\n'
          '• No data is sent to external servers\n'
          '• No analytics or tracking\n'
          '• You control all data export/import\n\n'
          'Your financial information is completely private and secure.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    try {
      // This would implement actual file export
      // For now, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data export feature coming soon!'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importData() {
    try {
      // This would implement actual file import
      // For now, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data import feature coming soon!'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}