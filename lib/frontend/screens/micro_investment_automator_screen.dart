import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MicroInvestmentAutomatorScreen extends StatefulWidget {
  const MicroInvestmentAutomatorScreen({super.key});

  @override
  State<MicroInvestmentAutomatorScreen> createState() => _MicroInvestmentAutomatorScreenState();
}

class _MicroInvestmentAutomatorScreenState extends State<MicroInvestmentAutomatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedRiskProfile = 'Moderate';
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
          'profile': 'Conservative',
          'recommendation': 'Consider investing in low-risk bonds and fixed deposits.',
        },
        {
          'profile': 'Moderate',
          'recommendation': 'A balanced mix of stocks and bonds is recommended.',
        },
        {
          'profile': 'Aggressive',
          'recommendation': 'High-risk stocks and crypto assets are suitable for your profile.',
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
        title: const Text('Micro-Investment Automator'),
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
                      'Set Investment',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Investment Amount'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter an investment amount' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedRiskProfile,
                      items: [
                        'Conservative',
                        'Moderate',
                        'Aggressive',
                      ].map((String value) {
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
                      decoration: const InputDecoration(labelText: 'Risk Profile'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // TODO: Save investment to backend
                        }
                      },
                      child: const Text('Invest'),
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
                          title: Text(recommendation['profile']),
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
    _amountController.dispose();
    super.dispose();
  }
} 