import 'package:cloud_firestore/cloud_firestore.dart';

class GroupExpense {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> participants;
  final Map<String, double> splits;
  final List<Map<String, dynamic>> suggestions;
  final String status;
  final String? name;
  final List<String>? members;
  final String? groupDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupExpense({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.participants,
    required this.splits,
    required this.suggestions,
    required this.status,
    this.name,
    this.members,
    this.groupDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupExpense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupExpense(
      id: doc.id,
      groupId: data['groupId'] as String,
      description: data['description'] as String,
      amount: (data['amount'] as num).toDouble(),
      paidBy: data['paidBy'] as String,
      participants: List<String>.from(data['participants'] as List),
      splits: Map<String, double>.from(data['splits'] ?? {}),
      suggestions: List<Map<String, dynamic>>.from(data['suggestions'] ?? []),
      status: data['status'] ?? 'pending',
      name: data['name'],
      members: data['members'] != null ? List<String>.from(data['members']) : null,
      groupDescription: data['groupDescription'],
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
      'splits': splits,
      'suggestions': suggestions,
      'status': status,
      'name': name,
      'members': members,
      'groupDescription': groupDescription,
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
    Map<String, double>? splits,
    List<Map<String, dynamic>>? suggestions,
    String? status,
    String? name,
    List<String>? members,
    String? groupDescription,
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
      splits: splits ?? this.splits,
      suggestions: suggestions ?? this.suggestions,
      status: status ?? this.status,
      name: name ?? this.name,
      members: members ?? this.members,
      groupDescription: groupDescription ?? this.groupDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 