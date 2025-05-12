import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as model_tx;
import 'base_service.dart';

class TransactionService extends BaseService<model_tx.Transaction> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'transactions';

  TransactionService(FirebaseFirestore firestore) : super(firestore, 'transactions');

  @override
  model_tx.Transaction fromFirestore(DocumentSnapshot doc) {
    return model_tx.Transaction.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Map<String, dynamic> toFirestore(model_tx.Transaction transaction) {
    return transaction.toMap();
  }

  // Create a new transaction
  Future<model_tx.Transaction> createTransaction(model_tx.Transaction transaction) async {
    try {
      final docRef = await _firestore.collection(_collection).add(transaction.toMap());
      return transaction.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Get all transactions for a user
  Future<List<model_tx.Transaction>> getUserTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => model_tx.Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Get transactions by category
  Future<List<model_tx.Transaction>> getTransactionsByCategory(
      String userId, String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => model_tx.Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions by category: $e');
    }
  }

  // Get transactions by date range
  Future<List<model_tx.Transaction>> getTransactionsByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => model_tx.Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions by date range: $e');
    }
  }

  // Get transaction statistics
  Future<Map<String, dynamic>> getTransactionStatistics(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final transactions = snapshot.docs
          .map((doc) => model_tx.Transaction.fromMap(doc.data(), doc.id))
          .toList();

      final totalIncome = transactions
          .where((t) => t.type == model_tx.TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalExpense = transactions
          .where((t) => t.type == model_tx.TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final categoryTotals = <String, double>{};
      for (var transaction in transactions) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'netAmount': totalIncome - totalExpense,
        'categoryTotals': categoryTotals,
        'transactionCount': transactions.length,
      };
    } catch (e) {
      throw Exception('Failed to fetch transaction statistics: $e');
    }
  }

  // Update a transaction
  Future<void> updateTransaction(model_tx.Transaction transaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection(_collection).doc(transactionId).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Get recurring transactions
  Future<List<model_tx.Transaction>> getRecurringTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRecurring', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => model_tx.Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recurring transactions: $e');
    }
  }

  // Get transactions by account
  Future<List<model_tx.Transaction>> getTransactionsByAccount(
      String userId, String accountId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('accountId', isEqualTo: accountId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => model_tx.Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions by account: $e');
    }
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