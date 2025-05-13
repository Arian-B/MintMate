import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mintmate/backend/services/ai_service.dart';
import 'package:mintmate/backend/services/account_aggregation_service.dart';
import 'package:intl/intl.dart';

class TaxCompanionScreen extends StatefulWidget {
  const TaxCompanionScreen({super.key});

  @override
  State<TaxCompanionScreen> createState() => _TaxCompanionScreenState();
}

class _TaxCompanionScreenState extends State<TaxCompanionScreen> {
  bool _isLoading = false;
  final _aiService = AIService();
  final _accountService = AccountAggregationService();
  
  // Tax estimation
  Map<String, dynamic> _taxEstimate = {
    'totalIncome': 0.0,
    'taxableIncome': 0.0,
    'estimatedTax': 0.0,
    'incomeBreakdown': {},
    'taxBreakdown': {},
  };
  
  // Deductions
  List<Map<String, dynamic>> _suggestedDeductions = [];
  
  // Reminders
  List<Map<String, dynamic>> _taxReminders = [];
  
  // Document checklist
  List<Map<String, dynamic>> _documentChecklist = [];
  
  // Form controllers
  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();
  String _selectedIncomeType = 'Full-time';
  
  @override
  void initState() {
    super.initState();
    _loadTaxData();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    super.dispose();
  }

  Future<void> _loadTaxData() async {
    setState(() => _isLoading = true);
    try {
      // Get user's financial data
      const userId = 'current_user_id'; // Replace with actual user ID
      final financialData = await _accountService.getAggregatedBalances(userId);
      
      // Calculate tax estimate
      _taxEstimate = await _calculateTaxEstimate(financialData);
      
      // Get AI-suggested deductions
      _suggestedDeductions = await _aiService.generateTaxDeductions(
        userId,
        _taxEstimate['totalIncome'],
        _taxEstimate['incomeBreakdown'],
      );
      
      // Generate tax reminders
      _taxReminders = await _generateTaxReminders();
      
      // Generate document checklist
      _documentChecklist = await _generateDocumentChecklist();
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tax data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>> _calculateTaxEstimate(Map<String, dynamic> financialData) async {
    // Calculate total income from all sources
    final totalIncome = (financialData['totalIncome'] ?? 0.0) as double;
    final incomeBreakdown = financialData['incomeBreakdown'] ?? {};
    
    // Calculate taxable income after standard deduction
    const standardDeduction = 50000.0; // Example standard deduction
    final taxableIncome = totalIncome - standardDeduction;
    
    // Calculate tax based on income slabs
    double estimatedTax = 0.0;
    Map<String, double> taxBreakdown = {};
    
    if (taxableIncome <= 250000) {
      estimatedTax = 0;
      taxBreakdown['0%'] = taxableIncome;
    } else if (taxableIncome <= 500000) {
      estimatedTax = (taxableIncome - 250000) * 0.05;
      taxBreakdown['0%'] = 250000;
      taxBreakdown['5%'] = taxableIncome - 250000;
    } else if (taxableIncome <= 1000000) {
      estimatedTax = 12500 + (taxableIncome - 500000) * 0.2;
      taxBreakdown['0%'] = 250000;
      taxBreakdown['5%'] = 250000;
      taxBreakdown['20%'] = taxableIncome - 500000;
    } else {
      estimatedTax = 112500 + (taxableIncome - 1000000) * 0.3;
      taxBreakdown['0%'] = 250000;
      taxBreakdown['5%'] = 250000;
      taxBreakdown['20%'] = 500000;
      taxBreakdown['30%'] = taxableIncome - 1000000;
    }
    
    return {
      'totalIncome': totalIncome,
      'taxableIncome': taxableIncome,
      'estimatedTax': estimatedTax,
      'incomeBreakdown': incomeBreakdown,
      'taxBreakdown': taxBreakdown,
    };
  }

  Future<List<Map<String, dynamic>>> _generateTaxReminders() async {
    final now = DateTime.now();
    final reminders = <Map<String, dynamic>>[];
    
    // Add quarterly tax payment reminders for freelancers
    if (_selectedIncomeType == 'Freelance') {
      final quarters = [
        DateTime(now.year, 3, 31),
        DateTime(now.year, 6, 30),
        DateTime(now.year, 9, 30),
        DateTime(now.year, 12, 31),
      ];
      
      for (var quarter in quarters) {
        if (quarter.isAfter(now)) {
          reminders.add({
            'date': quarter,
            'type': 'quarterly_payment',
            'message': 'Quarterly tax payment due for Q${(quarter.month / 3).ceil()}',
            'amount': _taxEstimate['estimatedTax'] / 4,
          });
        }
      }
    }
    
    // Add annual tax filing reminder
    final filingDeadline = DateTime(now.year + 1, 7, 31);
    reminders.add({
      'date': filingDeadline,
      'type': 'annual_filing',
      'message': 'Annual tax return filing deadline',
      'amount': _taxEstimate['estimatedTax'],
    });
    
    // Sort reminders by date
    reminders.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    return reminders;
  }

  Future<List<Map<String, dynamic>>> _generateDocumentChecklist() async {
    final checklist = <Map<String, dynamic>>[];
    
    // Basic documents
    checklist.addAll([
      {
        'category': 'Income Documents',
        'items': [
          {'name': 'Form 16 (if employed)', 'required': _selectedIncomeType == 'Full-time'},
          {'name': 'Freelance income statements', 'required': _selectedIncomeType == 'Freelance'},
          {'name': 'Bank statements', 'required': true},
          {'name': 'Investment income statements', 'required': true},
        ],
      },
      {
        'category': 'Deduction Documents',
        'items': [
          {'name': 'Rent receipts', 'required': true},
          {'name': 'Medical bills', 'required': true},
          {'name': 'Education expense receipts', 'required': true},
          {'name': 'Investment proofs', 'required': true},
        ],
      },
      {
        'category': 'Additional Documents',
        'items': [
          {'name': 'Previous year\'s tax return', 'required': true},
          {'name': 'PAN card', 'required': true},
          {'name': 'Aadhaar card', 'required': true},
        ],
      },
    ]);
    
    // Add freelance-specific documents
    if (_selectedIncomeType == 'Freelance') {
      checklist.add({
        'category': 'Freelance Documents',
        'items': [
          {'name': 'Client invoices', 'required': true},
          {'name': 'Business expense receipts', 'required': true},
          {'name': 'Home office expense details', 'required': true},
        ],
      });
    }
    
    return checklist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MateTax'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTaxData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTaxData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaxEstimate(),
                      const SizedBox(height: 24),
                      _buildIncomeInput(),
                      const SizedBox(height: 24),
                      _buildDeductions(),
                      const SizedBox(height: 24),
                      _buildTaxReminders(),
                      const SizedBox(height: 24),
                      _buildDocumentChecklist(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTaxEstimate() {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Tax Estimate',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEstimateRow('Total Income', currencyFormat.format(_taxEstimate['totalIncome'])),
            _buildEstimateRow('Taxable Income', currencyFormat.format(_taxEstimate['taxableIncome'])),
            _buildEstimateRow('Estimated Tax', currencyFormat.format(_taxEstimate['estimatedTax'])),
            const Divider(),
            Text(
              'Tax Breakdown',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...(_taxEstimate['taxBreakdown'] as Map<String, double>).entries.map(
              (entry) => _buildEstimateRow('${entry.key} slab', currencyFormat.format(entry.value)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimateRow(String label, String value) {
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

  Widget _buildIncomeInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Income',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedIncomeType,
              decoration: const InputDecoration(
                labelText: 'Income Type',
                border: OutlineInputBorder(),
              ),
              items: ['Full-time', 'Part-time', 'Freelance'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIncomeType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _incomeController,
              decoration: const InputDecoration(
                labelText: 'Income Amount',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _expenseController,
              decoration: const InputDecoration(
                labelText: 'Expense Amount',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement income addition
                _loadTaxData();
              },
              child: const Text('Add Income'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.discount, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Deductions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'AI-Suggested Deductions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ..._suggestedDeductions.map((deduction) => ListTile(
              leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
              title: Text(deduction['category']),
              subtitle: Text(deduction['suggestion']),
              trailing: Text(
                '₹${deduction['estimatedAmount'].toStringAsFixed(2)}',
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

  Widget _buildTaxReminders() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Tax Reminders',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._taxReminders.map((reminder) => ListTile(
              leading: Icon(
                reminder['type'] == 'quarterly_payment' ? Icons.calendar_today : Icons.description,
                color: Colors.blue,
              ),
              title: Text(reminder['message']),
              subtitle: Text(
                DateFormat('MMM dd, yyyy').format(reminder['date']),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Text(
                '₹${reminder['amount'].toStringAsFixed(2)}',
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

  Widget _buildDocumentChecklist() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Document Checklist',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._documentChecklist.map((category) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['category'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...(category['items'] as List).map((item) => CheckboxListTile(
                  title: Text(item['name']),
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement checklist item toggle
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                )),
                const SizedBox(height: 8),
              ],
            )),
          ],
        ),
      ),
    );
  }
} 