import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as model_tx;
import 'base_service.dart';

class TransactionService extends BaseService<model_tx.Transaction> {
  TransactionService(FirebaseFirestore firestore) : super(firestore, 'transactions');

  @override
  model_tx.Transaction fromFirestore(DocumentSnapshot doc) {
    return model_tx.Transaction.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(model_tx.Transaction transaction) {
    return transaction.toFirestore();
  }

  // Get all transactions for a user
  Future<List<model_tx.Transaction>> getTransactionsForUser(String userId) async {
    return query(field: 'userId', isEqualTo: userId);
  }

  // Get all transactions for an account
  Future<List<model_tx.Transaction>> getTransactionsForAccount(String accountId) async {
    return query(field: 'accountId', isEqualTo: accountId);
  }

  // Stream all transactions for a user
  Stream<List<model_tx.Transaction>> streamTransactionsForUser(String userId) {
    return stream().map((txs) => txs.where((t) => t.userId == userId).toList());
  }

  // Stream all transactions for an account
  Stream<List<model_tx.Transaction>> streamTransactionsForAccount(String accountId) {
    return stream().map((txs) => txs.where((t) => t.accountId == accountId).toList());
  }
} 