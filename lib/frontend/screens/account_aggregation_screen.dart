import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/account_aggregation_service.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:intl/intl.dart';

class AccountAggregationScreen extends StatefulWidget {
  const AccountAggregationScreen({super.key});

  @override
  State<AccountAggregationScreen> createState() => _AccountAggregationScreenState();
}

class _AccountAggregationScreenState extends State<AccountAggregationScreen> {
  final _accountService = AccountAggregationService();
  bool _isLoading = true;
  Map<String, dynamic> _aggregatedData = {};
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _loadAggregatedData();
  }

  Future<void> _loadAggregatedData() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        final data = await _accountService.getAggregatedBalances(userId);
        setState(() {
          _aggregatedData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading account data: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAggregatedData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAggregatedData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalBalance(),
                    const SizedBox(height: 24),
                    _buildBalanceBreakdown(),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(),
                    const SizedBox(height: 24),
                    _buildInsights(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTotalBalance() {
    final totalBalance = _aggregatedData['totalBalance'] as double? ?? 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currencyFormat.format(totalBalance),
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateFormat('MMM d, y HH:mm').format(_aggregatedData['lastUpdated'] as DateTime? ?? DateTime.now())}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceBreakdown() {
    final balancesByType = _aggregatedData['balancesByType'] as Map<String, double>? ?? {};
    final balancesByPlatform = _aggregatedData['balancesByPlatform'] as Map<String, double>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balance Breakdown',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By Type',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...balancesByType.entries.map((e) => _buildBalanceRow(e.key, e.value)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By Platform',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...balancesByPlatform.entries.map((e) => _buildBalanceRow(e.key, e.value)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            _currencyFormat.format(amount),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = _aggregatedData['recentTransactions'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index] as Map<String, dynamic>;
              return ListTile(
                title: Text(transaction['description'] as String? ?? 'Unknown'),
                subtitle: Text(
                  DateFormat('MMM d, y').format(transaction['timestamp'] as DateTime? ?? DateTime.now()),
                ),
                trailing: Text(
                  _currencyFormat.format(transaction['amount'] as num? ?? 0),
                  style: TextStyle(
                    color: (transaction['type'] as String? ?? '') == 'income'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    final insights = _aggregatedData['insights'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Insights',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => _buildInsightCard(insight as Map<String, dynamic>)),
      ],
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getInsightIcon(insight['type'] as String? ?? ''),
                  color: _getInsightColor(insight['type'] as String? ?? ''),
                ),
                const SizedBox(width: 8),
                Text(
                  _getInsightTitle(insight['type'] as String? ?? ''),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              insight['message'] as String? ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getInsightIcon(String type) {
    switch (type) {
      case 'income_source':
        return Icons.attach_money;
      case 'spending_pattern':
        return Icons.shopping_cart;
      case 'balance_distribution':
        return Icons.pie_chart;
      case 'transaction_pattern':
        return Icons.timeline;
      case 'balance_trend':
        return Icons.trending_up;
      case 'recommendation':
        return Icons.lightbulb;
      default:
        return Icons.info;
    }
  }

  Color _getInsightColor(String type) {
    switch (type) {
      case 'income_source':
        return Colors.green;
      case 'spending_pattern':
        return Colors.orange;
      case 'balance_distribution':
        return Colors.blue;
      case 'transaction_pattern':
        return Colors.purple;
      case 'balance_trend':
        return Colors.teal;
      case 'recommendation':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getInsightTitle(String type) {
    switch (type) {
      case 'income_source':
        return 'Income Analysis';
      case 'spending_pattern':
        return 'Spending Pattern';
      case 'balance_distribution':
        return 'Balance Distribution';
      case 'transaction_pattern':
        return 'Transaction Pattern';
      case 'balance_trend':
        return 'Balance Trend';
      case 'recommendation':
        return 'Recommendation';
      default:
        return 'Insight';
    }
  }
} 