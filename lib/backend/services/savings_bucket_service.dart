import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/savings_bucket.dart';
import 'base_service.dart';

class SavingsBucketService extends BaseService<SavingsBucket> {
  SavingsBucketService() : super(FirebaseFirestore.instance, 'savings_buckets');

  @override
  SavingsBucket fromFirestore(DocumentSnapshot doc) {
    return SavingsBucket.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(SavingsBucket model) {
    return model.toFirestore();
  }

  // Get all savings buckets for a user
  Stream<List<SavingsBucket>> getBucketsForUser(String userId) {
    return stream().map((buckets) => 
      buckets.where((b) => b.userId == userId).toList());
  }

  // Create a new savings bucket
  Future<SavingsBucket> createBucket(SavingsBucket bucket) async {
    return create(bucket);
  }

  // Update a savings bucket
  Future<SavingsBucket> updateBucket(SavingsBucket bucket) async {
    return update(bucket.id, bucket);
  }

  // Delete a savings bucket
  Future<void> deleteBucket(String bucketId) async {
    await delete(bucketId);
  }

  // Add amount to a savings bucket
  Future<SavingsBucket> addAmount(String bucketId, double amount) async {
    final bucket = await get(bucketId);
    if (bucket == null) throw Exception('Bucket not found');
    
    final updatedBucket = bucket.copyWith(
      currentAmount: bucket.currentAmount + amount,
      updatedAt: DateTime.now(),
    );
    
    return update(bucketId, updatedBucket);
  }

  // Get savings statistics
  Future<Map<String, dynamic>> getSavingsStats(String userId) async {
    final buckets = await query(field: 'userId', isEqualTo: userId);
    
    double totalTarget = 0;
    double totalSaved = 0;
    int completedBuckets = 0;
    int overdueBuckets = 0;
    
    for (var bucket in buckets) {
      totalTarget += bucket.targetAmount;
      totalSaved += bucket.currentAmount;
      if (bucket.isCompleted) completedBuckets++;
      if (bucket.isOverdue) overdueBuckets++;
    }
    
    return {
      'totalTarget': totalTarget,
      'totalSaved': totalSaved,
      'completionRate': totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0,
      'completedBuckets': completedBuckets,
      'overdueBuckets': overdueBuckets,
      'totalBuckets': buckets.length,
    };
  }

  // Get AI recommendations for savings
  Future<Map<String, dynamic>> getSavingsRecommendations(String userId) async {
    final buckets = await query(field: 'userId', isEqualTo: userId);
    // Calculate monthly savings rate
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final monthlySavings = buckets.fold(0.0, (sum, bucket) {
      if (bucket.updatedAt.isAfter(firstDayOfMonth)) {
        return sum + (bucket.currentAmount - (bucket.metadata['lastMonthAmount'] ?? 0.0));
      }
      return sum;
    });
    
    // Generate recommendations based on savings patterns
    final recommendations = {
      'monthlySavings': monthlySavings,
      'suggestedMonthlyTarget': monthlySavings * 1.2, // 20% increase
      'suggestedBuckets': [],
      'tips': [],
    };
    
    // Add bucket-specific recommendations
    for (var bucket in buckets) {
      if (bucket.isOverdue) {
        (recommendations['tips'] as List).add(
          'Consider adjusting your target for ${bucket.name} or extending the deadline.'
        );
      }
      
      if (bucket.progressPercentage < 50 && bucket.remainingTime.inDays < 30) {
        (recommendations['tips'] as List).add(
          'You might need to increase your savings rate for ${bucket.name} to meet your target.'
        );
      }
    }
    
    return recommendations;
  }
} 