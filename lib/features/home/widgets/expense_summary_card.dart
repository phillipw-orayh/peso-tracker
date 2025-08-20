import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../core/constants/app_constants.dart';

class ExpenseSummaryCard extends StatelessWidget {
  const ExpenseSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, LocaleProvider>(
      builder: (context, expenseProvider, locale, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.getLocalizedText('expense_summary'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        title: locale.getLocalizedText('today'),
                        amount: expenseProvider.totalExpensesToday,
                        locale: locale,
                        color: AppConstants.successColor,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: _buildSummaryItem(
                        title: locale.getLocalizedText('this_month'),
                        amount: expenseProvider.totalExpensesThisMonth,
                        locale: locale,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildExpenseChart(expenseProvider, locale),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required double amount,
    required LocaleProvider locale,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            locale.formatCurrency(amount),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(ExpenseProvider expenseProvider, LocaleProvider locale) {
    final categoryExpenses = expenseProvider.expensesByCategory;
    
    if (categoryExpenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Center(
          child: Text(
            locale.getLocalizedText('no_expenses_this_month'),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final sortedEntries = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.getLocalizedText('top_categories'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ...sortedEntries.take(3).map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getCategoryColor(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  locale.getLocalizedText(entry.key.toLowerCase()),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                locale.formatCurrency(entry.value),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )),
      ],
    );
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
}