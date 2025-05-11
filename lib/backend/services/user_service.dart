import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'base_service.dart';

class UserService extends BaseService<User> {
  UserService(FirebaseFirestore firestore) : super(firestore, 'users');

  @override
  User fromFirestore(DocumentSnapshot doc) {
    return User.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(User user) {
    return user.toFirestore();
  }

  // Get user by email
  Future<User?> getByEmail(String email) async {
    final users = await query(field: 'email', isEqualTo: email, limit: 1);
    return users.isNotEmpty ? users.first : null;
  }

  // Update user preferences
  Future<User> updatePreferences(String userId, Map<String, dynamic> preferences) async {
    final user = await get(userId);
    if (user == null) throw Exception('User not found');
    final updatedUser = user.copyWith(
      preferences: preferences,
    );
    return update(userId, updatedUser);
  }

  // Update active modules
  Future<User> updateActiveModules(String userId, List<String> activeModules) async {
    final user = await get(userId);
    if (user == null) throw Exception('User not found');
    final updatedUser = user.copyWith(
      activeModules: activeModules,
    );
    return update(userId, updatedUser);
  }

  // Update total net worth
  Future<User> updateNetWorth(String userId, double totalNetWorth) async {
    final user = await get(userId);
    if (user == null) throw Exception('User not found');
    final updatedUser = user.copyWith(
      totalNetWorth: totalNetWorth,
    );
    return update(userId, updatedUser);
  }

  // Update account balances
  Future<User> updateAccountBalances(String userId, Map<String, double> accountBalances) async {
    final user = await get(userId);
    if (user == null) throw Exception('User not found');
    final updatedUser = user.copyWith(
      accountBalances: accountBalances,
    );
    return update(userId, updatedUser);
  }

  // Get users by active module
  Future<List<User>> getUsersByActiveModule(String module) async {
    return query(field: 'activeModules', whereIn: [module]);
  }

  // Stream user's active modules
  Stream<List<String>> streamActiveModules(String userId) {
    return streamDocument(userId).map((user) => user?.activeModules ?? []);
  }

  // Stream user's total net worth
  Stream<double> streamNetWorth(String userId) {
    return streamDocument(userId).map((user) => user?.totalNetWorth ?? 0.0);
  }

  // Stream user's account balances
  Stream<Map<String, double>> streamAccountBalances(String userId) {
    return streamDocument(userId).map((user) => user?.accountBalances ?? {});
  }
} 