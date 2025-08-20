import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';
import '../../../shared/providers/goal_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/models/savings_goal.dart';

class EditGoalScreen extends StatefulWidget {
  final String goalId;
  
  const EditGoalScreen({super.key, required this.goalId});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _savedAmountController = TextEditingController();
  final _monthsController = TextEditingController();
  
  SavingsGoal? _goal;
  GoalType _selectedGoalType = GoalType.shortTerm;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  bool _isLoadingGoal = true;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    try {
      final goalProvider = context.read<GoalProvider>();
      await goalProvider.loadGoals();
      
      final goal = goalProvider.goals.firstWhere(
        (g) => g.id == widget.goalId,
        orElse: () => throw Exception('Goal not found'),
      );
      
      setState(() {
        _goal = goal;
        _titleController.text = goal.title;
        _descriptionController.text = goal.description;
        _targetAmountController.text = goal.targetAmount.toStringAsFixed(0);
        _savedAmountController.text = goal.savedAmount.toStringAsFixed(0);
        _selectedGoalType = goal.type;
        _targetDate = goal.targetDate;
        _monthsController.text = goal.targetDate.difference(goal.createdDate).inDays ~/ 30 > 0 
            ? (goal.targetDate.difference(goal.createdDate).inDays ~/ 30).toString()
            : '1';
        _isLoadingGoal = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading goal: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        NavigationService.pop();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingGoal || _goal == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppConstants.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocaleProvider>(
          builder: (context, locale, child) => Text(
            locale.getLocalizedText('edit_goal'),
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
              _buildGoalTypeSelector(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildTitleField(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildDescriptionField(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildTargetAmountField(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildSavedAmountField(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildTimelineSection(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildSavingsCalculator(),
              const SizedBox(height: AppConstants.largePadding),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Row(
          children: GoalType.values.map((type) {
            final isSelected = _selectedGoalType == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGoalType = type;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppConstants.primaryColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getGoalTypeIcon(type),
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getGoalTypeName(type),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., iPhone 15 Pro para sa work',
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
              return 'Please enter a goal title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description (Optional)',
          style: TextStyle(
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
            hintText: 'Why is this goal important to you?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: const BorderSide(color: AppConstants.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextFormField(
          controller: _targetAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\\d*\\.?\\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: 'Enter target amount',
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
          onChanged: _calculateSavings,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter target amount';
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
  }

  Widget _buildSavedAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Saved Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextFormField(
          controller: _savedAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\\d*\\.?\\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: 'Enter saved amount',
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
              return 'Please enter saved amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (double.parse(value) < 0) {
              return 'Amount must be 0 or greater';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _monthsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Months',
                  suffixText: 'months',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    borderSide: const BorderSide(color: AppConstants.primaryColor),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final months = int.tryParse(value) ?? 1;
                    setState(() {
                      _targetDate = DateTime.now().add(Duration(days: months * 30));
                    });
                    _calculateSavings(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppConstants.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSavingsCalculator() {
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
    final savedAmount = double.tryParse(_savedAmountController.text) ?? 0;
    final remainingAmount = targetAmount - savedAmount;
    final months = int.tryParse(_monthsController.text) ?? 1;
    final monthlyAmount = remainingAmount / months;
    final weeklyAmount = monthlyAmount / 4;
    final dailyAmount = monthlyAmount / 30;

    if (targetAmount <= 0 || remainingAmount <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: AppConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Savings Calculator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'To reach your remaining goal of ₱${remainingAmount.toStringAsFixed(0)} in $months months:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildCalculatorRow('Daily', dailyAmount),
          _buildCalculatorRow('Weekly', weeklyAmount),
          _buildCalculatorRow('Monthly', monthlyAmount),
        ],
      ),
    );
  }

  Widget _buildCalculatorRow(String period, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$period:'),
          Text(
            '₱${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateGoal,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Update Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    
    if (date != null) {
      setState(() {
        _targetDate = date;
        final months = date.difference(DateTime.now()).inDays ~/ 30;
        _monthsController.text = months.toString();
      });
      _calculateSavings(_targetAmountController.text);
    }
  }

  void _calculateSavings(String? value) {
    if (mounted) setState(() {});
  }

  Future<void> _updateGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedGoal = _goal!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? _titleController.text.trim() 
            : _descriptionController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        savedAmount: double.parse(_savedAmountController.text),
        targetDate: _targetDate,
        type: _selectedGoalType,
      );

      await context.read<GoalProvider>().updateGoal(updatedGoal);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal updated successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        NavigationService.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating goal: $e'),
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

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.shortTerm:
        return Icons.flash_on;
      case GoalType.mediumTerm:
        return Icons.trending_up;
      case GoalType.longTerm:
        return Icons.emoji_events;
    }
  }

  String _getGoalTypeName(GoalType type) {
    switch (type) {
      case GoalType.shortTerm:
        return 'Short\\n(1-6 months)';
      case GoalType.mediumTerm:
        return 'Medium\\n(6 months-2 years)';
      case GoalType.longTerm:
        return 'Long\\n(2+ years)';
    }
  }
}