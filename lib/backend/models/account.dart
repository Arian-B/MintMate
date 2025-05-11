import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType {
  bank,
  crypto,
  stock,
  cash,
  paypal,
  other
}

class Account {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? accountNumber;
  final String? institutionName;
  final bool isActive;
  final DateTime lastSync;
  final Map<String, dynamic> metadata;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.accountNumber,
    this.institutionName,
    required this.isActive,
    required this.lastSync,
    required this.metadata,
  });

  factory Account.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Account(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.toString() == 'AccountType.${data['type']}',
        orElse: () => AccountType.other,
      ),
      balance: (data['balance'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'INR',
      accountNumber: data['accountNumber'],
      institutionName: data['institutionName'],
      isActive: data['isActive'] ?? true,
      lastSync: (data['lastSync'] as Timestamp).toDate(),
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type.toString().split('.').last,
      'balance': balance,
      'currency': currency,
      'accountNumber': accountNumber,
      'institutionName': institutionName,
      'isActive': isActive,
      'lastSync': Timestamp.fromDate(lastSync),
      'metadata': metadata,
    };
  }

  Account copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    String? accountNumber,
    String? institutionName,
    bool? isActive,
    DateTime? lastSync,
    Map<String, dynamic>? metadata,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      accountNumber: accountNumber ?? this.accountNumber,
      institutionName: institutionName ?? this.institutionName,
      isActive: isActive ?? this.isActive,
      lastSync: lastSync ?? this.lastSync,
      metadata: metadata ?? this.metadata,
    );
  }
} 