import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final String userId;
  final String? receiptImageUrl;
  final bool isRecurring;
  final String? recurringPeriod;
  final String? paymentMethod;
  final String? location;
  final List<String>? tags;

  Expense({
    String? id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.userId,
    this.receiptImageUrl,
    this.isRecurring = false,
    this.recurringPeriod,
    this.paymentMethod,
    this.location,
    this.tags,
  }) : id = id ?? const Uuid().v4();

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] as String,
      userId: data['userId'] as String,
      receiptImageUrl: data['receiptImageUrl'] as String?,
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurringPeriod: data['recurringPeriod'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      location: data['location'] as String?,
      tags: (data['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'description': description,
      'userId': userId,
      'receiptImageUrl': receiptImageUrl,
      'isRecurring': isRecurring,
      'recurringPeriod': recurringPeriod,
      'paymentMethod': paymentMethod,
      'location': location,
      'tags': tags,
    };
  }

  // For backward compatibility
  Map<String, dynamic> toMap() => toFirestore();

  // For backward compatibility
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date']),
      description: map['description'],
      userId: map['userId'],
      receiptImageUrl: map['receiptImageUrl'],
      isRecurring: map['isRecurring'] ?? false,
      recurringPeriod: map['recurringPeriod'],
      paymentMethod: map['paymentMethod'],
      location: map['location'],
      tags: map['tags'] != null 
          ? List<String>.from(map['tags'])
          : null,
    );
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    String? userId,
    bool? isRecurring,
    String? receiptImageUrl,
    String? recurringPeriod,
    String? paymentMethod,
    String? location,
    List<String>? tags,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      location: location ?? this.location,
      tags: tags ?? this.tags,
    );
  }
} 