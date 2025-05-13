import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mintmate/backend/services/ai_service.dart';
import 'package:mintmate/backend/services/spending_service.dart';
import 'package:mintmate/backend/services/account_aggregation_service.dart';

class MateSaverScreen extends StatefulWidget {
  const MateSaverScreen({super.key});

  @override
  State<MateSaverScreen> createState() => _MateSaverScreenState();
}

class _MateSaverScreenState extends State<MateSaverScreen> {
  bool _isLoading = false;
  final _aiService = AIService();
  final _spendingService = SpendingService();
  final _accountService = AccountAggregationService();
  
  Map<String, dynamic> _savingsOpportunities = {};
  Map<String, dynamic> _spendingPredictions = {};
  List<Map<String, dynamic>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Get user's transactions and balances
      const userId = 'current_user_id'; // Replace with actual user ID
      final transactions = await _spendingService.getTransactions(userId);
      final rawBalances = await _accountService.getAggregatedBalances(userId);
      final balances = Map<String, double>.from(rawBalances);
      
      // Generate savings opportunities
      _savingsOpportunities = await _aiService.generateMicroSavingsOpportunities(
        userId,
        transactions,
        balances,
      );
      
      // Get spending predictions
      _spendingPredictions = await _aiService.predictFutureSpending(transactions);
      
      // Extract recommendations
      _recommendations = _savingsOpportunities['recommendations'] as List<Map<String, dynamic>>;
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MateSaver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSavingsOverview(),
                      const SizedBox(height: 24),
                      _buildSpendingPredictions(),
                      const SizedBox(height: 24),
                      _buildRecommendations(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSavingsOverview() {
    final totalPotential = _savingsOpportunities['total_potential_savings'] ?? 0.0;
    final opportunities = _savingsOpportunities['opportunities'] as List<Map<String, dynamic>>? ?? [];

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
                const Icon(Icons.savings, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Potential Monthly Savings',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '₹${totalPotential.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Savings Opportunities',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...opportunities.map((opp) => ListTile(
              leading: _getOpportunityIcon(opp['type']),
              title: Text(opp['description']),
              subtitle: Text('Estimated: ₹${opp['estimated_savings'].toStringAsFixed(2)}'),
              trailing: Chip(
                label: Text(opp['impact']),
                backgroundColor: _getImpactColor(opp['impact']),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingPredictions() {
    final predictions = _spendingPredictions['predictions'] as List<Map<String, dynamic>>? ?? [];
    final categoryTotals = _spendingPredictions['category_totals'] as Map<String, double>? ?? {};
    final confidence = _spendingPredictions['overall_confidence'] ?? 0.0;

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
                const Icon(Icons.trending_up, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Spending Predictions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}% confidence',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Category-wise Weekly Totals',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...categoryTotals.entries.map((entry) => ListTile(
              title: Text(entry.key),
              trailing: Text(
                '₹${entry.value.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
            const SizedBox(height: 16),
            Text(
              'Upcoming Predictions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...predictions.take(5).map((pred) => ListTile(
              title: Text(pred['category']),
              subtitle: Text(pred['date'].toString().split('T')[0]),
              trailing: Text(
                '₹${pred['predicted_amount'].toStringAsFixed(2)}',
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

  Widget _buildRecommendations() {
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
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Smart Recommendations',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._recommendations.map((rec) => ListTile(
              leading: _getRecommendationIcon(rec['type']),
              title: Text(rec['recommendation']),
              subtitle: Text('Implementation: ${rec['implementation']}'),
              trailing: Chip(
                label: Text('₹${rec['estimated_savings'].toStringAsFixed(2)}'),
                backgroundColor: Colors.green.withOpacity(0.2),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Icon _getOpportunityIcon(String type) {
    switch (type) {
      case 'round_up':
        return const Icon(Icons.arrow_upward, color: Colors.green);
      case 'smart_savings':
        return const Icon(Icons.schedule, color: Colors.blue);
      case 'subscription_optimization':
        return const Icon(Icons.subscriptions, color: Colors.orange);
      default:
        return const Icon(Icons.savings, color: Colors.grey);
    }
  }

  Icon _getRecommendationIcon(String type) {
    switch (type) {
      case 'round_up':
        return const Icon(Icons.arrow_upward, color: Colors.green);
      case 'smart_savings':
        return const Icon(Icons.schedule, color: Colors.blue);
      case 'subscription_optimization':
        return const Icon(Icons.subscriptions, color: Colors.orange);
      default:
        return const Icon(Icons.lightbulb_outline, color: Colors.amber);
    }
  }

  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'High':
        return Colors.red.withOpacity(0.2);
      case 'Medium':
        return Colors.orange.withOpacity(0.2);
      case 'Low':
        return Colors.green.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
} 