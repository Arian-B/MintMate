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
  final TransactionType type;
  final TransactionCategory category;
  final double amount;
  final String currency;
  final String description;
  final DateTime date;
  final String? recipientAccountId;
  final String? receiptUrl;
  final bool isRecurring;
  final String? recurringId;
  final Map<String, dynamic> metadata;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    this.recipientAccountId,
    this.receiptUrl,
    required this.isRecurring,
    this.recurringId,
    required this.metadata,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      accountId: data['accountId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${data['type']}',
        orElse: () => TransactionType.other,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == 'TransactionCategory.${data['category']}',
        orElse: () => TransactionCategory.other,
      ),
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'INR',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      recipientAccountId: data['recipientAccountId'],
      receiptUrl: data['receiptUrl'],
      isRecurring: data['isRecurring'] ?? false,
      recurringId: data['recurringId'],
      metadata: data['metadata'] ?? {},
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'accountId': accountId,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'amount': amount,
      'currency': currency,
      'description': description,
      'date': Timestamp.fromDate(date),
      'recipientAccountId': recipientAccountId,
      'receiptUrl': receiptUrl,
      'isRecurring': isRecurring,
      'recurringId': recurringId,
      'metadata': metadata,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    TransactionType? type,
    TransactionCategory? category,
    double? amount,
    String? currency,
    String? description,
    DateTime? date,
    String? recipientAccountId,
    String? receiptUrl,
    bool? isRecurring,
    String? recurringId,
    Map<String, dynamic>? metadata,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      recipientAccountId: recipientAccountId ?? this.recipientAccountId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringId: recurringId ?? this.recurringId,
      metadata: metadata ?? this.metadata,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 