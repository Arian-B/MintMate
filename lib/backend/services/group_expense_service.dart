import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_expense.dart';
import 'base_service.dart';

class GroupExpenseService extends BaseService<GroupExpense> {
  GroupExpenseService() : super(FirebaseFirestore.instance, 'group_expenses');

  @override
  GroupExpense fromFirestore(DocumentSnapshot doc) {
    return GroupExpense.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(GroupExpense model) {
    return model.toFirestore();
  }

  // Get all expenses for a group
  Stream<List<GroupExpense>> getExpensesForGroup(String groupId) {
    return stream().map((expenses) => 
      expenses.where((e) => e.groupId == groupId).toList());
  }

  // Create a new group expense
  Future<GroupExpense> createExpense(GroupExpense expense) async {
    return create(expense);
  }

  // Update a group expense
  Future<GroupExpense> updateExpense(GroupExpense expense) async {
    return update(expense.id, expense);
  }

  // Delete a group expense
  Future<void> deleteExpense(String expenseId) async {
    await delete(expenseId);
  }

  // Calculate splits for a group expense
  Map<String, double> calculateSplits(GroupExpense expense) {
    final int participantCount = expense.participants.length;
    final double splitAmount = expense.amount / participantCount;
    final Map<String, double> splits = {};
    for (String participant in expense.participants) {
      splits[participant] = splitAmount;
    }
    return splits;
  }

  // Calculate settlements for a group
  Future<Map<String, Map<String, double>>> calculateSettlements(String groupId) async {
    final expenses = await query(field: 'groupId', isEqualTo: groupId);
    final Map<String, double> balances = {};
    for (var expense in expenses) {
      final splits = calculateSplits(expense);
      for (String participant in expense.participants) {
        balances[participant] = (balances[participant] ?? 0) - splits[participant]!;
      }
      balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.amount;
    }
    final Map<String, Map<String, double>> settlements = {};
    for (String debtor in balances.keys) {
      if (balances[debtor]! < 0) {
        for (String creditor in balances.keys) {
          if (balances[creditor]! > 0) {
            final double amount = -balances[debtor]!;
            if (amount <= balances[creditor]!) {
              settlements[debtor] = {creditor: amount};
              balances[creditor] = balances[creditor]! - amount;
              balances[debtor] = 0;
            } else {
              settlements[debtor] = {creditor: balances[creditor]!};
              balances[debtor] = balances[debtor]! + balances[creditor]!;
              balances[creditor] = 0;
            }
          }
        }
      }
    }
    return settlements;
  }
} 