import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalType {
  savings,
  debt,
  investment,
  expense,
  income,
  other
}

enum GoalStatus {
  notStarted,
  inProgress,
  completed,
  failed,
  paused
}

class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalType type;
  final GoalStatus status;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime startDate;
  final DateTime targetDate;
  final DateTime? completedDate;
  final List<String> relatedAccountIds;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.startDate,
    required this.targetDate,
    this.completedDate,
    required this.relatedAccountIds,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: GoalType.values.firstWhere(
        (e) => e.toString() == 'GoalType.${data['type']}',
        orElse: () => GoalType.other,
      ),
      status: GoalStatus.values.firstWhere(
        (e) => e.toString() == 'GoalStatus.${data['status']}',
        orElse: () => GoalStatus.notStarted,
      ),
      targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'INR',
      startDate: (data['startDate'] as Timestamp).toDate(),
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
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'startDate': Timestamp.fromDate(startDate),
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

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    GoalType? type,
    GoalStatus? status,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? startDate,
    DateTime? targetDate,
    DateTime? completedDate,
    List<String>? relatedAccountIds,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      completedDate: completedDate ?? this.completedDate,
      relatedAccountIds: relatedAccountIds ?? this.relatedAccountIds,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progressPercentage => (currentAmount / targetAmount) * 100;
  bool get isCompleted => status == GoalStatus.completed;
  bool get isFailed => status == GoalStatus.failed;
  bool get isActive => status == GoalStatus.inProgress;
  Duration get remainingTime => targetDate.difference(DateTime.now());
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;
} 