import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mintmate/backend/services/base_service.dart';

class SavingsService extends BaseService {
  SavingsService() : super(FirebaseFirestore.instance, 'savings');

  @override
  Map<String, dynamic> fromFirestore(DocumentSnapshot doc) {
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> toFirestore(dynamic model) {
    return model as Map<String, dynamic>;
  }

  // Get all savings buckets for a user
  Stream<Map<String, double>> getSavingsBuckets(String userId) {
    return stream().map((docs) {
      final buckets = <String, double>{};
      for (var doc in docs) {
        if (doc['userId'] == userId) {
          buckets[doc['name']] = (doc['amount'] as num).toDouble();
        }
      }
      return buckets;
    });
  }

  // Add or update a savings bucket
  Future<void> updateSavingsBucket(String userId, String bucketName, double amount) async {
    final existingDocs = await query(
      field: 'userId',
      isEqualTo: userId,
    ).then((docs) => docs.where((doc) => doc['name'] == bucketName).toList());

    if (existingDocs.isEmpty) {
      // Create new bucket
      await create({
        'userId': userId,
        'name': bucketName,
        'amount': amount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing bucket
      await update(existingDocs.first.id, {
        'amount': amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Delete a savings bucket
  Future<void> deleteSavingsBucket(String userId, String bucketName) async {
    final existingDocs = await query(
      field: 'userId',
      isEqualTo: userId,
    ).then((docs) => docs.where((doc) => doc['name'] == bucketName).toList());

    if (existingDocs.isNotEmpty) {
      await delete(existingDocs.first.id);
    }
  }
} 