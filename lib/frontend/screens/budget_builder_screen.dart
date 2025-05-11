import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';
import 'package:mintmate/backend/services/expense_service.dart';
import 'package:mintmate/backend/models/expense.dart';

class BudgetBuilderScreen extends StatefulWidget {
  const BudgetBuilderScreen({super.key});

  @override
  State<BudgetBuilderScreen> createState() => _BudgetBuilderScreenState();
}

class _BudgetBuilderScreenState extends State<BudgetBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  String _selectedCategory = 'Food & Dining';
  double _budgetLimit = 0;
  List<Map<String, dynamic>> _aiRecommendations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAIRecommendations();
  }

  Future<void> _fetchAIRecommendations() async {
    setState(() => _isLoading = true);
    try {
      // Mock AI recommendations
      await Future.delayed(const Duration(seconds: 1));
      _aiRecommendations = [
        {
          'category': 'Food & Dining',
          'recommendation': 'Set a budget of ₹5000 for dining out this month.',
        },
        {
          'category': 'Transportation',
          'recommendation': 'Allocate ₹3000 for transportation expenses.',
        },
      ];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching AI recommendations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Builder'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Budget',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(labelText: 'Budget Limit'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a budget limit' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: [
                        'Food & Dining',
                        'Transportation',
                        'Housing',
                        'Entertainment',
                        'Healthcare',
                        'Education',
                        'Shopping',
                        'Utilities',
                        'Other',
                      ].map((String value) {
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
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _budgetLimit = double.parse(_budgetController.text);
                          // TODO: Save budget to backend
                        }
                      },
                      child: const Text('Set Budget'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AI Recommendations',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _aiRecommendations.length,
                      itemBuilder: (context, index) {
                        final recommendation = _aiRecommendations[index];
                        return ListTile(
                          title: Text(recommendation['category']),
                          subtitle: Text(recommendation['recommendation']),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
} 