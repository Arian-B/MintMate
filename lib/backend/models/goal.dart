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
  final String category;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final GoalStatus status;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    this.lastUpdated,
    this.status = GoalStatus.notStarted,
  });

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? lastUpdated,
    GoalStatus? status,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'status': status.toString().split('.').last,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map, String id) {
    return Goal(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
      status: GoalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => GoalStatus.notStarted,
      ),
    );
  }

  @override
  String toString() {
    return 'Goal(id: $id, userId: $userId, title: $title, description: $description, '
        'category: $category, targetAmount: $targetAmount, currentAmount: $currentAmount, '
        'targetDate: $targetDate, createdAt: $createdAt, lastUpdated: $lastUpdated, '
        'status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.targetDate == targetDate &&
        other.createdAt == createdAt &&
        other.lastUpdated == lastUpdated &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        category.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        targetDate.hashCode ^
        createdAt.hashCode ^
        lastUpdated.hashCode ^
        status.hashCode;
  }

  double get progressPercentage => (currentAmount / targetAmount) * 100;
  bool get isCompleted => status == GoalStatus.completed;
  bool get isFailed => status == GoalStatus.failed;
  bool get isActive => status == GoalStatus.inProgress;
  Duration get remainingTime => targetDate.difference(DateTime.now());
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;
} 