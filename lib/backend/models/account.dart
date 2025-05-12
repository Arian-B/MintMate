import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String currency;
  final double balance;
  final String? description;
  final String? accountNumber;
  final String? institution;
  final bool isLinked;
  final Map<String, dynamic>? externalData;
  final DateTime? lastSynced;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
    this.description,
    this.accountNumber,
    this.institution,
    this.isLinked = false,
    this.externalData,
    this.lastSynced,
    required this.createdAt,
    this.updatedAt,
  });

  Account copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? currency,
    double? balance,
    String? description,
    String? accountNumber,
    String? institution,
    bool? isLinked,
    Map<String, dynamic>? externalData,
    DateTime? lastSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      accountNumber: accountNumber ?? this.accountNumber,
      institution: institution ?? this.institution,
      isLinked: isLinked ?? this.isLinked,
      externalData: externalData ?? this.externalData,
      lastSynced: lastSynced ?? this.lastSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'currency': currency,
      'balance': balance,
      'description': description,
      'accountNumber': accountNumber,
      'institution': institution,
      'isLinked': isLinked,
      'externalData': externalData,
      'lastSynced': lastSynced != null ? Timestamp.fromDate(lastSynced!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map, String id) {
    return Account(
      id: id,
      userId: map['userId'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      currency: map['currency'] as String,
      balance: (map['balance'] as num).toDouble(),
      description: map['description'] as String?,
      accountNumber: map['accountNumber'] as String?,
      institution: map['institution'] as String?,
      isLinked: map['isLinked'] as bool? ?? false,
      externalData: map['externalData'] as Map<String, dynamic>?,
      lastSynced: map['lastSynced'] != null
          ? (map['lastSynced'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, userId: $userId, name: $name, type: $type, '
        'currency: $currency, balance: $balance, description: $description, '
        'accountNumber: $accountNumber, institution: $institution, '
        'isLinked: $isLinked, externalData: $externalData, '
        'lastSynced: $lastSynced, createdAt: $createdAt, '
        'updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.type == type &&
        other.currency == currency &&
        other.balance == balance &&
        other.description == description &&
        other.accountNumber == accountNumber &&
        other.institution == institution &&
        other.isLinked == isLinked &&
        other.externalData == externalData &&
        other.lastSynced == lastSynced &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        type.hashCode ^
        currency.hashCode ^
        balance.hashCode ^
        description.hashCode ^
        accountNumber.hashCode ^
        institution.hashCode ^
        isLinked.hashCode ^
        externalData.hashCode ^
        lastSynced.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 