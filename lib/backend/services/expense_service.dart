import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mintmate/backend/models/expense.dart';
import 'base_service.dart';

class ExpenseService extends BaseService<Expense> {
  ExpenseService() : super(FirebaseFirestore.instance, 'expenses');

  @override
  Expense fromFirestore(DocumentSnapshot doc) {
    return Expense.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(Expense model) {
    return model.toFirestore();
  }

  // Create a new expense
  Future<Expense> createExpense(Expense expense) async {
    return create(expense);
  }

  // Get all expenses for a user
  Stream<List<Expense>> getExpenses(String userId) {
    return stream().map((expenses) => 
      expenses.where((e) => e.userId == userId).toList());
  }

  // Get expenses by category
  Stream<List<Expense>> getExpensesByCategory(String userId, String category) {
    return stream().map((expenses) => 
      expenses.where((e) => e.userId == userId && e.category == category).toList());
  }

  // Get expenses by date range
  Stream<List<Expense>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return stream().map((expenses) => 
      expenses.where((e) => 
        e.userId == userId && 
        e.date.isAfter(startDate) && 
        e.date.isBefore(endDate)).toList());
  }

  // Update an expense
  Future<void> updateExpense(Expense expense) async {
    await update(expense.id, expense);
  }

  // Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    await delete(expenseId);
  }

  // Get expense statistics
  Future<Map<String, double>> getExpenseStats(String userId) async {
    final expenses = await query(field: 'userId', isEqualTo: userId);
    final Map<String, double> categoryTotals = {};
    double totalAmount = 0;

    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
      totalAmount += expense.amount;
    }

    return {
      'total': totalAmount,
      ...categoryTotals,
    };
  }

  // Get monthly expense trend
  Future<List<Map<String, dynamic>>> getMonthlyTrend(String userId) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 6, 1);
    
    final expenses = await query(
      field: 'userId',
      isEqualTo: userId,
      isGreaterThanOrEqualTo: startDate,
    );

    final Map<String, double> monthlyTotals = {};
    
    for (var expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    return monthlyTotals.entries
        .map((e) => {
              'month': e.key,
              'amount': e.value,
            })
        .toList()
      ..sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
  }
} 