import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mintmate/backend/services/ai_service.dart';
import 'base_service.dart';

class GroupGoalService extends BaseService {
  final AIService _aiService = AIService();

  GroupGoalService() : super(FirebaseFirestore.instance, 'group_goals');

  @override
  Map<String, dynamic> fromFirestore(DocumentSnapshot doc) {
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> toFirestore(dynamic model) {
    return model as Map<String, dynamic>;
  }

  // Create a new group goal
  Future<Map<String, dynamic>> createGroupGoal({
    required String groupId,
    required String name,
    required double targetAmount,
    required List<String> participants,
    required String type, // 'travel', 'event', 'purchase'
    DateTime? targetDate,
    Map<String, dynamic>? details,
  }) async {
    try {
      final goal = {
        'groupId': groupId,
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': 0.0,
        'participants': participants,
        'type': type,
        'targetDate': targetDate,
        'details': details ?? {},
        'status': 'active',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      final docRef = await create(goal);
      return {...goal, 'id': docRef.id};
    } catch (e) {
      throw Exception('Error creating group goal: $e');
    }
  }

  // Get all goals for a group
  Future<List<Map<String, dynamic>>> getGroupGoals(String groupId) async {
    try {
      final goals = await query(field: 'groupId', isEqualTo: groupId);
      return goals.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error getting group goals: $e');
    }
  }

  // Add contribution to a goal
  Future<void> addContribution(String goalId, String userId, double amount) async {
    try {
      final goal = await get(goalId);
      if (goal == null) throw Exception('Goal not found');

      final currentAmount = (goal['currentAmount'] as num).toDouble();
      final newAmount = currentAmount + amount;

      await update(goalId, {
        'currentAmount': newAmount,
        'updatedAt': DateTime.now(),
        'contributions': [
          ...(goal['contributions'] as List? ?? []),
          {
            'userId': userId,
            'amount': amount,
            'timestamp': DateTime.now(),
          },
        ],
      });

      // Check if goal is completed
      if (newAmount >= (goal['targetAmount'] as num).toDouble()) {
        await update(goalId, {'status': 'completed'});
      }
    } catch (e) {
      throw Exception('Error adding contribution: $e');
    }
  }

  // Create travel budget plan
  Future<Map<String, dynamic>> createTravelBudget({
    required String groupId,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> participants,
    required double totalBudget,
  }) async {
    try {
      // Get AI recommendations for budget allocation
      final recommendations = await _aiService.getTravelBudgetRecommendations(
        destination,
        startDate,
        endDate,
        participants.length,
        totalBudget,
      );

      final budget = {
        'groupId': groupId,
        'destination': destination,
        'startDate': startDate,
        'endDate': endDate,
        'participants': participants,
        'totalBudget': totalBudget,
        'allocations': recommendations['allocations'],
        'suggestions': recommendations['suggestions'],
        'status': 'active',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      final docRef = await create(budget);
      return {...budget, 'id': docRef.id};
    } catch (e) {
      throw Exception('Error creating travel budget: $e');
    }
  }

  // Get travel budget details
  Future<Map<String, dynamic>?> getTravelBudget(String budgetId) async {
    try {
      return await get(budgetId);
    } catch (e) {
      throw Exception('Error getting travel budget: $e');
    }
  }

  // Update travel budget allocation
  Future<void> updateTravelBudgetAllocation(
    String budgetId,
    Map<String, double> allocations,
  ) async {
    try {
      await update(budgetId, {
        'allocations': allocations,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Error updating travel budget: $e');
    }
  }
} 