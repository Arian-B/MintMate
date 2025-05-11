import 'package:cloud_firestore/cloud_firestore.dart';

class GroupExpense {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> participants;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupExpense({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupExpense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupExpense(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      paidBy: data['paidBy'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'description': description,
      'amount': amount,
      'paidBy': paidBy,
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  GroupExpense copyWith({
    String? id,
    String? groupId,
    String? description,
    double? amount,
    String? paidBy,
    List<String>? participants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupExpense(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 