import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';
import '../../../shared/providers/goal_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/models/savings_goal.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _monthsController = TextEditingController();
  
  GoalType _selectedGoalType = GoalType.shortTerm;
  String? _selectedTemplate;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  // Filipino-themed goal templates
  final Map<GoalType, Map<String, Map<String, dynamic>>> _goalTemplates = {
    GoalType.shortTerm: {
      'New Phone': {
        'description': 'Latest smartphone para sa work at social media',
        'suggestedAmount': 25000.0,
        'icon': Icons.phone_android,
      },
      'Concert Tickets': {
        'description': 'Tickets para sa favorite artist mo',
        'suggestedAmount': 8000.0,
        'icon': Icons.music_note,
      },
      'Weekend Trip sa Baguio': {
        'description': 'Relaxing weekend getaway sa City of Pines',
        'suggestedAmount': 12000.0,
        'icon': Icons.landscape,
      },
      'Emergency Fund': {
        'description': '3 months expenses para sa emergencies',
        'suggestedAmount': 45000.0,
        'icon': Icons.security,
      },
    },
    GoalType.mediumTerm: {
      'Laptop for Work/School': {
        'description': 'Gaming or work laptop para sa productivity',
        'suggestedAmount': 60000.0,
        'icon': Icons.laptop,
      },
      'Vacation Abroad': {
        'description': 'Dream vacation sa Japan, Korea, or Europe',
        'suggestedAmount': 80000.0,
        'icon': Icons.flight,
      },
      'Course/Certification': {
        'description': 'Professional development or skill upgrade',
        'suggestedAmount': 25000.0,
        'icon': Icons.school,
      },
      'Small Business Capital': {
        'description': 'Startup capital para sa online business',
        'suggestedAmount': 100000.0,
        'icon': Icons.business,
      },
    },
    GoalType.longTerm: {
      'House Down Payment': {
        'description': 'Down payment para sa sariling bahay',
        'suggestedAmount': 500000.0,
        'icon': Icons.home,
      },
      'Car Purchase': {
        'description': 'Brand new or second-hand sasakyan',
        'suggestedAmount': 300000.0,
        'icon': Icons.directions_car,
      },
      'Retirement Fund': {
        'description': 'Investment para sa future retirement',
        'suggestedAmount': 1000000.0,
        'icon': Icons.savings,
      },
      'Children\'s Education': {
        'description': 'College fund para sa mga anak',
        'suggestedAmount': 800000.0,
        'icon': Icons.child_care,
      },
    },
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocaleProvider>(
          builder: (context, locale, child) => Text(
            locale.getLocalizedText('new_goal'),
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
              _buildGoalTemplates(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildTitleField(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildDescriptionField(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildTargetAmountField(),
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
                      _selectedTemplate = null;
                      _updateTargetDate();
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

  Widget _buildGoalTemplates() {
    final templates = _goalTemplates[_selectedGoalType]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Goals',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final templateName = templates.keys.elementAt(index);
            final template = templates[templateName]!;
            final isSelected = _selectedTemplate == templateName;
            
            return GestureDetector(
              onTap: () => _selectTemplate(templateName, template),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      template['icon'],
                      size: 32,
                      color: isSelected ? AppConstants.primaryColor : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      templateName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppConstants.primaryColor : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '₱${(template['suggestedAmount'] as double).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? AppConstants.primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
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
    final months = int.tryParse(_monthsController.text) ?? 1;
    final monthlyAmount = targetAmount / months;
    final weeklyAmount = monthlyAmount / 4;
    final dailyAmount = monthlyAmount / 30;

    if (targetAmount <= 0) return const SizedBox.shrink();

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
            'To reach your goal of ₱${targetAmount.toStringAsFixed(0)} in $months months:',
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
        onPressed: _isLoading ? null : _submitGoal,
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
                'Create Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _selectTemplate(String templateName, Map<String, dynamic> template) {
    setState(() {
      _selectedTemplate = templateName;
      _titleController.text = templateName;
      _descriptionController.text = template['description'];
      _targetAmountController.text = (template['suggestedAmount'] as double).toStringAsFixed(0);
      _updateTargetDate();
      _calculateSavings(_targetAmountController.text);
    });
  }

  void _updateTargetDate() {
    final defaultMonths = _selectedGoalType == GoalType.shortTerm ? 3 
        : _selectedGoalType == GoalType.mediumTerm ? 12 : 24;
    
    setState(() {
      _monthsController.text = defaultMonths.toString();
      _targetDate = DateTime.now().add(Duration(days: defaultMonths * 30));
    });
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

  Future<void> _submitGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final goal = SavingsGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? _titleController.text.trim() 
            : _descriptionController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        createdDate: DateTime.now(),
        targetDate: _targetDate,
        type: _selectedGoalType,
      );

      await context.read<GoalProvider>().addGoal(goal);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal created successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        NavigationService.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating goal: $e'),
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
        return 'Short\n(1-6 months)';
      case GoalType.mediumTerm:
        return 'Medium\n(6 months-2 years)';
      case GoalType.longTerm:
        return 'Long\n(2+ years)';
    }
  }
}