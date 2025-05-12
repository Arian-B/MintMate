import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account.dart';
import 'base_service.dart';

class AccountService extends BaseService<Account> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'accounts';

  AccountService(FirebaseFirestore firestore) : super(firestore, 'accounts');

  @override
  Account fromFirestore(DocumentSnapshot doc) {
    return Account.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Map<String, dynamic> toFirestore(Account account) {
    return account.toMap();
  }

  // Create a new account
  Future<Account> createAccount(Account account) async {
    try {
      final docRef = await _firestore.collection(_collection).add(account.toMap());
      return account.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  // Get all accounts for a user
  Future<List<Account>> getUserAccounts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Account.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch accounts: $e');
    }
  }

  // Get account by ID
  Future<Account> getAccount(String accountId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(accountId).get();
      if (!doc.exists) {
        throw Exception('Account not found');
      }
      return Account.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch account: $e');
    }
  }

  // Update account
  Future<void> updateAccount(Account account) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(account.id)
          .update(account.toMap());
    } catch (e) {
      throw Exception('Failed to update account: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount(String accountId) async {
    try {
      await _firestore.collection(_collection).doc(accountId).delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Update account balance
  Future<void> updateBalance(String accountId, double amount) async {
    try {
      final docRef = _firestore.collection(_collection).doc(accountId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw Exception('Account does not exist');
        }

        final account = Account.fromMap(doc.data()!, doc.id);
        final newBalance = account.balance + amount;
        
        transaction.update(docRef, {
          'balance': newBalance,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to update account balance: $e');
    }
  }

  // Get accounts by type
  Future<List<Account>> getAccountsByType(String userId, String type) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Account.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch accounts by type: $e');
    }
  }

  // Get account statistics
  Future<Map<String, dynamic>> getAccountStatistics(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final accounts = snapshot.docs
          .map((doc) => Account.fromMap(doc.data(), doc.id))
          .toList();

      final totalBalance = accounts.fold<double>(
          0, (sum, account) => sum + account.balance);

      final typeTotals = <String, double>{};
      for (var account in accounts) {
        typeTotals[account.type] =
            (typeTotals[account.type] ?? 0) + account.balance;
      }

      return {
        'totalBalance': totalBalance,
        'accountCount': accounts.length,
        'typeTotals': typeTotals,
      };
    } catch (e) {
      throw Exception('Failed to fetch account statistics: $e');
    }
  }

  // Link external account
  Future<void> linkExternalAccount(String accountId, Map<String, dynamic> externalData) async {
    try {
      await _firestore.collection(_collection).doc(accountId).update({
        'externalData': externalData,
        'isLinked': true,
        'lastSynced': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to link external account: $e');
    }
  }

  // Unlink external account
  Future<void> unlinkExternalAccount(String accountId) async {
    try {
      await _firestore.collection(_collection).doc(accountId).update({
        'externalData': FieldValue.delete(),
        'isLinked': false,
        'lastSynced': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to unlink external account: $e');
    }
  }
} 