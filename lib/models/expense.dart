import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final String? receiptImageUrl;
  final bool isRecurring;
  final String? recurringPeriod;

  Expense({
    String? id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.receiptImageUrl,
    this.isRecurring = false,
    this.recurringPeriod,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'receiptImageUrl': receiptImageUrl,
      'isRecurring': isRecurring,
      'recurringPeriod': recurringPeriod,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      receiptImageUrl: map['receiptImageUrl'],
      isRecurring: map['isRecurring'],
      recurringPeriod: map['recurringPeriod'],
    );
  }
} 