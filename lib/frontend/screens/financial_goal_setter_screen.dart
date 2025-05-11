import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class FinancialGoalSetterScreen extends StatefulWidget {
  const FinancialGoalSetterScreen({super.key});

  @override
  State<FinancialGoalSetterScreen> createState() => _FinancialGoalSetterScreenState();
}

class _FinancialGoalSetterScreenState extends State<FinancialGoalSetterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalNameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  String _selectedGoalType = 'Short-term';
  double _targetAmount = 0;
  double _currentAmount = 0;
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
          'goalType': 'Short-term',
          'recommendation': 'Set a goal to save ₹10,000 for an emergency fund.',
        },
        {
          'goalType': 'Long-term',
          'recommendation': 'Consider investing in a retirement fund for long-term growth.',
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
        title: const Text('Financial Goal Setter'),
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
                      'Set Financial Goal',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _goalNameController,
                      decoration: const InputDecoration(labelText: 'Goal Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a goal name' : null,
                    ),
                    TextFormField(
                      controller: _targetAmountController,
                      decoration: const InputDecoration(labelText: 'Target Amount'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a target amount' : null,
                    ),
                    TextFormField(
                      controller: _currentAmountController,
                      decoration: const InputDecoration(labelText: 'Current Amount'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter the current amount' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedGoalType,
                      items: [
                        'Short-term',
                        'Long-term',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGoalType = newValue!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Goal Type'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _targetAmount = double.parse(_targetAmountController.text);
                          _currentAmount = double.parse(_currentAmountController.text);
                          // TODO: Save goal to backend
                        }
                      },
                      child: const Text('Set Goal'),
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
                          title: Text(recommendation['goalType']),
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
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }
} 