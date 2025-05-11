import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String type; // e.g. 'bill', 'goal', 'custom'
  final bool isRecurring;
  final String? recurringPeriod; // e.g. 'daily', 'weekly', 'monthly'
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.dateTime,
    required this.type,
    required this.isRecurring,
    this.recurringPeriod,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      type: data['type'] ?? 'custom',
      isRecurring: data['isRecurring'] ?? false,
      recurringPeriod: data['recurringPeriod'],
      isEnabled: data['isEnabled'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'type': type,
      'isRecurring': isRecurring,
      'recurringPeriod': recurringPeriod,
      'isEnabled': isEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? type,
    bool? isRecurring,
    String? recurringPeriod,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 