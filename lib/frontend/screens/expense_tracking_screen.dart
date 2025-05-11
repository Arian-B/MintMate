import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mintmate/backend/models/expense.dart';
import 'package:mintmate/backend/services/expense_service.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  const ExpenseTrackingScreen({super.key});

  @override
  _ExpenseTrackingScreenState createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoading = false;
  List<Expense> _expenses = [];
  Map<String, double> _expenseStats = {};
  List<Map<String, dynamic>> _monthlyTrend = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        _expenseService.getExpenses(userId).listen((expenses) {
          setState(() {
            _expenses = expenses;
          });
          _checkOverspending(expenses);
        });

        _expenseStats = await _expenseService.getExpenseStats(userId);
        _monthlyTrend = await _expenseService.getMonthlyTrend(userId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading expenses: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkOverspending(List<Expense> expenses) {
    final aiService = AIService();
    final List<Map<String, dynamic>> expenseMaps = expenses.map((e) => {
      'amount': e.amount,
      'category': e.category,
    }).toList();
    final analysis = aiService.analyzeSpendingPatterns(expenseMaps);
    final categoryPercentages = analysis['categoryPercentages'] as Map<String, double>;
    categoryPercentages.forEach((category, percentage) {
      if (percentage > 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Warning: $category exceeds 50% of total spending!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MintMate - Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExpenses,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildExpenseChart(),
                    _buildMonthlyTrend(),
                    _buildExpenseList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpenseChart() {
    if (_expenseStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = _expenseStats['total'] ?? 0;
    final sections = _expenseStats.entries
        .where((e) => e.key != 'total')
        .map((e) => PieChartSectionData(
              value: e.value,
              title: '${(e.value / total * 100).toStringAsFixed(1)}%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ))
        .toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Expense Distribution',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrend() {
    if (_monthlyTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Monthly Trend',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= _monthlyTrend.length) {
                          return const Text('');
                        }
                        final month = _monthlyTrend[value.toInt()]['month'] as String;
                        return Text(month.substring(5)); // Show only MM
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _monthlyTrend.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value['amount'] as double);
                    }).toList(),
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _deleteExpense(expense),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            title: Text(expense.description),
            subtitle: Text(expense.category),
            trailing: Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addExpense() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );

    if (result != null) {
      try {
        final userId = context.read<AuthService>().currentUser?.uid;
        if (userId != null) {
          final aiService = AIService();
          final autoCategory = aiService.categorizeExpense(
            result['description'] as String,
            (result['amount'] as num).toDouble(),
          );
          final expense = Expense(
            amount: (result['amount'] as num).toDouble(),
            category: autoCategory,
            date: DateTime.now(),
            description: result['description'] as String,
            userId: userId,
            isRecurring: false,
            receiptImageUrl: null,
            recurringPeriod: null,
            paymentMethod: null,
            location: null,
            tags: null,
          );
          await _expenseService.createExpense(expense);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding expense: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    try {
      await _expenseService.deleteExpense(expense.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting expense: $e')),
        );
      }
    }
  }

  void _showAnalytics() {
    // TODO: Implement detailed analytics view
  }
}

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Other';

  final List<String> _categories = [
    'Food & Dining',
    'Transportation',
    'Housing',
    'Entertainment',
    'Healthcare',
    'Education',
    'Shopping',
    'Utilities',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a description' : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter an amount' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, {
        'description': _descriptionController.text,
        'amount': double.parse(_amountController.text),
        'category': _selectedCategory,
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
} 