import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  bool _isLoading = false;
  double _loanAmount = 0;
  double _interestRate = 0;
  int _loanTerm = 0;
  double _emi = 0;
  List<Map<String, dynamic>> _loanSuggestions = [];

  @override
  void initState() {
    super.initState();
    _calculateEMI();
  }

  Future<void> _calculateEMI() async {
    setState(() => _isLoading = true);
    try {
      // Mock EMI calculation
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _emi = _loanAmount * _interestRate / (1 - math.pow(1 + _interestRate, -_loanTerm));
        _loanSuggestions = [
          {
            'suggestion': 'Consider increasing your EMI to reduce total interest.',
            'details': 'Increasing your EMI by 10% can save you ₹${(_loanAmount * 0.1).toStringAsFixed(2)} in interest.',
          },
          {
            'suggestion': 'Prepay a portion of your loan to reduce the loan term.',
            'details': 'Prepaying 20% of your loan can reduce your loan term by ${(_loanTerm * 0.2).toStringAsFixed(0)} months.',
          },
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error calculating EMI: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Calculator'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EMI: ₹$_emi',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AI Loan Suggestions',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _loanSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _loanSuggestions[index];
                      return ListTile(
                        title: Text(suggestion['suggestion']),
                        subtitle: Text(suggestion['details']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _calculateEMI,
                    child: const Text('Recalculate EMI'),
                  ),
                ],
              ),
            ),
    );
  }
} 