import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' show log;

class DebtPlannerScreen extends StatefulWidget {
  const DebtPlannerScreen({super.key});

  @override
  State<DebtPlannerScreen> createState() => _DebtPlannerScreenState();
}

class _DebtPlannerScreenState extends State<DebtPlannerScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _debts = [];
  List<Map<String, dynamic>> _payoffPlan = [];
  List<Map<String, dynamic>> _negotiationTemplates = [];

  @override
  void initState() {
    super.initState();
    _loadDebtData();
  }

  Future<void> _loadDebtData() async {
    setState(() => _isLoading = true);
    try {
      // Mock debt data
      _debts = [
        {
          'name': 'Student Loan',
          'amount': 50000.0,
          'interestRate': 5.0,
          'minimumPayment': 500.0,
          'type': 'student_loan',
        },
        {
          'name': 'Credit Card',
          'amount': 10000.0,
          'interestRate': 18.0,
          'minimumPayment': 200.0,
          'type': 'credit_card',
        },
      ];

      // Generate payoff plan
      _payoffPlan = await _generatePayoffPlan();
      
      // Generate negotiation templates
      _negotiationTemplates = await _generateNegotiationTemplates();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading debt data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _generatePayoffPlan() async {
    // Sort debts by interest rate (highest first)
    final sortedDebts = List<Map<String, dynamic>>.from(_debts)
      ..sort((a, b) => (b['interestRate'] as double).compareTo(a['interestRate'] as double));

    final plan = <Map<String, dynamic>>[];
    double totalMonthlyPayment = 1000.0; // Example total monthly payment

    for (var debt in sortedDebts) {
      final monthlyPayment = debt == sortedDebts.first
          ? totalMonthlyPayment
          : debt['minimumPayment'] as double;

      final monthsToPayoff = _calculateMonthsToPayoff(
        debt['amount'] as double,
        debt['interestRate'] as double,
        monthlyPayment,
      );

      plan.add({
        'debt': debt['name'],
        'monthlyPayment': monthlyPayment,
        'monthsToPayoff': monthsToPayoff,
        'totalInterest': _calculateTotalInterest(
          debt['amount'] as double,
          debt['interestRate'] as double,
          monthlyPayment,
          monthsToPayoff,
        ),
        'strategy': _getPayoffStrategy(debt['type'] as String),
      });
    }

    return plan;
  }

  int _calculateMonthsToPayoff(double principal, double annualRate, double monthlyPayment) {
    final monthlyRate = annualRate / 12 / 100;
    if (monthlyPayment <= principal * monthlyRate) return -1; // Will never pay off

    return (log(monthlyPayment / (monthlyPayment - principal * monthlyRate)) /
            log(1 + monthlyRate))
        .ceil();
  }

  double _calculateTotalInterest(
    double principal,
    double annualRate,
    double monthlyPayment,
    int months,
  ) {
    final monthlyRate = annualRate / 12 / 100;
    return (monthlyPayment * months) - (principal * (1 + monthlyRate * months));
  }

  String _getPayoffStrategy(String debtType) {
    switch (debtType) {
      case 'student_loan':
        return 'Focus on paying off high-interest student loans first. Consider income-driven repayment plans if eligible.';
      case 'credit_card':
        return 'Pay more than minimum on high-interest credit cards. Consider balance transfer options.';
      default:
        return 'Prioritize paying off high-interest debt first.';
    }
  }

  Future<List<Map<String, dynamic>>> _generateNegotiationTemplates() async {
    return [
      {
        'type': 'student_loan',
        'template': '''
Dear [Lender Name],

I am writing regarding my student loan account [Account Number]. I am committed to repaying my loan but am currently facing financial challenges.

I would like to discuss the possibility of:
1. Lowering my interest rate
2. Extending my repayment term
3. Switching to an income-driven repayment plan

I have been a responsible borrower and would appreciate any assistance you can provide.

Thank you for your consideration.

Best regards,
[Your Name]
''',
      },
      {
        'type': 'credit_card',
        'template': '''
Dear [Credit Card Company],

I am writing regarding my credit card account [Account Number]. I have been a loyal customer for [X] years and have always made timely payments.

I would like to request:
1. A lower interest rate
2. A reduction in annual fees
3. A payment plan for my current balance

I value our relationship and would appreciate any assistance you can provide.

Thank you for your consideration.

Best regards,
[Your Name]
''',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Payoff Planner'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDebtSummary(),
                  const SizedBox(height: 24),
                  _buildPayoffPlan(),
                  const SizedBox(height: 24),
                  _buildNegotiationTemplates(),
                ],
              ),
            ),
    );
  }

  Widget _buildDebtSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Debts',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._debts.map((debt) => ListTile(
              title: Text(debt['name']),
              subtitle: Text('Interest Rate: ${debt['interestRate']}%'),
              trailing: Text(
                '₹${debt['amount'].toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoffPlan() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payoff Plan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._payoffPlan.map((plan) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan['debt'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPlanRow('Monthly Payment', '₹${plan['monthlyPayment'].toStringAsFixed(2)}'),
                _buildPlanRow('Months to Payoff', '${plan['monthsToPayoff']}'),
                _buildPlanRow('Total Interest', '₹${plan['totalInterest'].toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text(
                  plan['strategy'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Divider(),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRow(String label, String value) {
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

  Widget _buildNegotiationTemplates() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Negotiation Templates',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._negotiationTemplates.map((template) => ExpansionTile(
              title: Text(
                template['type'] == 'student_loan' ? 'Student Loan' : 'Credit Card',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    template['template'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement copy to clipboard
                    },
                    child: const Text('Copy Template'),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
} 