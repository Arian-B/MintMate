import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseInsightsScreen extends StatefulWidget {
  const ExpenseInsightsScreen({super.key});

  @override
  State<ExpenseInsightsScreen> createState() => _ExpenseInsightsScreenState();
}

class _ExpenseInsightsScreenState extends State<ExpenseInsightsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _expenseInsights = [];
  Map<String, dynamic> _spendingPatterns = {};
  List<String> _savingsTips = [];

  @override
  void initState() {
    super.initState();
    _loadExpenseInsights();
  }

  Future<void> _loadExpenseInsights() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading expense insights
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _expenseInsights = [
          {
            'category': 'Food & Dining',
            'insight': 'Consider reducing dining out expenses to save more.',
          },
          {
            'category': 'Transportation',
            'insight': 'Your transportation costs are within the expected range.',
          },
          {
            'category': 'Housing',
            'insight': 'Housing expenses are high; consider refinancing options.',
          },
        ];
        _spendingPatterns = {
          'totalSpent': 5000,
          'categorySpending': {
            'Food & Dining': 2000,
            'Transportation': 1000,
            'Housing': 2000,
          },
        };
        _savingsTips = [
          'Set up automatic transfers to your savings account.',
          'Review and cancel unused subscriptions.',
          'Plan meals to reduce food waste and save on groceries.',
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading expense insights: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Insights'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Expense Insights',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _expenseInsights.length,
                    itemBuilder: (context, index) {
                      final insight = _expenseInsights[index];
                      return ListTile(
                        title: Text(insight['category']),
                        subtitle: Text(insight['insight']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Spending Patterns',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text('Total Spent: ₹${_spendingPatterns['totalSpent']}'),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _spendingPatterns['categorySpending'].length,
                    itemBuilder: (context, index) {
                      final category = _spendingPatterns['categorySpending'].keys.elementAt(index);
                      final amount = _spendingPatterns['categorySpending'][category];
                      return ListTile(
                        title: Text(category),
                        subtitle: Text('₹$amount'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Personalized Savings Tips',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _savingsTips.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_savingsTips[index]),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadExpenseInsights,
                    child: const Text('Refresh Insights'),
                  ),
                ],
              ),
            ),
    );
  }
} 