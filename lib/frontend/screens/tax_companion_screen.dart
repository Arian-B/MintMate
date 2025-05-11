import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class TaxCompanionScreen extends StatefulWidget {
  const TaxCompanionScreen({super.key});

  @override
  State<TaxCompanionScreen> createState() => _TaxCompanionScreenState();
}

class _TaxCompanionScreenState extends State<TaxCompanionScreen> {
  bool _isLoading = false;
  double _estimatedTax = 0;
  List<Map<String, dynamic>> _deductions = [];
  List<Map<String, dynamic>> _reminders = [];
  List<String> _documentChecklist = [];

  @override
  void initState() {
    super.initState();
    _loadTaxData();
  }

  Future<void> _loadTaxData() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading tax data
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _estimatedTax = 5000;
        _deductions = [
          {
            'category': 'Home Office',
            'suggestion': 'Consider claiming home office expenses for remote work.',
          },
          {
            'category': 'Education',
            'suggestion': 'Check if your education expenses qualify for deductions.',
          },
        ];
        _reminders = [
          {
            'date': '2023-12-31',
            'message': 'Quarterly tax payment due.',
          },
          {
            'date': '2024-01-31',
            'message': 'Annual tax return filing deadline.',
          },
        ];
        _documentChecklist = [
          'Income statements',
          'Expense receipts',
          'Investment statements',
          'Property tax documents',
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tax data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Companion'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Tax: ₹$_estimatedTax',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AI Deduction Suggestions',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _deductions.length,
                    itemBuilder: (context, index) {
                      final deduction = _deductions[index];
                      return ListTile(
                        title: Text(deduction['category']),
                        subtitle: Text(deduction['suggestion']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tax Reminders',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _reminders[index];
                      return ListTile(
                        title: Text(reminder['date']),
                        subtitle: Text(reminder['message']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Document Checklist',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _documentChecklist.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_documentChecklist[index]),
                        leading: const Icon(Icons.check_box_outline_blank),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadTaxData,
                    child: const Text('Refresh Tax Data'),
                  ),
                ],
              ),
            ),
    );
  }
} 