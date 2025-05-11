import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account.dart';
import 'base_service.dart';

class AccountService extends BaseService<Account> {
  AccountService(FirebaseFirestore firestore) : super(firestore, 'accounts');

  @override
  Account fromFirestore(DocumentSnapshot doc) {
    return Account.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(Account account) {
    return account.toFirestore();
  }

  // Get all accounts for a user
  Future<List<Account>> getAccountsForUser(String userId) async {
    return query(field: 'userId', isEqualTo: userId);
  }

  // Stream all accounts for a user
  Stream<List<Account>> streamAccountsForUser(String userId) {
    return stream().map((accounts) => accounts.where((a) => a.userId == userId).toList());
  }
} 