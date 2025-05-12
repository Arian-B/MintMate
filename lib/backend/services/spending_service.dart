import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mintmate/backend/services/base_service.dart';
import 'package:logging/logging.dart';

class SpendingService extends BaseService<Map<String, dynamic>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _logger = Logger('SpendingService');

  SpendingService() : super(FirebaseFirestore.instance, 'transactions');

  @override
  Map<String, dynamic> fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      ...data,
    };
  }

  @override
  Map<String, dynamic> toFirestore(Map<String, dynamic> data) {
    return data;
  }

  Future<List<Map<String, dynamic>>> getSpendingData(
    String userId, {
    String period = 'week',
  }) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('type', isEqualTo: 'expense')
          .orderBy('date')
          .get();

      final Map<DateTime, double> dailySpending = {};

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final amount = (data['amount'] as num).toDouble();

        // Group by day
        final day = DateTime(date.year, date.month, date.day);
        dailySpending[day] = (dailySpending[day] ?? 0) + amount;
      }

      // Convert to list and fill missing dates with 0
      final List<Map<String, dynamic>> spendingData = [];
      var currentDate = startDate;
      while (currentDate.isBefore(now) || currentDate.isAtSameMomentAs(now)) {
        spendingData.add({
          'date': currentDate.toIso8601String(),
          'amount': dailySpending[currentDate] ?? 0,
        });
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return spendingData;
    } catch (e) {
      _logger.severe('Error fetching spending data: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> getSpendingByCategory(
    String userId, {
    String period = 'month',
  }) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('type', isEqualTo: 'expense')
          .get();

      final Map<String, double> categorySpending = {};

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String;
        final amount = (data['amount'] as num).toDouble();

        categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      }

      return categorySpending;
    } catch (e) {
      _logger.severe('Error fetching spending by category: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> watchSpendingData(
    String userId, {
    String period = 'week',
  }) {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      return _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('type', isEqualTo: 'expense')
          .orderBy('date')
          .snapshots()
          .map((snapshot) {
        final Map<DateTime, double> dailySpending = {};

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final date = (data['date'] as Timestamp).toDate();
          final amount = (data['amount'] as num).toDouble();

          // Group by day
          final day = DateTime(date.year, date.month, date.day);
          dailySpending[day] = (dailySpending[day] ?? 0) + amount;
        }

        // Convert to list and fill missing dates with 0
        final List<Map<String, dynamic>> spendingData = [];
        var currentDate = startDate;
        while (currentDate.isBefore(now) || currentDate.isAtSameMomentAs(now)) {
          spendingData.add({
            'date': currentDate.toIso8601String(),
            'amount': dailySpending[currentDate] ?? 0,
          });
          currentDate = currentDate.add(const Duration(days: 1));
        }

        return spendingData;
      });
    } catch (e) {
      _logger.severe('Error watching spending data: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    try {
      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      return transactionsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _logger.severe('Error fetching transactions: $e');
      rethrow;
    }
  }
} 