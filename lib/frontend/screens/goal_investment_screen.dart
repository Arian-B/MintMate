import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class GoalInvestmentScreen extends StatefulWidget {
  const GoalInvestmentScreen({super.key});

  @override
  State<GoalInvestmentScreen> createState() => _GoalInvestmentScreenState();
}

class _GoalInvestmentScreenState extends State<GoalInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetAmountController = TextEditingController();
  final _timeFrameController = TextEditingController();
  String _selectedGoalType = 'Short-term Goal';
  String _selectedRiskProfile = 'Moderate';
  bool _isLoading = false;
  List<Map<String, dynamic>> _recommendations = [];
  final _aiService = AIService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _generateRecommendations() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final targetAmount = double.parse(_targetAmountController.text);
      final timeFrame = int.parse(_timeFrameController.text);

      final recommendations = await _aiService.generateGoalBasedRecommendations(
        goalType: _selectedGoalType,
        targetAmount: targetAmount,
        timeFrame: timeFrame,
        riskProfile: _selectedRiskProfile,
      );

      setState(() {
        _recommendations = recommendations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating recommendations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal-Based Investment'),
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
                      'Investment Goal Planner',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _selectedGoalType,
                      decoration: const InputDecoration(
                        labelText: 'Goal Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Emergency Fund',
                        'Short-term Goal',
                        'Long-term Goal',
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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Target Amount (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter target amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _timeFrameController,
                      decoration: const InputDecoration(
                        labelText: 'Time Frame (Years)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter time frame';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRiskProfile,
                      decoration: const InputDecoration(
                        labelText: 'Risk Profile',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Conservative', 'Moderate', 'Aggressive']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRiskProfile = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _generateRecommendations,
                      child: const Text('Generate Recommendations'),
                    ),
                    if (_recommendations.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildRecommendationsList(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRecommendationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Recommendations',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._recommendations.map((recommendation) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['asset'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRecommendationRow(
                  'Allocation',
                  '${(recommendation['allocation'] * 100).toStringAsFixed(1)}%',
                ),
                _buildRecommendationRow(
                  'Monthly Investment',
                  '₹${recommendation['monthlyAmount'].toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation['rationale'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildRecommendationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _targetAmountController.dispose();
    _timeFrameController.dispose();
    super.dispose();
  }
} 