import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsBucket {
  final String id;
  final String userId;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime targetDate;
  final DateTime? completedDate;
  final List<String> relatedAccountIds;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsBucket({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.targetDate,
    this.completedDate,
    required this.relatedAccountIds,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingsBucket.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingsBucket(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'INR',
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      completedDate: data['completedDate'] != null
          ? (data['completedDate'] as Timestamp).toDate()
          : null,
      relatedAccountIds: List<String>.from(data['relatedAccountIds'] ?? []),
      metadata: data['metadata'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'targetDate': Timestamp.fromDate(targetDate),
      'completedDate': completedDate != null
          ? Timestamp.fromDate(completedDate!)
          : null,
      'relatedAccountIds': relatedAccountIds,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SavingsBucket copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? targetDate,
    DateTime? completedDate,
    List<String>? relatedAccountIds,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsBucket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      completedDate: completedDate ?? this.completedDate,
      relatedAccountIds: relatedAccountIds ?? this.relatedAccountIds,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progressPercentage => (currentAmount / targetAmount) * 100;
  bool get isCompleted => currentAmount >= targetAmount;
  Duration get remainingTime => targetDate.difference(DateTime.now());
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;
} 