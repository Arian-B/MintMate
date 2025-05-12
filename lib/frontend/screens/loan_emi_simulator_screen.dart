import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mintmate/backend/services/ai_service.dart';
import 'dart:math';

class LoanEMISimulatorScreen extends StatefulWidget {
  const LoanEMISimulatorScreen({super.key});

  @override
  State<LoanEMISimulatorScreen> createState() => _LoanEMISimulatorScreenState();
}

class _LoanEMISimulatorScreenState extends State<LoanEMISimulatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _loanTermController = TextEditingController();
  final _prepaymentAmountController = TextEditingController();
  double _emi = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;
  List<Map<String, dynamic>> _paymentSchedule = [];
  List<Map<String, dynamic>> _aiSuggestions = [];
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculateEMI();
  }

  void _calculateEMI() {
    if (_formKey.currentState?.validate() ?? false) {
      final loanAmount = double.parse(_loanAmountController.text);
      final interestRate = double.parse(_interestRateController.text) / 100 / 12; // Monthly interest rate
      final loanTerm = int.parse(_loanTermController.text) * 12; // Total number of months

      _emi = (loanAmount * interestRate * pow(1 + interestRate, loanTerm)) / (pow(1 + interestRate, loanTerm) - 1);
      _totalPayment = _emi * loanTerm;
      _totalInterest = _totalPayment - loanAmount;

      _generatePaymentSchedule(loanAmount, interestRate, loanTerm);
      _generateAISuggestions(loanAmount, interestRate, loanTerm);
    }
  }

  void _generatePaymentSchedule(double loanAmount, double interestRate, int loanTerm) {
    _paymentSchedule = [];
    double remainingLoan = loanAmount;

    for (int i = 1; i <= loanTerm; i++) {
      final interest = remainingLoan * interestRate;
      final principal = _emi - interest;
      remainingLoan -= principal;

      _paymentSchedule.add({
        'month': i,
        'principal': principal,
        'interest': interest,
        'remainingLoan': remainingLoan,
      });
    }
  }

  void _generateAISuggestions(double loanAmount, double interestRate, int loanTerm) {
    final aiService = AIService();
    _aiSuggestions = aiService.getLoanSuggestions(loanAmount, interestRate, loanTerm);
  }

  void _analyzePrepayment() {
    if (_formKey.currentState?.validate() ?? false) {
      final loanAmount = double.parse(_loanAmountController.text);
      final interestRate = double.parse(_interestRateController.text) / 100 / 12; // Monthly interest rate
      final loanTerm = int.parse(_loanTermController.text) * 12; // Total number of months
      final prepaymentAmount = double.parse(_prepaymentAmountController.text);

      final newLoanAmount = loanAmount - prepaymentAmount;
      final newEMI = (newLoanAmount * interestRate * pow(1 + interestRate, loanTerm)) / (pow(1 + interestRate, loanTerm) - 1);
      final newTotalPayment = newEMI * loanTerm;
      final newTotalInterest = newTotalPayment - newLoanAmount;

      final interestSaved = _totalInterest - newTotalInterest;
      final monthsReduced = (loanTerm - (newTotalPayment / _emi)).round();

      setState(() {
        _aiSuggestions.add({
          'suggestion': 'Prepayment Analysis',
          'details': 'Prepaying ₹${prepaymentAmount.toStringAsFixed(2)} can save you ₹${interestSaved.toStringAsFixed(2)} in interest and reduce your loan term by $monthsReduced months.',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan EMI Simulator'),
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
                      'Loan Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _loanAmountController,
                      decoration: const InputDecoration(labelText: 'Loan Amount (₹)'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter loan amount' : null,
                    ),
                    TextFormField(
                      controller: _interestRateController,
                      decoration: const InputDecoration(labelText: 'Interest Rate (%)'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter interest rate' : null,
                    ),
                    TextFormField(
                      controller: _loanTermController,
                      decoration: const InputDecoration(labelText: 'Loan Term (Years)'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter loan term' : null,
                    ),
                    TextFormField(
                      controller: _prepaymentAmountController,
                      decoration: const InputDecoration(labelText: 'Prepayment Amount (₹)'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter prepayment amount' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _calculateEMI,
                      child: const Text('Calculate EMI'),
                    ),
                    ElevatedButton(
                      onPressed: _analyzePrepayment,
                      child: const Text('Analyze Prepayment'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'EMI: ₹${_emi.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Interest: ₹${_totalInterest.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Total Payment: ₹${_totalPayment.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Payment Schedule',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _paymentSchedule.length,
                      itemBuilder: (context, index) {
                        final payment = _paymentSchedule[index];
                        return ListTile(
                          title: Text('Month ${payment['month']}'),
                          subtitle: Text(
                            'Principal: ₹${payment['principal'].toStringAsFixed(2)}, Interest: ₹${payment['interest'].toStringAsFixed(2)}',
                          ),
                          trailing: Text(
                            'Remaining: ₹${payment['remainingLoan'].toStringAsFixed(2)}',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AI Suggestions',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _aiSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _aiSuggestions[index];
                        return ListTile(
                          title: Text(suggestion['suggestion']),
                          subtitle: Text(suggestion['details']),
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
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    _prepaymentAmountController.dispose();
    super.dispose();
  }
} 