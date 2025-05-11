import 'package:mintmate/backend/services/base_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIService extends BaseService {
  AIService() : super(FirebaseFirestore.instance, 'ai_settings');

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
} 