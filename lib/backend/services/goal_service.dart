import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal.dart';
import 'base_service.dart';

class GoalService extends BaseService<Goal> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'goals';

  GoalService(FirebaseFirestore firestore) : super(firestore, 'goals');

  @override
  Goal fromFirestore(DocumentSnapshot doc) {
    return Goal.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Map<String, dynamic> toFirestore(Goal goal) {
    return goal.toMap();
  }

  // Create a new financial goal
  Future<Goal> createGoal(Goal goal) async {
    try {
      final docRef = await _firestore.collection(_collection).add(goal.toMap());
      return goal.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  // Get all goals for a user
  Future<List<Goal>> getUserGoals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Goal.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch goals: $e');
    }
  }

  // Update a goal
  Future<void> updateGoal(Goal goal) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(goal.id)
          .update(goal.toMap());
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      await _firestore.collection(_collection).doc(goalId).delete();
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  // Update goal progress
  Future<void> updateProgress(String goalId, double amount) async {
    try {
      final docRef = _firestore.collection(_collection).doc(goalId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw Exception('Goal does not exist');
        }

        final goal = Goal.fromMap(doc.data()!, doc.id);
        final newProgress = goal.currentAmount + amount;
        
        transaction.update(docRef, {
          'currentAmount': newProgress,
          'lastUpdated': FieldValue.serverTimestamp(),
          'isCompleted': newProgress >= goal.targetAmount,
        });
      });
    } catch (e) {
      throw Exception('Failed to update goal progress: $e');
    }
  }

  // Get goals by category
  Future<List<Goal>> getGoalsByCategory(String userId, String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Goal.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch goals by category: $e');
    }
  }

  // Get goals by status
  Future<List<Goal>> getGoalsByStatus(String userId, bool isCompleted) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: isCompleted)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Goal.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch goals by status: $e');
    }
  }

  // Get goals due soon
  Future<List<Goal>> getGoalsDueSoon(String userId, {int days = 30}) async {
    try {
      final now = DateTime.now();
      final dueDate = now.add(Duration(days: days));

      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .where('targetDate', isLessThanOrEqualTo: dueDate)
          .orderBy('targetDate')
          .get();

      return snapshot.docs
          .map((doc) => Goal.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch goals due soon: $e');
    }
  }

  // Get goal statistics
  Future<Map<String, dynamic>> getGoalStatistics(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final goals = snapshot.docs
          .map((doc) => Goal.fromMap(doc.data(), doc.id))
          .toList();

      final totalGoals = goals.length;
      final completedGoals = goals.where((g) => g.isCompleted).length;
      final totalTargetAmount = goals.fold<double>(
          0, (sum, goal) => sum + goal.targetAmount);
      final totalCurrentAmount = goals.fold<double>(
          0, (sum, goal) => sum + goal.currentAmount);

      return {
        'totalGoals': totalGoals,
        'completedGoals': completedGoals,
        'completionRate': totalGoals > 0 ? completedGoals / totalGoals : 0,
        'totalTargetAmount': totalTargetAmount,
        'totalCurrentAmount': totalCurrentAmount,
        'overallProgress': totalTargetAmount > 0
            ? totalCurrentAmount / totalTargetAmount
            : 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch goal statistics: $e');
    }
  }
} 