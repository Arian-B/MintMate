import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mintmate/backend/services/base_service.dart';

class NetWorthService extends BaseService {
  NetWorthService() : super(FirebaseFirestore.instance, 'net_worth');

  @override
  Map<String, dynamic> fromFirestore(DocumentSnapshot doc) {
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> toFirestore(dynamic model) {
    return model as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> calculateNetWorth(String userId) async {
    try {
      // Get all accounts
      final accountsSnapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .where('userId', isEqualTo: userId)
          .get();

      double totalAssets = 0;
      double totalLiabilities = 0;
      Map<String, double> assetsByType = {};
      Map<String, double> liabilitiesByType = {};

      for (var account in accountsSnapshot.docs) {
        final data = account.data();
        final balance = (data['balance'] as num).toDouble();
        final type = data['type'] as String;
        final isLiability = data['isLiability'] as bool? ?? false;

        if (isLiability) {
          totalLiabilities += balance;
          liabilitiesByType[type] = (liabilitiesByType[type] ?? 0) + balance;
        } else {
          totalAssets += balance;
          assetsByType[type] = (assetsByType[type] ?? 0) + balance;
        }
      }

      final netWorth = totalAssets - totalLiabilities;
      final netWorthChange = await _calculateNetWorthChange(userId, netWorth);

      // Save the calculation
      await create({
        'userId': userId,
        'totalAssets': totalAssets,
        'totalLiabilities': totalLiabilities,
        'netWorth': netWorth,
        'assetsByType': assetsByType,
        'liabilitiesByType': liabilitiesByType,
        'netWorthChange': netWorthChange,
        'timestamp': DateTime.now(),
      });

      return {
        'totalAssets': totalAssets,
        'totalLiabilities': totalLiabilities,
        'netWorth': netWorth,
        'assetsByType': assetsByType,
        'liabilitiesByType': liabilitiesByType,
        'netWorthChange': netWorthChange,
      };
    } catch (e) {
      throw Exception('Error calculating net worth: $e');
    }
  }

  Future<Map<String, dynamic>> _calculateNetWorthChange(String userId, double currentNetWorth) async {
    try {
      // Get last month's net worth
      final lastMonth = DateTime.now().subtract(const Duration(days: 30));
      final lastMonthSnapshot = await FirebaseFirestore.instance
          .collection('net_worth')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: lastMonth)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (lastMonthSnapshot.docs.isEmpty) {
        return {
          'amount': 0.0,
          'percentage': 0.0,
          'isPositive': true,
        };
      }

      final lastMonthNetWorth = (lastMonthSnapshot.docs.first.data()['netWorth'] as num).toDouble();
      final change = currentNetWorth - lastMonthNetWorth;
      final percentage = lastMonthNetWorth != 0 ? (change / lastMonthNetWorth) * 100 : 0;

      return {
        'amount': change,
        'percentage': percentage,
        'isPositive': change >= 0,
      };
    } catch (e) {
      return {
        'amount': 0.0,
        'percentage': 0.0,
        'isPositive': true,
      };
    }
  }

  Stream<Map<String, dynamic>> watchNetWorth(String userId) {
    return FirebaseFirestore.instance
        .collection('net_worth')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return {
          'totalAssets': 0.0,
          'totalLiabilities': 0.0,
          'netWorth': 0.0,
          'assetsByType': {},
          'liabilitiesByType': {},
          'netWorthChange': {
            'amount': 0.0,
            'percentage': 0.0,
            'isPositive': true,
          },
        };
      }
      return snapshot.docs.first.data();
    });
  }
} 