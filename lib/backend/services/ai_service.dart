import 'package:mintmate/backend/services/base_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class AIService extends BaseService {
  AIService() : super(FirebaseFirestore.instance, 'ai_insights');

  @override
  Map<String, dynamic> fromFirestore(DocumentSnapshot doc) {
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> toFirestore(dynamic model) {
    return model as Map<String, dynamic>;
  }

  String categorizeExpense(String description, double amount) {
    // Simple rule-based categorization
    description = description.toLowerCase();
    
    if (description.contains('food') || 
        description.contains('restaurant') || 
        description.contains('cafe')) {
      return 'Food & Dining';
    }
    
    if (description.contains('transport') || 
        description.contains('uber') || 
        description.contains('taxi')) {
      return 'Transportation';
    }
    
    if (description.contains('rent') || 
        description.contains('mortgage') || 
        description.contains('housing')) {
      return 'Housing';
    }
    
    if (description.contains('movie') || 
        description.contains('entertainment') || 
        description.contains('game')) {
      return 'Entertainment';
    }
    
    if (description.contains('medical') || 
        description.contains('health') || 
        description.contains('pharmacy')) {
      return 'Healthcare';
    }
    
    // Default category
    return 'Other';
  }

  Future<Map<String, double>> getBudgetRecommendations(List<Map<String, dynamic>> expenses) async {
    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      final category = expense['category'] as String;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + (expense['amount'] as double);
    }
    
    // Calculate recommended budget limits based on spending patterns
    final Map<String, double> recommendations = {};
    for (var entry in categoryTotals.entries) {
      final category = entry.key;
      final spent = entry.value;
      
      // Adjust budget based on category importance and spending patterns
      double recommendedBudget;
      switch (category) {
        case 'Food & Dining':
          recommendedBudget = spent * 1.2; // Allow 20% more than current spending
          break;
        case 'Housing':
          recommendedBudget = spent * 1.1; // Keep housing budget stable
          break;
        case 'Transportation':
          recommendedBudget = spent * 1.15; // Allow 15% more for transportation
          break;
        case 'Entertainment':
          recommendedBudget = spent * 1.3; // Allow 30% more for entertainment
          break;
        case 'Healthcare':
          recommendedBudget = spent * 1.25; // Allow 25% more for healthcare
          break;
        case 'Education':
          recommendedBudget = spent * 1.2; // Allow 20% more for education
          break;
        case 'Shopping':
          recommendedBudget = spent * 1.15; // Allow 15% more for shopping
          break;
        case 'Utilities':
          recommendedBudget = spent * 1.1; // Keep utilities budget stable
          break;
        default:
          recommendedBudget = spent * 1.2; // Default 20% increase
      }
      
      recommendations[category] = recommendedBudget;
    }
    
    return recommendations;
  }

  Map<String, dynamic> analyzeSpendingPatterns(List<Map<String, dynamic>> expenses) {
    // Calculate total spending
    double totalSpending = expenses.fold(0, (sum, expense) => sum + expense['amount']);
    
    // Calculate category-wise spending
    Map<String, double> categorySpending = {};
    for (var expense in expenses) {
      String category = expense['category'];
      categorySpending[category] = (categorySpending[category] ?? 0) + expense['amount'];
    }
    
    // Calculate percentage for each category
    Map<String, double> categoryPercentages = {};
    categorySpending.forEach((category, amount) {
      categoryPercentages[category] = (amount / totalSpending) * 100;
    });
    
    return {
      'totalSpending': totalSpending,
      'categorySpending': categorySpending,
      'categoryPercentages': categoryPercentages,
    };
  }

  Future<Map<String, double>> getSavingsRecommendations(List<Map<String, dynamic>> expenses) async {
    // Calculate total monthly spending
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + (e['amount'] as double));
    
    // Calculate recommended savings based on spending patterns
    final Map<String, double> recommendations = {
      'Emergency Fund': totalSpent * 3, // 3 months of expenses
      'Short-term Goals': totalSpent * 0.5, // 50% of monthly expenses
      'Long-term Goals': totalSpent * 0.3, // 30% of monthly expenses
      'Investment Fund': totalSpent * 0.2, // 20% of monthly expenses
    };
    
    // Adjust recommendations based on spending patterns
    final analysis = analyzeSpendingPatterns(expenses);
    final categoryPercentages = analysis['categoryPercentages'] as Map<String, double>;
    
    // Increase emergency fund if high spending on essential categories
    if ((categoryPercentages['Housing'] ?? 0) > 40 ||
        (categoryPercentages['Healthcare'] ?? 0) > 20) {
      recommendations['Emergency Fund'] = (recommendations['Emergency Fund'] ?? 0) * 1.2; // Increase by 20%
    }
    
    // Adjust investment fund based on spending patterns
    if ((categoryPercentages['Entertainment'] ?? 0) > 30 ||
        (categoryPercentages['Shopping'] ?? 0) > 25) {
      recommendations['Investment Fund'] = (recommendations['Investment Fund'] ?? 0) * 0.8; // Decrease by 20%
      recommendations['Short-term Goals'] = (recommendations['Short-term Goals'] ?? 0) * 1.2; // Increase by 20%
    }
    
    return recommendations;
  }

  List<Map<String, dynamic>> getLoanSuggestions(double loanAmount, double interestRate, int loanTerm) {
    // Mock AI suggestions for now
    return [
      {
        'suggestion': 'Consider increasing your EMI to reduce total interest.',
        'details': 'Increasing your EMI by 10% can save you ₹${(loanAmount * 0.1).toStringAsFixed(2)} in interest.',
      },
      {
        'suggestion': 'Prepay a portion of your loan to reduce the loan term.',
        'details': 'Prepaying 20% of your loan can reduce your loan term by ${(loanTerm * 0.2).toStringAsFixed(0)} months.',
      },
    ];
  }

  List<Map<String, dynamic>> getCurrencyAlerts(String fromCurrency, String toCurrency, double convertedAmount) {
    // Mock AI alerts for now
    return [
      {
        'alert': 'Exchange Rate Alert',
        'details': 'The exchange rate for $fromCurrency to $toCurrency is favorable. Consider converting now to save on fees.',
      },
      {
        'alert': 'Travel Expense Optimization',
        'details': 'For travel expenses, consider using a travel card to avoid high conversion fees.',
      },
    ];
  }

  List<Map<String, dynamic>> getExpenseInsights(List<Map<String, dynamic>> expenseData) {
    // Mock AI insights for now
    return [
      {
        'category': 'Food & Dining',
        'insight': 'Consider reducing dining out expenses to save more.',
      },
      {
        'category': 'Transportation',
        'insight': 'Your transportation costs are within the expected range.',
      },
      {
        'category': 'Housing',
        'insight': 'Housing expenses are high; consider refinancing options.',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> generateTaxDeductions(
    String userId,
    double totalIncome,
    Map<String, dynamic> incomeBreakdown,
  ) async {
    try {
      final deductions = <Map<String, dynamic>>[];
      
      // Standard deductions
      deductions.addAll([
        {
          'category': 'Home Office',
          'suggestion': 'Claim 5% of your total income as home office expenses',
          'estimatedAmount': totalIncome * 0.05,
        },
        {
          'category': 'Education',
          'suggestion': 'Claim education loan interest up to ₹15,000',
          'estimatedAmount': 15000.0,
        },
        {
          'category': 'Medical',
          'suggestion': 'Claim medical insurance premium up to ₹25,000',
          'estimatedAmount': 25000.0,
        },
      ]);

      // Income-specific deductions
      if (incomeBreakdown['freelance'] != null) {
        deductions.add({
          'category': 'Business Expenses',
          'suggestion': 'Claim 30% of freelance income as business expenses',
          'estimatedAmount': (incomeBreakdown['freelance'] as double) * 0.3,
        });
      }

      if (incomeBreakdown['rental'] != null) {
        deductions.add({
          'category': 'Property Tax',
          'suggestion': 'Claim 30% of rental income as standard deduction',
          'estimatedAmount': (incomeBreakdown['rental'] as double) * 0.3,
        });
      }

      if (totalIncome > 500000) {
        deductions.add({
          'category': 'Investment Deductions',
          'suggestion': 'Invest in tax-saving instruments under Section 80C',
          'estimatedAmount': 150000.0,
        });
      }

      return deductions;
    } catch (e) {
      throw Exception('Error generating tax deductions: $e');
    }
  }

  // Generate spending insights
  Future<Map<String, dynamic>> generateSpendingInsights(String userId) async {
    try {
      // Get user's transaction history
      final transactions = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      // Prepare data for AI analysis
      final transactionData = transactions.docs.map((doc) => doc.data()).toList();

      // Call AI service for analysis
      final response = await http.post(
        Uri.parse('https://api.ai-service.com/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'transactions': transactionData,
        }),
      );

      if (response.statusCode == 200) {
        final insights = jsonDecode(response.body);
        await create({
          'userId': userId,
          'type': 'spending_insights',
          'insights': insights,
          'timestamp': DateTime.now(),
        });
        return insights;
      } else {
        throw Exception('Failed to generate spending insights');
      }
    } catch (e) {
      throw Exception('Error generating spending insights: $e');
    }
  }

  // Generate investment recommendations
  Future<Map<String, dynamic>> generateInvestmentRecommendations(
    String userId,
    Map<String, dynamic> userProfile,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ai-service.com/investment-recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'profile': userProfile,
        }),
      );

      if (response.statusCode == 200) {
        final recommendations = jsonDecode(response.body);
        await create({
          'userId': userId,
          'type': 'investment_recommendations',
          'recommendations': recommendations,
          'timestamp': DateTime.now(),
        });
        return recommendations;
      } else {
        throw Exception('Failed to generate investment recommendations');
      }
    } catch (e) {
      throw Exception('Error generating investment recommendations: $e');
    }
  }

  // Analyze contracts
  Future<Map<String, dynamic>> analyzeContract(String contractText) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ai-service.com/analyze-contract'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contractText': contractText,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze contract');
      }
    } catch (e) {
      throw Exception('Error analyzing contract: $e');
    }
  }

  // Generate financial tips
  Future<List<Map<String, dynamic>>> generateFinancialTips(
    String userId,
    Map<String, dynamic> userContext,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ai-service.com/financial-tips'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'context': userContext,
        }),
      );

      if (response.statusCode == 200) {
        final tips = jsonDecode(response.body);
        await create({
          'userId': userId,
          'type': 'financial_tips',
          'tips': tips,
          'timestamp': DateTime.now(),
        });
        return List<Map<String, dynamic>>.from(tips);
      } else {
        throw Exception('Failed to generate financial tips');
      }
    } catch (e) {
      throw Exception('Error generating financial tips: $e');
    }
  }

  // Analyze credit health
  Future<Map<String, dynamic>> analyzeCreditHealth(
    String userId,
    Map<String, dynamic> creditData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ai-service.com/credit-health'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'creditData': creditData,
        }),
      );

      if (response.statusCode == 200) {
        final analysis = jsonDecode(response.body);
        await create({
          'userId': userId,
          'type': 'credit_health',
          'analysis': analysis,
          'timestamp': DateTime.now(),
        });
        return analysis;
      } else {
        throw Exception('Failed to analyze credit health');
      }
    } catch (e) {
      throw Exception('Error analyzing credit health: $e');
    }
  }

  // Generate tax recommendations
  Future<Map<String, dynamic>> generateTaxRecommendations(
    String userId,
    Map<String, dynamic> financialData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ai-service.com/tax-recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'financialData': financialData,
        }),
      );

      if (response.statusCode == 200) {
        final recommendations = jsonDecode(response.body);
        await create({
          'userId': userId,
          'type': 'tax_recommendations',
          'recommendations': recommendations,
          'timestamp': DateTime.now(),
        });
        return recommendations;
      } else {
        throw Exception('Failed to generate tax recommendations');
      }
    } catch (e) {
      throw Exception('Error generating tax recommendations: $e');
    }
  }

  Future<String> generateDailyTip(String userId) async {
    try {
      // Get user's financial profile and recent activities
      final userProfile = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      final recentExpenses = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      // Prepare context for AI
      final context = {
        'spendingPatterns': _analyzeSpendingPatterns(recentExpenses.docs.map((doc) => doc.data()).toList()),
        'financialGoals': userProfile.data()?['goals'] ?? [],
        'savingsRate': userProfile.data()?['savingsRate'] ?? 0.0,
        'riskProfile': userProfile.data()?['riskProfile'] ?? 'moderate',
      };

      // Generate personalized tip based on context
      String tip = '';
      if (context['spendingPatterns']['hasOverspending']) {
        tip = "I notice you've been spending more than usual on ${context['spendingPatterns']['highestCategory']}. "
            "Consider setting a weekly budget for this category to stay on track with your goals.";
      } else if (context['savingsRate'] < 0.2) {
        tip = "Your savings rate is below the recommended 20%. "
            "Try the 50/30/20 rule: 50% for needs, 30% for wants, and 20% for savings.";
      } else if (context['financialGoals'].isEmpty) {
        tip = "You haven't set any financial goals yet. "
            "Setting clear goals can help you stay motivated and track your progress!";
      } else {
        // Default tips based on user's risk profile
        switch (context['riskProfile']) {
          case 'conservative':
            tip = "As a conservative investor, consider diversifying your portfolio with index funds "
                "for steady, long-term growth.";
            break;
          case 'moderate':
            tip = "Your balanced approach to investing is great! "
                "Consider reviewing your portfolio quarterly to maintain your desired risk level.";
            break;
          case 'aggressive':
            tip = "While you're comfortable with higher risk, remember to maintain an emergency fund "
                "of 3-6 months' expenses for unexpected situations.";
            break;
          default:
            tip = "Remember to review your budget regularly and adjust it based on your changing needs "
                "and financial goals.";
        }
      }

      // Log the tip
      await create({
        'userId': userId,
        'type': 'daily_tip',
        'tip': tip,
        'context': context,
        'timestamp': DateTime.now(),
      });

      return tip;
    } catch (e) {
      throw Exception('Error generating daily tip: $e');
    }
  }

  Map<String, dynamic> _analyzeSpendingPatterns(List<Map<String, dynamic>> expenses) {
    final categoryTotals = <String, double>{};
    double totalSpent = 0;

    for (var expense in expenses) {
      final category = expense['category'] as String;
      final amount = expense['amount'] as double;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      totalSpent += amount;
    }

    String highestCategory = '';
    double highestAmount = 0;
    bool hasOverspending = false;

    categoryTotals.forEach((category, amount) {
      if (amount > highestAmount) {
        highestAmount = amount;
        highestCategory = category;
      }
      // Consider overspending if any category exceeds 40% of total
      if (amount / totalSpent > 0.4) {
        hasOverspending = true;
      }
    });

    return {
      'highestCategory': highestCategory,
      'hasOverspending': hasOverspending,
      'categoryPercentages': categoryTotals.map(
        (category, amount) => MapEntry(category, amount / totalSpent),
      ),
    };
  }

  // Generate AI-powered insights about account activity
  Future<List<Map<String, dynamic>>> generateAccountInsights(
    String userId,
    List<Map<String, dynamic>> transactions,
    Map<String, double> balancesByType,
    Map<String, double> balancesByPlatform,
  ) async {
    try {
      final insights = <Map<String, dynamic>>[];

      // Analyze transaction patterns
      final transactionPatterns = await _analyzeTransactionPatterns(transactions);
      insights.addAll(transactionPatterns);

      // Analyze balance trends
      final balanceTrends = await _analyzeBalanceTrends(balancesByType, balancesByPlatform);
      insights.addAll(balanceTrends);

      // Generate personalized recommendations
      final recommendations = await _generateRecommendations(
        userId,
        transactions,
        balancesByType,
        balancesByPlatform,
      );
      insights.addAll(recommendations);

      return insights;
    } catch (e) {
      throw Exception('Error generating account insights: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _analyzeTransactionPatterns(
    List<Map<String, dynamic>> transactions,
  ) async {
    final insights = <Map<String, dynamic>>[];

    // Group transactions by day of week
    final transactionsByDay = <String, List<Map<String, dynamic>>>{};
    for (var transaction in transactions) {
      final date = transaction['timestamp'] as DateTime;
      final day = date.weekday.toString();
      transactionsByDay[day] = [...(transactionsByDay[day] ?? []), transaction];
    }

    // Find busiest transaction day
    final busiestDay = transactionsByDay.entries
        .reduce((a, b) => a.value.length > b.value.length ? a : b);
    
    if (busiestDay.value.isNotEmpty) {
      insights.add({
        'type': 'transaction_pattern',
        'message': 'Most of your transactions occur on ${_getDayName(int.parse(busiestDay.key))}',
        'data': {
          'day': busiestDay.key,
          'count': busiestDay.value.length,
        },
      });
    }

    return insights;
  }

  Future<List<Map<String, dynamic>>> _analyzeBalanceTrends(
    Map<String, double> balancesByType,
    Map<String, double> balancesByPlatform,
  ) async {
    final insights = <Map<String, dynamic>>[];

    // Analyze platform distribution
    final totalBalance = balancesByPlatform.values.fold<double>(0, (sum, balance) => sum + balance);
    if (totalBalance > 0) {
      final dominantPlatform = balancesByPlatform.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add({
        'type': 'balance_trend',
        'message': 'Your largest balance is in ${dominantPlatform.key} (${(dominantPlatform.value / totalBalance * 100).round()}%)',
        'data': {
          'platform': dominantPlatform.key,
          'percentage': (dominantPlatform.value / totalBalance * 100).round(),
        },
      });
    }

    return insights;
  }

  Future<List<Map<String, dynamic>>> _generateRecommendations(
    String userId,
    List<Map<String, dynamic>> transactions,
    Map<String, double> balancesByType,
    Map<String, double> balancesByPlatform,
  ) async {
    final recommendations = <Map<String, dynamic>>[];

    // Analyze spending vs income
    double totalIncome = 0;
    double totalSpending = 0;
    for (var transaction in transactions) {
      if (transaction['type'] == 'income') {
        totalIncome += (transaction['amount'] as num).toDouble();
      } else if (transaction['type'] == 'expense') {
        totalSpending += (transaction['amount'] as num).toDouble();
      }
    }

    if (totalIncome > 0) {
      final savingsRate = (totalIncome - totalSpending) / totalIncome;
      if (savingsRate < 0.2) {
        recommendations.add({
          'type': 'recommendation',
          'message': 'Consider increasing your savings rate. Currently at ${(savingsRate * 100).round()}%',
          'data': {
            'currentRate': savingsRate,
            'targetRate': 0.2,
          },
        });
      }
    }

    // Analyze investment distribution
    if (balancesByType.containsKey('stock') && balancesByType.containsKey('crypto')) {
      final stockPercentage = balancesByType['stock']! / 
          (balancesByType['stock']! + balancesByType['crypto']!);
      
      if (stockPercentage < 0.4) {
        recommendations.add({
          'type': 'recommendation',
          'message': 'Consider diversifying more into stocks. Currently ${(stockPercentage * 100).round()}% in stocks',
          'data': {
            'currentPercentage': stockPercentage,
            'targetPercentage': 0.4,
          },
        });
      }
    }

    return recommendations;
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }

  Future<Map<String, dynamic>> getLearningProgress(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('learning_progress')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data() ?? {
          'completedLessons': 0,
          'totalLessons': 0,
          'streak': 0,
          'badges': [],
        };
      }

      return {
        'completedLessons': 0,
        'totalLessons': 0,
        'streak': 0,
        'badges': [],
      };
    } catch (e) {
      throw Exception('Error getting learning progress: $e');
    }
  }

  Future<String> askFinancialQuestion(String userId, String question) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ai-service.com/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'question': question,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] as String;
      } else {
        throw Exception('Failed to get answer');
      }
    } catch (e) {
      throw Exception('Error asking financial question: $e');
    }
  }

  Future<void> completeLesson(String userId, String lessonId) async {
    try {
      await FirebaseFirestore.instance
          .collection('learning_progress')
          .doc(userId)
          .update({
        'completedLessons': FieldValue.increment(1),
        'completedLessonIds': FieldValue.arrayUnion([lessonId]),
        'lastCompletedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Error completing lesson: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFinancialLessons(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('financial_lessons')
          .get();

      final userProgress = await getLearningProgress(userId);
      final completedIds = List<String>.from(userProgress['completedLessonIds'] ?? []);

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'completed': completedIds.contains(doc.id),
        };
      }).toList();
    } catch (e) {
      throw Exception('Error getting financial lessons: $e');
    }
  }

  // MateSaver: Smart micro-savings feature
  Future<Map<String, dynamic>> generateMicroSavingsOpportunities(
    String userId,
    List<Map<String, dynamic>> transactions,
    Map<String, double> balances,
  ) async {
    try {
      final opportunities = <Map<String, dynamic>>[];
      final spendingPatterns = analyzeSpendingPatterns(transactions);
      final categoryPercentages = spendingPatterns['categoryPercentages'] as Map<String, double>;
      
      // Analyze discretionary spending categories
      final discretionaryCategories = ['Entertainment', 'Shopping', 'Food & Dining'];
      double totalDiscretionary = 0;
      
      for (var category in discretionaryCategories) {
        totalDiscretionary += categoryPercentages[category] ?? 0;
      }
      
      // Generate micro-savings opportunities
      if (totalDiscretionary > 30) { // If discretionary spending is high
        opportunities.add({
          'type': 'round_up',
          'description': 'Round up purchases to nearest ₹10',
          'estimated_savings': 500.0, // Example amount
          'impact': 'Low',
          'implementation': 'automatic',
        });
      }
      
      // Analyze spending patterns for smart savings
      final dailySpending = <DateTime, double>{};
      for (var transaction in transactions) {
        final date = transaction['date'] as DateTime;
        final day = DateTime(date.year, date.month, date.day);
        dailySpending[day] = (dailySpending[day] ?? 0) + (transaction['amount'] as double);
      }
      
      // Find days with lowest spending
      final sortedDays = dailySpending.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      if (sortedDays.isNotEmpty) {
        final lowestSpendingDay = sortedDays.first;
        opportunities.add({
          'type': 'smart_savings',
          'description': 'Save extra on ${_getDayName(lowestSpendingDay.key.weekday)}',
          'estimated_savings': lowestSpendingDay.value * 0.2, // Save 20% of lowest spending day
          'impact': 'Medium',
          'implementation': 'scheduled',
        });
      }
      
      // Analyze subscription patterns
      final subscriptions = transactions.where((t) => 
        t['category'] == 'Subscription' && t['isRecurring'] == true).toList();
      
      if (subscriptions.isNotEmpty) {
        final totalSubscriptions = subscriptions.fold<double>(
          0, (sum, sub) => sum + (sub['amount'] as double));
        
        opportunities.add({
          'type': 'subscription_optimization',
          'description': 'Review and optimize subscriptions',
          'estimated_savings': totalSubscriptions * 0.15, // Potential 15% savings
          'impact': 'High',
          'implementation': 'manual',
        });
      }
      
      return {
        'opportunities': opportunities,
        'total_potential_savings': opportunities.fold<double>(
          0, (sum, opp) => sum + (opp['estimated_savings'] as double)),
        'recommendations': _generateSavingsRecommendations(opportunities),
      };
    } catch (e) {
      throw Exception('Error generating micro-savings opportunities: $e');
    }
  }

  // Enhanced spending prediction
  Future<Map<String, dynamic>> predictFutureSpending(
    List<Map<String, dynamic>> transactions,
    {int daysAhead = 30}
  ) async {
    try {
      // Group transactions by category and day of week
      final categoryByDay = <String, Map<int, List<double>>>{};
      
      for (var transaction in transactions) {
        final category = transaction['category'] as String;
        final date = transaction['date'] as DateTime;
        final dayOfWeek = date.weekday;
        final amount = transaction['amount'] as double;
        
        categoryByDay[category] ??= {};
        categoryByDay[category]![dayOfWeek] ??= [];
        categoryByDay[category]![dayOfWeek]!.add(amount);
      }
      
      // Calculate average spending by category and day
      final predictions = <String, Map<String, dynamic>>{};
      
      categoryByDay.forEach((category, dayData) {
        final dailyAverages = <int, double>{};
        final standardDeviations = <int, double>{};
        
        dayData.forEach((day, amounts) {
          if (amounts.isNotEmpty) {
            final avg = amounts.reduce((a, b) => a + b) / amounts.length;
            dailyAverages[day] = avg;
            
            // Calculate standard deviation
            final variance = amounts.fold<double>(
              0, (sum, amount) => sum + (amount - avg) * (amount - avg)) / amounts.length;
            standardDeviations[day] = sqrt(variance);
          }
        });
        
        // Calculate weekly total and confidence
        double weeklyTotal = 0;
        double confidence = 1.0;
        
        dailyAverages.forEach((day, avg) {
          weeklyTotal += avg;
          // Lower confidence if standard deviation is high
          confidence *= 1 - (standardDeviations[day]! / avg).clamp(0.0, 0.5);
        });
        
        predictions[category] = {
          'daily_averages': dailyAverages,
          'weekly_total': weeklyTotal,
          'confidence': confidence,
          'trend': _calculateTrend(dayData),
        };
      });
      
      // Generate future predictions
      final futurePredictions = <Map<String, dynamic>>[];
      final now = DateTime.now();
      
      for (var i = 0; i < daysAhead; i++) {
        final futureDate = now.add(Duration(days: i));
        final dayOfWeek = futureDate.weekday;
        
        for (var entry in predictions.entries) {
          final category = entry.key;
          final data = entry.value;
          final dailyAvg = data['daily_averages'][dayOfWeek] ?? 0.0;
          
          if (dailyAvg > 0) {
            futurePredictions.add({
              'date': futureDate.toIso8601String(),
              'category': category,
              'predicted_amount': dailyAvg,
              'confidence': data['confidence'],
              'trend': data['trend'],
            });
          }
        }
      }
      
      return {
        'predictions': futurePredictions,
        'category_totals': predictions.map((category, data) => 
          MapEntry(category, data['weekly_total'])),
        'overall_confidence': predictions.values
          .fold<double>(1.0, (conf, data) => conf * data['confidence']),
      };
    } catch (e) {
      throw Exception('Error predicting future spending: $e');
    }
  }

  String _calculateTrend(Map<int, List<double>> dayData) {
    // Simple trend calculation based on recent vs older data
    final recentDays = dayData.entries.where((e) => e.key >= 5).toList();
    final olderDays = dayData.entries.where((e) => e.key < 5).toList();
    
    if (recentDays.isEmpty || olderDays.isEmpty) return 'stable';
    
    final recentAvg = recentDays.fold<double>(
      0, (sum, day) => sum + day.value.reduce((a, b) => a + b) / day.value.length) / recentDays.length;
    
    final olderAvg = olderDays.fold<double>(
      0, (sum, day) => sum + day.value.reduce((a, b) => a + b) / day.value.length) / olderDays.length;
    
    final difference = recentAvg - olderAvg;
    final percentChange = (difference / olderAvg) * 100;
    
    if (percentChange > 10) return 'increasing';
    if (percentChange < -10) return 'decreasing';
    return 'stable';
  }

  List<Map<String, dynamic>> _generateSavingsRecommendations(
    List<Map<String, dynamic>> opportunities
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    // Sort opportunities by impact and estimated savings
    opportunities.sort((a, b) {
      final impactOrder = {'High': 3, 'Medium': 2, 'Low': 1};
      final impactCompare = impactOrder[b['impact']]!.compareTo(impactOrder[a['impact']]!);
      if (impactCompare != 0) return impactCompare;
      return (b['estimated_savings'] as double).compareTo(a['estimated_savings'] as double);
    });
    
    // Generate personalized recommendations
    for (var opportunity in opportunities) {
      String recommendation = '';
      switch (opportunity['type']) {
        case 'round_up':
          recommendation = 'Enable round-up savings to automatically save small amounts on every purchase. '
              'This can add up to ₹${opportunity['estimated_savings']} per month without feeling the impact.';
          break;
        case 'smart_savings':
          recommendation = 'Set up automatic transfers on ${opportunity['description'].split(' on ')[1]} '
              'to save an extra ₹${opportunity['estimated_savings']} when your spending is typically lower.';
          break;
        case 'subscription_optimization':
          recommendation = 'Review your subscriptions and consider canceling unused services or switching to '
              'lower-tier plans to save up to ₹${opportunity['estimated_savings']} monthly.';
          break;
      }
      
      recommendations.add({
        'type': opportunity['type'],
        'recommendation': recommendation,
        'impact': opportunity['impact'],
        'estimated_savings': opportunity['estimated_savings'],
        'implementation': opportunity['implementation'],
      });
    }
    
    return recommendations;
  }

  Future<Map<String, dynamic>> generateInvestmentForecast({
    required double monthlyAmount,
    required int years,
    required String riskProfile,
  }) async {
    try {
      // Calculate expected returns based on risk profile
      double annualRate;
      switch (riskProfile) {
        case 'Conservative':
          annualRate = 0.06; // 6% annual return
          break;
        case 'Moderate':
          annualRate = 0.10; // 10% annual return
          break;
        case 'Aggressive':
          annualRate = 0.15; // 15% annual return
          break;
        default:
          annualRate = 0.10;
      }

      // Calculate compound interest
      final monthlyRate = annualRate / 12;
      double totalAmount = 0;
      final monthlyContributions = <double>[];
      final monthlyReturns = <double>[];

      for (int month = 0; month < years * 12; month++) {
        final contribution = monthlyAmount;
        final previousTotal = totalAmount;
        totalAmount = (totalAmount + contribution) * (1 + monthlyRate);
        
        monthlyContributions.add(contribution);
        monthlyReturns.add(totalAmount - previousTotal - contribution);
      }

      // Generate forecast data
      return {
        'totalInvestment': monthlyAmount * years * 12,
        'finalAmount': totalAmount,
        'totalReturn': totalAmount - (monthlyAmount * years * 12),
        'annualRate': annualRate,
        'monthlyContributions': monthlyContributions,
        'monthlyReturns': monthlyReturns,
        'monthlyTotals': List.generate(years * 12, (index) => 
          monthlyContributions[index] + monthlyReturns[index]),
      };
    } catch (e) {
      throw Exception('Error generating investment forecast: $e');
    }
  }

  Future<List<Map<String, dynamic>>> generateGoalBasedRecommendations({
    required String goalType,
    required double targetAmount,
    required int timeFrame,
    required String riskProfile,
  }) async {
    try {
      final recommendations = <Map<String, dynamic>>[];
      
      // Calculate required monthly investment
      final monthlyAmount = targetAmount / (timeFrame * 12);
      
      // Generate investment mix based on goal type and risk profile
      Map<String, double> investmentMix;
      switch (goalType) {
        case 'Emergency Fund':
          investmentMix = {
            'Fixed Deposits': 0.4,
            'Liquid Funds': 0.4,
            'Short-term Bonds': 0.2,
          };
          break;
        case 'Short-term Goal':
          investmentMix = {
            'Equity Funds': 0.3,
            'Hybrid Funds': 0.4,
            'Debt Funds': 0.3,
          };
          break;
        case 'Long-term Goal':
          investmentMix = {
            'Equity Funds': 0.6,
            'Index Funds': 0.2,
            'International Funds': 0.2,
          };
          break;
        default:
          investmentMix = {
            'Equity Funds': 0.4,
            'Debt Funds': 0.4,
            'Gold': 0.2,
          };
      }

      // Adjust mix based on risk profile
      if (riskProfile == 'Conservative') {
        investmentMix = investmentMix.map((key, value) => 
          MapEntry(key, value * 0.8));
        investmentMix['Fixed Deposits'] = (investmentMix['Fixed Deposits'] ?? 0) + 0.2;
      } else if (riskProfile == 'Aggressive') {
        investmentMix = investmentMix.map((key, value) => 
          MapEntry(key, value * 1.2));
        investmentMix['Equity Funds'] = (investmentMix['Equity Funds'] ?? 0) + 0.2;
      }

      // Generate recommendations
      for (var entry in investmentMix.entries) {
        recommendations.add({
          'asset': entry.key,
          'allocation': entry.value,
          'monthlyAmount': monthlyAmount * entry.value,
          'rationale': _getInvestmentRationale(entry.key, goalType, riskProfile),
        });
      }

      return recommendations;
    } catch (e) {
      throw Exception('Error generating goal-based recommendations: $e');
    }
  }

  String _getInvestmentRationale(String asset, String goalType, String riskProfile) {
    final rationales = {
      'Fixed Deposits': 'Provides stable returns and capital protection',
      'Liquid Funds': 'Offers high liquidity with better returns than savings account',
      'Short-term Bonds': 'Balances safety with moderate returns',
      'Equity Funds': 'Potential for higher returns over the long term',
      'Hybrid Funds': 'Balanced approach with mix of equity and debt',
      'Debt Funds': 'Lower risk with steady income generation',
      'Index Funds': 'Passive investing with market-matching returns',
      'International Funds': 'Geographic diversification and currency exposure',
      'Gold': 'Hedge against inflation and market volatility',
    };

    return rationales[asset] ?? 'Suitable for your investment goals';
  }

  // Smart expense splitting recommendations
  Future<Map<String, dynamic>> getSmartSplitRecommendations(
    double totalAmount,
    List<String> participants,
    Map<String, dynamic>? context,
  ) async {
    try {
      // Analyze spending patterns and preferences
      final Map<String, double> recommendedSplits = {};
      final List<Map<String, dynamic>> suggestions = [];

      // Default to equal split
      final equalShare = totalAmount / participants.length;
      for (var participant in participants) {
        recommendedSplits[participant] = equalShare;
      }

      // Add context-based adjustments
      if (context != null) {
        // Adjust for income differences
        if (context['incomes'] != null) {
          final incomes = context['incomes'] as Map<String, double>;
          final totalIncome = incomes.values.fold(0.0, (sum, income) => sum + income);
          
          for (var participant in participants) {
            final income = incomes[participant] ?? 0.0;
            if (income > 0) {
              final incomeRatio = income / totalIncome;
              recommendedSplits[participant] = totalAmount * incomeRatio;
            }
          }
        }

        // Adjust for preferences
        if (context['preferences'] != null) {
          final preferences = context['preferences'] as Map<String, dynamic>;
          for (var participant in participants) {
            if (preferences[participant] != null) {
              final preference = preferences[participant] as Map<String, dynamic>;
              if (preference['willingToPayMore'] == true) {
                recommendedSplits[participant] = recommendedSplits[participant]! * 1.1;
              }
            }
          }
        }
      }

      // Generate suggestions
      suggestions.add({
        'type': 'fair_split',
        'message': 'Split based on equal contribution',
        'splits': Map<String, double>.from(recommendedSplits),
      });

      if (context != null && context['incomes'] != null) {
        suggestions.add({
          'type': 'income_based',
          'message': 'Split based on income levels',
          'splits': Map<String, double>.from(recommendedSplits),
        });
      }

      return {
        'recommendedSplits': recommendedSplits,
        'suggestions': suggestions,
      };
    } catch (e) {
      throw Exception('Error generating smart split recommendations: $e');
    }
  }

  // Travel budget recommendations
  Future<Map<String, dynamic>> getTravelBudgetRecommendations(
    String destination,
    DateTime startDate,
    DateTime endDate,
    int participantCount,
    double totalBudget,
  ) async {
    try {
      // Calculate trip duration
      final duration = endDate.difference(startDate).inDays;
      
      // Default allocations
      final Map<String, double> allocations = {
        'accommodation': totalBudget * 0.4,
        'transportation': totalBudget * 0.2,
        'food': totalBudget * 0.2,
        'activities': totalBudget * 0.15,
        'miscellaneous': totalBudget * 0.05,
      };

      // Adjust allocations based on destination and duration
      if (duration > 7) {
        allocations['accommodation'] = totalBudget * 0.35;
        allocations['activities'] = totalBudget * 0.2;
      }

      // Generate suggestions
      final List<Map<String, dynamic>> suggestions = [
        {
          'category': 'accommodation',
          'suggestion': 'Consider booking accommodations in advance for better rates',
          'estimatedCost': allocations['accommodation'],
        },
        {
          'category': 'transportation',
          'suggestion': 'Look for group discounts on transportation',
          'estimatedCost': allocations['transportation'],
        },
        {
          'category': 'food',
          'suggestion': 'Mix of local restaurants and grocery shopping for meals',
          'estimatedCost': allocations['food'],
        },
        {
          'category': 'activities',
          'suggestion': 'Research free activities and group discounts',
          'estimatedCost': allocations['activities'],
        },
      ];

      // Calculate per-person budget
      final perPersonBudget = totalBudget / participantCount;

      return {
        'allocations': allocations,
        'suggestions': suggestions,
        'perPersonBudget': perPersonBudget,
        'duration': duration,
      };
    } catch (e) {
      throw Exception('Error generating travel budget recommendations: $e');
    }
  }

  // Generate fun payment reminders
  Future<List<Map<String, dynamic>>> generatePaymentReminders(
    String debtor,
    String creditor,
    double amount,
    DateTime dueDate,
  ) async {
    try {
      final List<Map<String, dynamic>> reminders = [];
      final now = DateTime.now();
      final daysUntilDue = dueDate.difference(now).inDays;

      // Generate friendly reminders based on time until due date
      if (daysUntilDue > 7) {
        reminders.add({
          'type': 'friendly',
          'message': 'Hey! Just a friendly reminder about the ₹$amount you owe to $creditor',
          'tone': 'casual',
          'scheduledFor': dueDate.subtract(const Duration(days: 7)),
        });
      }

      if (daysUntilDue > 3) {
        reminders.add({
          'type': 'gentle',
          'message': 'Don\'t forget! You have ₹$amount due to $creditor in 3 days',
          'tone': 'reminder',
          'scheduledFor': dueDate.subtract(const Duration(days: 3)),
        });
      }

      if (daysUntilDue > 1) {
        reminders.add({
          'type': 'urgent',
          'message': 'Last call! Your payment of ₹$amount to $creditor is due tomorrow',
          'tone': 'urgent',
          'scheduledFor': dueDate.subtract(const Duration(days: 1)),
        });
      }

      return reminders;
    } catch (e) {
      throw Exception('Error generating payment reminders: $e');
    }
  }
} 