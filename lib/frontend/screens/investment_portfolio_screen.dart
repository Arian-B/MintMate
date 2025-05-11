import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class InvestmentPortfolioScreen extends StatefulWidget {
  const InvestmentPortfolioScreen({super.key});

  @override
  State<InvestmentPortfolioScreen> createState() => _InvestmentPortfolioScreenState();
}

class _InvestmentPortfolioScreenState extends State<InvestmentPortfolioScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _investmentRecommendations = [];
  Map<String, dynamic> _portfolioPerformance = {};
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
        _investmentRecommendations = [
          {
            'asset': 'Stocks',
            'recommendation': 'Consider diversifying into tech stocks.',
          },
          {
            'asset': 'Bonds',
            'recommendation': 'Bonds are stable; maintain current allocation.',
          },
          {
            'asset': 'Real Estate',
            'recommendation': 'Real estate investments show good potential.',
          },
        ];
        _portfolioPerformance = {
          'totalValue': 100000,
          'assetAllocation': {
            'Stocks': 60000,
            'Bonds': 30000,
            'Real Estate': 10000,
          },
        };
        _riskAssessment = 'Your portfolio is moderately risky. Consider increasing bond allocation for stability.';
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
        title: const Text('Investment Portfolio'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Investment Recommendations',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _investmentRecommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = _investmentRecommendations[index];
                      return ListTile(
                        title: Text(recommendation['asset']),
                        subtitle: Text(recommendation['recommendation']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Portfolio Performance',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text('Total Value: ₹${_portfolioPerformance['totalValue']}'),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _portfolioPerformance['assetAllocation'].length,
                    itemBuilder: (context, index) {
                      final asset = _portfolioPerformance['assetAllocation'].keys.elementAt(index);
                      final value = _portfolioPerformance['assetAllocation'][asset];
                      return ListTile(
                        title: Text(asset),
                        subtitle: Text('₹$value'),
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