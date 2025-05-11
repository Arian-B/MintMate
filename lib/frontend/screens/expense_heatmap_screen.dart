import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseHeatmapScreen extends StatefulWidget {
  const ExpenseHeatmapScreen({super.key});

  @override
  State<ExpenseHeatmapScreen> createState() => _ExpenseHeatmapScreenState();
}

class _ExpenseHeatmapScreenState extends State<ExpenseHeatmapScreen> {
  bool _isLoading = false;
  Map<String, double> _categorySpending = {};
  List<Map<String, dynamic>> _aiInsights = [];
  String _selectedTimeFrame = 'Monthly';

  @override
  void initState() {
    super.initState();
    _loadExpenseData();
  }

  Future<void> _loadExpenseData() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading expense data
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _categorySpending = {
          'Food & Dining': 2000,
          'Transportation': 1000,
          'Housing': 2000,
          'Entertainment': 500,
        };
        _aiInsights = [
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
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading expense data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildHeatmap() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _categorySpending.length,
      itemBuilder: (context, index) {
        final category = _categorySpending.keys.elementAt(index);
        final amount = _categorySpending[category];
        final color = _getColorForAmount(amount);
        return Card(
          color: color,
          child: InkWell(
            onTap: () => _showCategoryDetails(category, amount),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    '₹$amount',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorForAmount(double? amount) {
    if (amount == null) return Colors.grey;
    if (amount > 1500) return Colors.red;
    if (amount > 1000) return Colors.orange;
    return Colors.green;
  }

  void _showCategoryDetails(String category, double? amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category),
        content: Text('Amount: ₹${amount ?? 0}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Heatmap'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Spending',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildHeatmap(),
                  const SizedBox(height: 24),
                  Text(
                    'AI Insights',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _aiInsights.length,
                    itemBuilder: (context, index) {
                      final insight = _aiInsights[index];
                      return ListTile(
                        title: Text(insight['category']),
                        subtitle: Text(insight['insight']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadExpenseData,
                    child: const Text('Refresh Expense Data'),
                  ),
                ],
              ),
            ),
    );
  }
} 