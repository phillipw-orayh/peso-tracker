import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = AppConstants.expenseCategories.first;
  String? _selectedSubcategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> _getSubcategories(String category) {
    switch (category) {
      case 'Pagkain':
        return AppConstants.foodSubcategories;
      case 'Transportasyon':
        return AppConstants.transportationSubcategories;
      case 'Bills':
        return AppConstants.billsSubcategories;
      default:
        return [];
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        subcategory: _selectedSubcategory,
        description: _descriptionController.text.trim(),
        dateTime: _selectedDate,
      );

      await context.read<ExpenseProvider>().addExpense(expense);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        NavigationService.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding expense: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocaleProvider>(
          builder: (context, locale, child) => Text(
            locale.getLocalizedText('add_expense'),
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountField(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildCategorySelection(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildSubcategorySelection(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildDescriptionField(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildDateSelection(),
              const SizedBox(height: AppConstants.largePadding),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.getLocalizedText('amount'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: 'Enter amount in pesos',
                prefixText: '₱ ',
                prefixStyle: const TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: const BorderSide(color: AppConstants.primaryColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelection() {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.getLocalizedText('category'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  items: AppConstants.expenseCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(locale.getLocalizedText(category.toLowerCase())),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _selectedSubcategory = null;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubcategorySelection() {
    final subcategories = _getSubcategories(_selectedCategory);
    
    if (subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subcategory',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSubcategory,
              hint: const Text('Select subcategory (optional)'),
              items: subcategories.map((subcategory) {
                return DropdownMenuItem(
                  value: subcategory,
                  child: Text(subcategory),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubcategory = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.getLocalizedText('description'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What did you spend on? (e.g., lunch sa Jollibee)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: const BorderSide(color: AppConstants.primaryColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppConstants.primaryColor),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    locale.getLocalizedText('save'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
}