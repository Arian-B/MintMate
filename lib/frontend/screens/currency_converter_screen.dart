import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _convertedAmount = 0;
  List<Map<String, dynamic>> _aiAlerts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    setState(() => _isLoading = true);
    try {
      // Mock exchange rate fetching
      await Future.delayed(const Duration(seconds: 1));
      _convertedAmount = double.parse(_amountController.text) * 0.85; // Mock conversion rate
      _generateAIAlerts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching exchange rates: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _generateAIAlerts() {
    final aiService = AIService();
    _aiAlerts = aiService.getCurrencyAlerts(_fromCurrency, _toCurrency, _convertedAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
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
                      'Convert Currency',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter an amount' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _fromCurrency,
                      items: ['USD', 'EUR', 'GBP', 'JPY', 'AUD'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _fromCurrency = newValue!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'From Currency'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _toCurrency,
                      items: ['USD', 'EUR', 'GBP', 'JPY', 'AUD'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _toCurrency = newValue!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'To Currency'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchExchangeRates,
                      child: const Text('Convert'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Converted Amount: ${_convertedAmount.toStringAsFixed(2)} $_toCurrency',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AI Alerts',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _aiAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = _aiAlerts[index];
                        return ListTile(
                          title: Text(alert['alert']),
                          subtitle: Text(alert['details']),
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