import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final Map<String, dynamic> preferences;
  final List<String> activeModules;
  final double totalNetWorth;
  final Map<String, double> accountBalances;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
    List<String>? activeModules,
    double? totalNetWorth,
    Map<String, double>? accountBalances,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    lastLogin = lastLogin ?? DateTime.now(),
    preferences = preferences ?? {},
    activeModules = activeModules ?? [],
    totalNetWorth = totalNetWorth ?? 0.0,
    accountBalances = accountBalances ?? {};

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: Map<String, dynamic>.from(data['preferences'] as Map? ?? {}),
      activeModules: List<String>.from(data['activeModules'] as List? ?? []),
      totalNetWorth: (data['totalNetWorth'] as num?)?.toDouble() ?? 0.0,
      accountBalances: Map<String, double>.from(
        (data['accountBalances'] as Map?)?.map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ) ?? {},
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'preferences': preferences,
      'activeModules': activeModules,
      'totalNetWorth': totalNetWorth,
      'accountBalances': accountBalances,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
    List<String>? activeModules,
    double? totalNetWorth,
    Map<String, double>? accountBalances,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
      activeModules: activeModules ?? this.activeModules,
      totalNetWorth: totalNetWorth ?? this.totalNetWorth,
      accountBalances: accountBalances ?? this.accountBalances,
    );
  }
} 