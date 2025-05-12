import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mintmate/backend/services/ai_service.dart';
import '../models/group_expense.dart';
import 'base_service.dart';

class GroupExpenseService extends BaseService<GroupExpense> {
  final AIService _aiService = AIService();

  GroupExpenseService() : super(FirebaseFirestore.instance, 'group_expenses');

  @override
  GroupExpense fromFirestore(DocumentSnapshot doc) {
    return GroupExpense.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(dynamic model) {
    return (model as GroupExpense).toFirestore();
  }

  // Get all expenses for a group
  Future<List<GroupExpense>> getExpensesForGroup(String groupId) async {
    final docs = await query(field: 'groupId', isEqualTo: groupId);
    return docs.map((doc) => fromFirestore(doc as DocumentSnapshot)).toList();
  }

  // Create a new group
  Future<GroupExpense> createGroup({
    required String name,
    required List<String> members,
    String? groupDescription,
  }) async {
    try {
      final group = GroupExpense(
        id: '',
        groupId: '',
        name: name,
        members: members,
        groupDescription: groupDescription,
        description: '',
        amount: 0.0,
        paidBy: '',
        participants: [],
        splits: {},
        suggestions: [],
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await create(group);
      return group.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Error creating group: $e');
    }
  }

  // Get all groups for a user
  Future<List<GroupExpense>> getUserGroups(String userId) async {
    try {
      final groups = await query(
        field: 'members',
        isEqualTo: userId,
      );
      return groups.map((doc) => fromFirestore(doc as DocumentSnapshot)).toList();
    } catch (e) {
      throw Exception('Error getting user groups: $e');
    }
  }

  // Add expense with smart splitting
  Future<GroupExpense> addExpense({
    required String groupId,
    required String paidBy,
    required double amount,
    required String description,
    required List<String> participants,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Get smart split recommendations
      final recommendations = await _aiService.getSmartSplitRecommendations(
        amount,
        participants,
        context,
      );

      final expense = GroupExpense(
        id: '',
        groupId: groupId,
        paidBy: paidBy,
        amount: amount,
        description: description,
        participants: participants,
        splits: Map<String, double>.from(recommendations['recommendedSplits']),
        suggestions: List<Map<String, dynamic>>.from(recommendations['suggestions']),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await create(expense);
      return expense.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Error adding expense: $e');
    }
  }

  // Get expenses for a group
  Future<List<GroupExpense>> getGroupExpenses(String groupId) async {
    try {
      final expenses = await query(field: 'groupId', isEqualTo: groupId);
      return expenses;
    } catch (e) {
      throw Exception('Error getting group expenses: $e');
    }
  }

  // Calculate settlements
  Future<List<Map<String, dynamic>>> calculateSettlements(String groupId) async {
    try {
      final expenses = await getGroupExpenses(groupId);
      final Map<String, double> balances = {};

      // Calculate net balances
      for (var expense in expenses) {
        // Add to payer's balance
        balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.amount;

        // Subtract from each participant's balance
        for (var entry in expense.splits.entries) {
          final participant = entry.key;
          final share = entry.value;
          balances[participant] = (balances[participant] ?? 0) - share;
        }
      }

      // Generate settlements
      final List<Map<String, dynamic>> settlements = [];
      final debtors = balances.entries.where((e) => e.value < 0).toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final creditors = balances.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (var debtor in debtors) {
        var remainingDebt = -debtor.value;
        for (var creditor in creditors) {
          if (remainingDebt <= 0 || creditor.value <= 0) continue;

          final amount = remainingDebt < creditor.value ? remainingDebt : creditor.value;
          if (amount > 0) {
            settlements.add({
              'from': debtor.key,
              'to': creditor.key,
              'amount': amount,
            });

            remainingDebt -= amount;
            balances[creditor.key] = creditor.value - amount;
          }
        }
      }

      return settlements;
    } catch (e) {
      throw Exception('Error calculating settlements: $e');
    }
  }

  // Generate payment reminders
  Future<List<Map<String, dynamic>>> generatePaymentReminders(
    String groupId,
    String debtor,
    String creditor,
    double amount,
  ) async {
    try {
      final dueDate = DateTime.now().add(const Duration(days: 7));
      return await _aiService.generatePaymentReminders(
        debtor,
        creditor,
        amount,
        dueDate,
      );
    } catch (e) {
      throw Exception('Error generating payment reminders: $e');
    }
  }

  Future<void> createExpense(GroupExpense expense) async {
    await create(expense);
  }

  Future<void> updateExpense(GroupExpense expense) async {
    await update(expense.id, expense);
  }

  Future<void> deleteExpense(String expenseId) async {
    await delete(expenseId);
  }

  Map<String, double> calculateSplits(GroupExpense expense) {
    final splits = <String, double>{};
    final amountPerPerson = expense.amount / expense.participants.length;

    for (final participant in expense.participants) {
      if (participant == expense.paidBy) {
        splits[participant] = expense.amount - amountPerPerson;
      } else {
        splits[participant] = -amountPerPerson;
      }
    }

    return splits;
  }
} 