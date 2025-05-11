import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class InvestmentAdvisorScreen extends StatefulWidget {
  const InvestmentAdvisorScreen({super.key});

  @override
  State<InvestmentAdvisorScreen> createState() => _InvestmentAdvisorScreenState();
}

class _InvestmentAdvisorScreenState extends State<InvestmentAdvisorScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _recommendations = [];
  Map<String, dynamic> _portfolioAnalysis = {};
  String _riskAssessment = '';

  @override
  void initState() {
    super.initState();
    _loadInvestmentData();
  }

  Future<void> _loadInvestmentData() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading investment data
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _recommendations = [
          {
            'asset': 'Stocks',
            'suggestion': 'Consider diversifying your portfolio with index funds.',
          },
          {
            'asset': 'Bonds',
            'suggestion': 'Bonds can provide stability in volatile markets.',
          },
        ];
        _portfolioAnalysis = {
          'totalValue': 10000,
          'assetAllocation': {
            'Stocks': 60,
            'Bonds': 30,
            'Cash': 10,
          },
        };
        _riskAssessment = 'Moderate risk profile suitable for balanced growth.';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading investment data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Advisor'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portfolio Analysis',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Total Value: ₹${_portfolioAnalysis['totalValue']}'),
                  const SizedBox(height: 24),
                  Text(
                    'Asset Allocation',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _portfolioAnalysis['assetAllocation'].length,
                    itemBuilder: (context, index) {
                      final asset = _portfolioAnalysis['assetAllocation'].keys.elementAt(index);
                      final allocation = _portfolioAnalysis['assetAllocation'][asset];
                      return ListTile(
                        title: Text(asset),
                        subtitle: Text('$allocation%'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AI Investment Recommendations',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = _recommendations[index];
                      return ListTile(
                        title: Text(recommendation['asset']),
                        subtitle: Text(recommendation['suggestion']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Risk Assessment',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(_riskAssessment),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadInvestmentData,
                    child: const Text('Refresh Investment Data'),
                  ),
                ],
              ),
            ),
    );
  }
} 