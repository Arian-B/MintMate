import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class InvestmentForecastScreen extends StatefulWidget {
  const InvestmentForecastScreen({super.key});

  @override
  State<InvestmentForecastScreen> createState() => _InvestmentForecastScreenState();
}

class _InvestmentForecastScreenState extends State<InvestmentForecastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyAmountController = TextEditingController(text: '500');
  final _yearsController = TextEditingController(text: '5');
  String _selectedRiskProfile = 'Moderate';
  bool _isLoading = false;
  Map<String, dynamic> _forecastData = {};
  List<FlSpot> _forecastPoints = [];
  final _aiService = AIService();

  @override
  void initState() {
    super.initState();
    _generateForecast();
  }

  Future<void> _generateForecast() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final monthlyAmount = double.parse(_monthlyAmountController.text);
      final years = int.parse(_yearsController.text);
      
      // Get forecast from AI service
      final forecast = await _aiService.generateInvestmentForecast(
        monthlyAmount: monthlyAmount,
        years: years,
        riskProfile: _selectedRiskProfile,
      );

      // Generate chart points
      _forecastPoints = [];
      for (int i = 0; i < forecast['monthlyTotals'].length; i++) {
        _forecastPoints.add(FlSpot(i.toDouble(), forecast['monthlyTotals'][i]));
      }

      setState(() {
        _forecastData = forecast;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating forecast: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Forecast'),
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
                      'AI Investment Forecast',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _monthlyAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Monthly Investment Amount (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yearsController,
                      decoration: const InputDecoration(
                        labelText: 'Investment Period (Years)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of years';
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
                      onPressed: _generateForecast,
                      child: const Text('Generate Forecast'),
                    ),
                    if (_forecastData.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildForecastSummary(),
                      const SizedBox(height: 24),
                      _buildForecastChart(),
                      const SizedBox(height: 24),
                      _buildInvestmentBreakdown(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildForecastSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forecast Summary',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Total Investment', '₹${_forecastData['totalInvestment'].toStringAsFixed(2)}'),
            _buildSummaryRow('Final Amount', '₹${_forecastData['finalAmount'].toStringAsFixed(2)}'),
            _buildSummaryRow('Total Return', '₹${_forecastData['totalReturn'].toStringAsFixed(2)}'),
            _buildSummaryRow('Annual Return Rate', '${(_forecastData['annualRate'] * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Growth',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${(value / 1000).toStringAsFixed(0)}K',
                            style: GoogleFonts.poppins(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 12).toStringAsFixed(0)}Y',
                            style: GoogleFonts.poppins(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _forecastPoints,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Breakdown',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownRow('Monthly Contribution', '₹${_forecastData['monthlyContributions'][0].toStringAsFixed(2)}'),
            _buildBreakdownRow('Average Monthly Return', '₹${(_forecastData['monthlyReturns'].reduce((a, b) => a + b) / _forecastData['monthlyReturns'].length).toStringAsFixed(2)}'),
            _buildBreakdownRow('Total Monthly Growth', '₹${_forecastData['monthlyTotals'][0].toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _monthlyAmountController.dispose();
    _yearsController.dispose();
    super.dispose();
  }
} 