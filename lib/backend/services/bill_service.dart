import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mintmate/backend/models/bill.dart';
import 'package:mintmate/backend/services/base_service.dart';
import 'package:mintmate/backend/services/notification_service.dart';

class BillService extends BaseService<Bill> {
  final NotificationService _notificationService = NotificationService();

  BillService() : super(FirebaseFirestore.instance, 'bills');

  @override
  Bill fromFirestore(DocumentSnapshot doc) {
    return Bill.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(Bill model) {
    return model.toFirestore();
  }

  // Get all bills for a user
  Stream<List<Bill>> getBills(String userId) {
    return stream().map((bills) => 
      bills.where((b) => b.userId == userId).toList());
  }

  // Get upcoming bills (due within next 7 days)
  Stream<List<Bill>> getUpcomingBills(String userId) {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return stream().map((bills) => 
      bills.where((b) => 
        b.userId == userId && 
        !b.isPaid &&
        b.dueDate.isAfter(now) && 
        b.dueDate.isBefore(nextWeek)
      ).toList());
  }

  // Get overdue bills
  Stream<List<Bill>> getOverdueBills(String userId) {
    final now = DateTime.now();
    
    return stream().map((bills) => 
      bills.where((b) => 
        b.userId == userId && 
        !b.isPaid &&
        b.dueDate.isBefore(now)
      ).toList());
  }

  // Get bills by category
  Stream<List<Bill>> getBillsByCategory(String userId, String category) {
    return stream().map((bills) => 
      bills.where((b) => 
        b.userId == userId && 
        b.category == category
      ).toList());
  }

  // Create a new bill
  Future<Bill> createBill(Bill bill) async {
    return create(bill);
  }

  // Update a bill
  Future<void> updateBill(Bill bill) async {
    await update(bill.id, bill);
  }

  // Mark a bill as paid
  Future<void> markBillAsPaid(String billId) async {
    final bill = await get(billId);
    if (bill != null) {
      final updatedBill = bill.copyWith(
        isPaid: true,
        lastPaidDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await update(billId, updatedBill);
    }
  }

  // Delete a bill
  Future<void> deleteBill(String billId) async {
    await delete(billId);
  }

  // Get bill statistics
  Future<Map<String, dynamic>> getBillStats(String userId) async {
    final bills = await query(field: 'userId', isEqualTo: userId);
    
    double totalAmount = 0;
    double paidAmount = 0;
    double upcomingAmount = 0;
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    for (var bill in bills) {
      totalAmount += bill.amount;
      if (bill.isPaid) {
        paidAmount += bill.amount;
      } else if (bill.dueDate.isAfter(now) && bill.dueDate.isBefore(nextWeek)) {
        upcomingAmount += bill.amount;
      }
    }
    
    return {
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'upcomingAmount': upcomingAmount,
      'unpaidAmount': totalAmount - paidAmount,
    };
  }

  // Get subscription optimization suggestions
  Future<List<Map<String, dynamic>>> getSubscriptionSuggestions(String userId) async {
    final bills = await query(field: 'userId', isEqualTo: userId);
    final subscriptions = bills.where((b) => b.frequency != 'monthly').toList();
    
    final suggestions = <Map<String, dynamic>>[];
    
    // Group similar subscriptions
    final Map<String, List<Bill>> categoryGroups = {};
    for (var sub in subscriptions) {
      categoryGroups[sub.category ?? 'Other'] = [...(categoryGroups[sub.category ?? 'Other'] ?? []), sub];
    }
    
    // Analyze each category group
    categoryGroups.forEach((category, subs) {
      if (subs.length > 1) {
        // Multiple subscriptions in same category
        suggestions.add({
          'type': 'consolidation',
          'category': category,
          'subscriptions': subs.map((s) => s.name).toList(),
          'totalAmount': subs.fold(0.0, (sum, s) => sum + s.amount),
          'suggestion': 'Consider consolidating your ${category.toLowerCase()} subscriptions to save money.',
        });
      }
      
      // Check for unused subscriptions
      for (var sub in subs) {
        if (sub.lastPaidDate != null) {
          final monthsSinceLastPayment = 
              (DateTime.now().difference(sub.lastPaidDate!).inDays / 30).floor();
          if (monthsSinceLastPayment > 3) {
            suggestions.add({
              'type': 'unused',
              'subscription': sub.name,
              'amount': sub.amount,
              'lastUsed': sub.lastPaidDate,
              'suggestion': 'You haven\'t used ${sub.name} in $monthsSinceLastPayment months. Consider canceling if no longer needed.',
            });
          }
        }
      }
    });
    
    return suggestions;
  }

  // Schedule reminders for upcoming bills
  Future<void> scheduleReminders(String userId) async {
    final bills = await query(field: 'userId', isEqualTo: userId);
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    for (var bill in bills) {
      if (!bill.isPaid && bill.dueDate.isAfter(now) && bill.dueDate.isBefore(nextWeek)) {
        final daysUntilDue = bill.dueDate.difference(now).inDays;
        if (daysUntilDue <= 3) {
          await _notificationService.showLocalNotification(
            title: 'Bill Due Soon',
            body: '${bill.name} of ₹${bill.amount.toStringAsFixed(2)} is due in $daysUntilDue days.',
          );
        }
      }
    }
  }
} 