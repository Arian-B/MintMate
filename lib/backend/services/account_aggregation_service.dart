import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mintmate/backend/services/platform_integration_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class AccountAggregationService {
  final PlatformIntegrationService _platformService;
  final AIService _aiService;
  final FirebaseFirestore _firestore;

  AccountAggregationService()
      : _platformService = PlatformIntegrationService(),
        _aiService = AIService(),
        _firestore = FirebaseFirestore.instance;

  // Get aggregated balances across all platforms
  Future<Map<String, dynamic>> getAggregatedBalances(String userId) async {
    try {
      final integrations = await _platformService.query(field: 'userId', isEqualTo: userId);
      
      double totalBalance = 0;
      Map<String, double> balancesByType = {};
      Map<String, double> balancesByPlatform = {};
      List<Map<String, dynamic>> recentTransactions = [];

      for (var integration in integrations) {
        final type = integration['type'] as String;
        final platform = integration['platform'] as String;
        final balance = _getBalanceFromIntegration(integration);
        
        // Aggregate by type
        balancesByType[type] = (balancesByType[type] ?? 0) + balance;
        
        // Aggregate by platform
        balancesByPlatform[platform] = (balancesByPlatform[platform] ?? 0) + balance;
        
        totalBalance += balance;

        // Collect recent transactions
        if (integration['transactions'] != null) {
          recentTransactions.addAll(
            (integration['transactions'] as List).cast<Map<String, dynamic>>(),
          );
        }
      }

      // Sort transactions by date
      recentTransactions.sort((a, b) {
        final aDate = a['timestamp'] as DateTime?;
        final bDate = b['timestamp'] as DateTime?;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      // Get AI insights
      final insights = await _generateAccountInsights(
        userId,
        balancesByType,
        balancesByPlatform,
        recentTransactions,
      );

      return {
        'totalBalance': totalBalance,
        'balancesByType': balancesByType,
        'balancesByPlatform': balancesByPlatform,
        'recentTransactions': recentTransactions.take(10).toList(),
        'insights': insights,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Error getting aggregated balances: $e');
    }
  }

  // Generate AI-powered insights about account activity
  Future<List<Map<String, dynamic>>> _generateAccountInsights(
    String userId,
    Map<String, double> balancesByType,
    Map<String, double> balancesByPlatform,
    List<Map<String, dynamic>> transactions,
  ) async {
    try {
      final insights = <Map<String, dynamic>>[];

      // Analyze income sources
      final incomeSources = _analyzeIncomeSources(transactions);
      if (incomeSources.isNotEmpty) {
        insights.add({
          'type': 'income_source',
          'message': 'Most of your income this month came from ${incomeSources.first['source']} (${incomeSources.first['percentage']}%)',
          'data': incomeSources,
        });
      }

      // Analyze spending patterns
      final spendingPatterns = _analyzeSpendingPatterns(transactions);
      if (spendingPatterns.isNotEmpty) {
        insights.add({
          'type': 'spending_pattern',
          'message': 'Your highest spending category is ${spendingPatterns.first['category']} (${spendingPatterns.first['percentage']}%)',
          'data': spendingPatterns,
        });
      }

      // Analyze balance distribution
      final balanceDistribution = _analyzeBalanceDistribution(balancesByType);
      insights.add({
        'type': 'balance_distribution',
        'message': 'Your assets are primarily in ${balanceDistribution.first['type']} (${balanceDistribution.first['percentage']}%)',
        'data': balanceDistribution,
      });

      // Get AI-generated insights
      final aiInsights = await _aiService.generateAccountInsights(
        userId,
        transactions,
        balancesByType,
        balancesByPlatform,
      );

      insights.addAll(aiInsights);

      return insights;
    } catch (e) {
      throw Exception('Error generating account insights: $e');
    }
  }

  double _getBalanceFromIntegration(Map<String, dynamic> integration) {
    switch (integration['type']) {
      case 'bank':
        return (integration['balance'] as num).toDouble();
      case 'crypto':
        if (integration['platform'] == 'coinbase') {
          final accounts = integration['accounts'] as List;
          return accounts.fold<double>(
            0,
            (sum, account) => sum + (account['balance']['amount'] as num).toDouble(),
          );
        } else if (integration['platform'] == 'binance') {
          final balances = integration['balances'] as List;
          return balances.fold<double>(
            0,
            (sum, balance) => sum + (balance['free'] as num).toDouble(),
          );
        }
        return 0;
      case 'stock':
        if (integration['platform'] == 'zerodha') {
          final portfolio = integration['portfolio'] as Map<String, dynamic>;
          return (portfolio['net'] as num).toDouble();
        }
        return 0;
      default:
        return 0;
    }
  }

  List<Map<String, dynamic>> _analyzeIncomeSources(List<Map<String, dynamic>> transactions) {
    final incomeBySource = <String, double>{};
    double totalIncome = 0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'income') {
        final source = transaction['source'] as String;
        final amount = (transaction['amount'] as num).toDouble();
        incomeBySource[source] = (incomeBySource[source] ?? 0) + amount;
        totalIncome += amount;
      }
    }

    return incomeBySource.entries
        .map((e) => {
              'source': e.key,
              'amount': e.value,
              'percentage': (e.value / totalIncome * 100).round(),
            })
        .toList()
      ..sort((a, b) {
        final aPercent = a['percentage'] as num;
        final bPercent = b['percentage'] as num;
        return bPercent.compareTo(aPercent);
      });
  }

  List<Map<String, dynamic>> _analyzeSpendingPatterns(List<Map<String, dynamic>> transactions) {
    final spendingByCategory = <String, double>{};
    double totalSpending = 0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'expense') {
        final category = transaction['category'] as String;
        final amount = (transaction['amount'] as num).toDouble();
        spendingByCategory[category] = (spendingByCategory[category] ?? 0) + amount;
        totalSpending += amount;
      }
    }

    return spendingByCategory.entries
        .map((e) => {
              'category': e.key,
              'amount': e.value,
              'percentage': (e.value / totalSpending * 100).round(),
            })
        .toList()
      ..sort((a, b) {
        final aPercent = a['percentage'] as num;
        final bPercent = b['percentage'] as num;
        return bPercent.compareTo(aPercent);
      });
  }

  List<Map<String, dynamic>> _analyzeBalanceDistribution(Map<String, double> balancesByType) {
    final total = balancesByType.values.fold<double>(0, (sum, balance) => sum + balance);
    
    return balancesByType.entries
        .map((e) => {
              'type': e.key,
              'amount': e.value,
              'percentage': (e.value / total * 100).round(),
            })
        .toList()
      ..sort((a, b) {
        final aPercent = a['percentage'] as num;
        final bPercent = b['percentage'] as num;
        return bPercent.compareTo(aPercent);
      });
  }

  // Watch for real-time updates
  Stream<Map<String, dynamic>> watchAggregatedBalances(String userId) {
    return _firestore
        .collection('account_aggregations')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }
} 