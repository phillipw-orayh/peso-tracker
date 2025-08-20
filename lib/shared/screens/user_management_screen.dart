import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';
import '../models/user_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/database_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserData> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      _users = DatabaseService.getAllUsers();
      setState(() {});
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppConstants.primaryColor))
          : Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Manage Users',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create, edit, or switch between different user profiles',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Create New User Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateUserDialog(),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Create New User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Users List
                  if (_users.isEmpty)
                    _buildEmptyState()
                  else
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Existing Users (${_users.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                return _buildUserCard(user);
                              },
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

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Users Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first user profile to get started with PesoTracker',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserData user) {
    final gamificationProvider = context.watch<GamificationProvider>();
    final isCurrentUser = gamificationProvider.currentUser?.id == user.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppConstants.primaryColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color:
              isCurrentUser ? AppConstants.primaryColor : Colors.grey.shade200,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor:
              isCurrentUser ? AppConstants.primaryColor : Colors.grey.shade400,
          radius: 24,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              user.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color:
                    isCurrentUser ? AppConstants.primaryColor : Colors.black87,
              ),
            ),
            if (isCurrentUser) ...[
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
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Level ${_calculateLevel(user)} • ${user.currentStreak} day streak',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (user.monthlyIncome > 0) ...[
              const SizedBox(height: 2),
              Text(
                'Monthly Income: ₱${user.monthlyIncome.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            if (!isCurrentUser)
              const PopupMenuItem(
                value: 'switch',
                child: Row(
                  children: [
                    Icon(Icons.switch_account, size: 16),
                    SizedBox(width: 8),
                    Text('Switch to User'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit User'),
                ],
              ),
            ),
            if (_users.length > 1)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _calculateLevel(UserData user) {
    // Simple level calculation based on total points
    return (user.totalPoints / 100).floor() + 1;
  }

  void _handleUserAction(String action, UserData user) {
    switch (action) {
      case 'switch':
        _switchToUser(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _switchToUser(UserData user) async {
    try {
      await context.read<GamificationProvider>().switchUser(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to ${user.name}'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to switch user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreateUserDialog() {
    _showUserDialog(null);
  }

  void _showEditUserDialog(UserData user) {
    _showUserDialog(user);
  }

  void _showUserDialog(UserData? existingUser) {
    final nameController =
        TextEditingController(text: existingUser?.name ?? '');
    final incomeController = TextEditingController(
      text: existingUser?.monthlyIncome.toString() ?? '',
    );
    final budgetController = TextEditingController(
      text: existingUser?.monthlyBudget.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingUser == null ? 'Create New User' : 'Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Enter user name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: incomeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Income (₱)',
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                  prefixText: '₱ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: budgetController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Budget (₱)',
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                  prefixText: '₱ ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _saveUser(
              existingUser,
              nameController.text,
              incomeController.text,
              budgetController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(existingUser == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _saveUser(
    UserData? existingUser,
    String name,
    String incomeStr,
    String budgetStr,
  ) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final income = double.tryParse(incomeStr) ?? 0.0;
    final budget = double.tryParse(budgetStr) ?? 0.0;

    try {
      Navigator.of(context).pop(); // Close dialog

      UserData user;
      if (existingUser == null) {
        // Create new user
        user = UserData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
          email: '', // Default empty email
          monthlyIncome: income,
          monthlyBudget: budget,
          totalPoints: 0,
          currentStreak: 0,
          longestStreak: 0,
          lastActiveDate: DateTime.now(),
        );

        await DatabaseService.createUser(user);

        // Switch to new user if it's the first user
        if (_users.isEmpty) {
          await context.read<GamificationProvider>().switchUser(user.id);
        }
      } else {
        // Update existing user
        user = existingUser.copyWith(
          name: name.trim(),
          monthlyIncome: income,
          monthlyBudget: budget,
        );

        await DatabaseService.updateUser(user);

        // Update current user if editing the active user
        final gamificationProvider = context.read<GamificationProvider>();
        if (gamificationProvider.currentUser?.id == user.id) {
          await gamificationProvider.loadUserData();
        }
      }

      await _loadUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingUser == null
                ? 'User "${user.name}" created successfully'
                : 'User "${user.name}" updated successfully',
          ),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteUserDialog(UserData user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete "${user.name}"?\n\n'
          'This will permanently delete all data associated with this user including expenses, goals, and progress.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteUser(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(UserData user) async {
    try {
      Navigator.of(context).pop(); // Close dialog

      final gamificationProvider = context.read<GamificationProvider>();
      final isCurrentUser = gamificationProvider.currentUser?.id == user.id;

      await DatabaseService.deleteUser(user.id);
      await _loadUsers();

      // If deleting current user, switch to another user or create a default one
      if (isCurrentUser) {
        if (_users.isNotEmpty) {
          await gamificationProvider.switchUser(_users.first.id);
        } else {
          // No users left, clear current user
          await gamificationProvider.clearCurrentUser();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User "${user.name}" deleted successfully'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
