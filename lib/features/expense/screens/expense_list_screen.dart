import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/models/expense.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String? _selectedCategoryFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocaleProvider>(
          builder: (context, locale, child) => Text(
            locale.getLocalizedText('expenses'),
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => NavigationService.goToAddExpense(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, expenseProvider, child) {
                if (expenseProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final filteredExpenses = _getFilteredExpenses(expenseProvider.expenses);

                if (filteredExpenses.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildExpenseList(filteredExpenses);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NavigationService.goToAddExpense(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: AppConstants.smallPadding),
          _buildCategoryFilter(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search expenses...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', _selectedCategoryFilter == null),
          ...AppConstants.expenseCategories.map(
            (category) => _buildFilterChip(
              category,
              _selectedCategoryFilter == category,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (label == 'All') {
              _selectedCategoryFilter = null;
            } else {
              _selectedCategoryFilter = selected ? label : null;
            }
          });
        },
        selectedColor: AppConstants.primaryColor.withOpacity(0.2),
        checkmarkColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                locale.getLocalizedText('no_expenses_yet'),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              ElevatedButton(
                onPressed: () => NavigationService.goToAddExpense(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(locale.getLocalizedText('add_expense')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: InkWell(
            onTap: () => _showExpenseDetails(expense),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getCategoryColor(expense.category).withOpacity(0.2),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: _getCategoryColor(expense.category),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              locale.getLocalizedText(expense.category.toLowerCase()),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (expense.subcategory != null) ...[
                              Text(
                                ' • ${expense.subcategory}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(expense.dateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        locale.formatCurrency(expense.amount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      if (_isToday(expense.dateTime))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.successColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExpenseDetails(Expense expense) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildExpenseDetailSheet(expense),
    );
  }

  Widget _buildExpenseDetailSheet(Expense expense) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getCategoryColor(expense.category).withOpacity(0.2),
                    radius: 30,
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: _getCategoryColor(expense.category),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          locale.formatCurrency(expense.amount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildDetailRow('Category', locale.getLocalizedText(expense.category.toLowerCase())),
              if (expense.subcategory != null)
                _buildDetailRow('Subcategory', expense.subcategory!),
              _buildDetailRow('Date', DateFormat('MMMM dd, yyyy - hh:mm a').format(expense.dateTime)),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(expense);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.errorColor,
                        side: const BorderSide(color: AppConstants.errorColor),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _duplicateExpense(expense);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.primaryColor,
                        side: const BorderSide(color: AppConstants.primaryColor),
                      ),
                      child: const Text('Duplicate'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement edit functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit feature coming soon!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ExpenseProvider>().deleteExpense(expense.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense deleted successfully'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting expense: $e'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateExpense(Expense originalExpense) async {
    try {
      // Create a new expense with the same data but new ID and current timestamp
      final duplicatedExpense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: originalExpense.amount,
        category: originalExpense.category,
        subcategory: originalExpense.subcategory,
        description: '${originalExpense.description} (Copy)',
        dateTime: DateTime.now(),
        receiptPath: originalExpense.receiptPath,
        location: originalExpense.location,
        metadata: originalExpense.metadata != null 
            ? Map<String, dynamic>.from(originalExpense.metadata!)
            : null,
      );

      await context.read<ExpenseProvider>().addExpense(duplicatedExpense);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense duplicated successfully - ₱${duplicatedExpense.amount.toStringAsFixed(2)}'),
            backgroundColor: AppConstants.successColor,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Scroll to top to show the new expense (since it will be at the top)
                // The expense list is already sorted by date desc, so new expenses appear first
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error duplicating expense: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    return expenses.where((expense) {
      final matchesSearch = _searchQuery.isEmpty ||
          expense.description.toLowerCase().contains(_searchQuery) ||
          expense.category.toLowerCase().contains(_searchQuery);
      
      final matchesCategory = _selectedCategoryFilter == null ||
          expense.category == _selectedCategoryFilter;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pagkain':
        return Icons.restaurant;
      case 'transportasyon':
        return Icons.directions_bus;
      case 'bills':
        return Icons.receipt_long;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'pagkain':
        return Colors.orange;
      case 'transportasyon':
        return Colors.blue;
      case 'bills':
        return Colors.red;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}