import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String frequency; // e.g. 'monthly', 'yearly', 'weekly'
  final bool isActive;
  final bool isPaid;
  final DateTime? lastPaidDate;
  final String? category;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.frequency,
    required this.isActive,
    required this.isPaid,
    this.lastPaidDate,
    this.category,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Bill(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      frequency: data['frequency'] ?? 'monthly',
      isActive: data['isActive'] ?? true,
      isPaid: data['isPaid'] ?? false,
      lastPaidDate: data['lastPaidDate'] != null ? (data['lastPaidDate'] as Timestamp).toDate() : null,
      category: data['category'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'frequency': frequency,
      'isActive': isActive,
      'isPaid': isPaid,
      'lastPaidDate': lastPaidDate != null ? Timestamp.fromDate(lastPaidDate!) : null,
      'category': category,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Bill copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    DateTime? dueDate,
    String? frequency,
    bool? isActive,
    bool? isPaid,
    DateTime? lastPaidDate,
    String? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      isPaid: isPaid ?? this.isPaid,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 