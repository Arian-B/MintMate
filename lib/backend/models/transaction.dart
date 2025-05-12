import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  income,
  expense,
  transfer,
  investment,
  loan,
  other
}

enum TransactionCategory {
  // Income Categories
  salary,
  freelance,
  investment,
  gift,
  refund,
  otherIncome,

  // Expense Categories
  food,
  transportation,
  housing,
  utilities,
  entertainment,
  shopping,
  healthcare,
  education,
  travel,
  subscription,
  otherExpense,

  // Transfer Categories
  transferIn,
  transferOut,

  // Investment Categories
  stockPurchase,
  stockSale,
  cryptoPurchase,
  cryptoSale,
  otherInvestment,

  // Loan Categories
  loanPayment,
  loanReceived,
  interestPayment,
  otherLoan,

  // Other Categories
  other
}

class Transaction {
  final String id;
  final String userId;
  final String accountId;
  final String category;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final bool isRecurring;
  final String? recurringId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.category,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.isRecurring = false,
    this.recurringId,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? category,
    String? description,
    double? amount,
    TransactionType? type,
    DateTime? date,
    bool? isRecurring,
    String? recurringId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringId: recurringId ?? this.recurringId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'accountId': accountId,
      'category': category,
      'description': description,
      'amount': amount,
      'type': type.toString().split('.').last,
      'date': Timestamp.fromDate(date),
      'isRecurring': isRecurring,
      'recurringId': recurringId,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      userId: map['userId'] as String,
      accountId: map['accountId'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => TransactionType.expense,
      ),
      date: (map['date'] as Timestamp).toDate(),
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurringId: map['recurringId'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, userId: $userId, accountId: $accountId, '
        'category: $category, description: $description, amount: $amount, '
        'type: $type, date: $date, isRecurring: $isRecurring, '
        'recurringId: $recurringId, metadata: $metadata, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.userId == userId &&
        other.accountId == accountId &&
        other.category == category &&
        other.description == description &&
        other.amount == amount &&
        other.type == type &&
        other.date == date &&
        other.isRecurring == isRecurring &&
        other.recurringId == recurringId &&
        other.metadata == metadata &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        accountId.hashCode ^
        category.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        date.hashCode ^
        isRecurring.hashCode ^
        recurringId.hashCode ^
        metadata.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 