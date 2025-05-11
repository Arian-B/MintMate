import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  bool _isLoading = false;
  Map<String, double> _budgetRecommendations = {};
  List<Map<String, dynamic>> _expenses = [];
  List<String> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading budget data
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _budgetRecommendations = {
          'Food & Dining': 500,
          'Transportation': 300,
          'Housing': 1000,
          'Entertainment': 200,
        };
        _expenses = [
          {
            'category': 'Food & Dining',
            'amount': 450,
          },
          {
            'category': 'Transportation',
            'amount': 280,
          },
          {
            'category': 'Housing',
            'amount': 950,
          },
          {
            'category': 'Entertainment',
            'amount': 180,
          },
        ];
        _goals = [
          'Save ₹5000 for emergency fund.',
          'Reduce dining out expenses by 20%.',
          'Increase investment contributions by 10%.',
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading budget data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planner'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Budget Recommendations',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _budgetRecommendations.length,
                    itemBuilder: (context, index) {
                      final category = _budgetRecommendations.keys.elementAt(index);
                      final amount = _budgetRecommendations[category];
                      return ListTile(
                        title: Text(category),
                        subtitle: Text('₹$amount'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Expense Tracking',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return ListTile(
                        title: Text(expense['category']),
                        subtitle: Text('₹${expense['amount']}'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Financial Goals',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_goals[index]),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadBudgetData,
                    child: const Text('Refresh Budget Data'),
                  ),
                ],
              ),
            ),
    );
  }
} 