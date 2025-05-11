import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal.dart';
import 'base_service.dart';

class GoalService extends BaseService<Goal> {
  GoalService(FirebaseFirestore firestore) : super(firestore, 'goals');

  @override
  Goal fromFirestore(DocumentSnapshot doc) {
    return Goal.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(Goal goal) {
    return goal.toFirestore();
  }

  // Get all goals for a user
  Future<List<Goal>> getGoalsForUser(String userId) async {
    return query(field: 'userId', isEqualTo: userId);
  }

  // Stream all goals for a user
  Stream<List<Goal>> streamGoalsForUser(String userId) {
    return stream().map((goals) => goals.where((g) => g.userId == userId).toList());
  }
} 