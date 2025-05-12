import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'base_service.dart';

class SecurityService extends BaseService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  late encrypt.Encrypter _encrypter;
  late encrypt.Key _encryptionKey;
  late encrypt.IV _encryptionIV;
  
  // Constants for rate limiting
  static const int _maxAuthAttempts = 5;
  static const Duration _authLockoutDuration = Duration(minutes: 15);
  
  SecurityService() : super(FirebaseFirestore.instance, 'security_logs') {
    _initializeEncryption();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notifications.initialize(initSettings);
  }

  Future<void> _initializeEncryption() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedKey = prefs.getString('encryption_key');
    String? storedIV = prefs.getString('encryption_iv');
    
    if (storedKey == null || storedIV == null) {
      _encryptionKey = encrypt.Key.fromSecureRandom(32);
      _encryptionIV = encrypt.IV.fromSecureRandom(16);
      await prefs.setString('encryption_key', _encryptionKey.base64);
      await prefs.setString('encryption_iv', _encryptionIV.base64);
    } else {
      _encryptionKey = encrypt.Key.fromBase64(storedKey);
      _encryptionIV = encrypt.IV.fromBase64(storedIV);
    }
    
    _encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc),
    );
  }

  @override
  Map<String, dynamic> fromFirestore(DocumentSnapshot doc) {
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> toFirestore(dynamic model) {
    return model as Map<String, dynamic>;
  }

  // Rate limiting for authentication
  Future<bool> _checkAuthAttempts(String userId) async {
    final attempts = await FirebaseFirestore.instance
        .collection('auth_attempts')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: DateTime.now().subtract(_authLockoutDuration))
        .get();

    if (attempts.docs.length >= _maxAuthAttempts) {
      await logSecurityEvent(
        userId,
        'auth_locked_out',
        {'reason': 'Too many failed attempts'},
      );
      return false;
    }
    return true;
  }

  // Enhanced biometric authentication with rate limiting
  Future<bool> authenticateWithBiometrics(String userId) async {
    try {
      if (!await _checkAuthAttempts(userId)) {
        throw Exception('Account temporarily locked. Please try again later.');
      }

      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return false;
      }

      final success = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access MintMate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!success) {
        await FirebaseFirestore.instance.collection('auth_attempts').add({
          'userId': userId,
          'timestamp': DateTime.now(),
          'success': false,
        });
      }

      return success;
    } catch (e) {
      throw Exception('Error during biometric authentication: $e');
    }
  }

  // Device fingerprinting
  Future<Map<String, dynamic>> getDeviceFingerprint() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'deviceId': androidInfo.id,
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'deviceId': iosInfo.identifierForVendor,
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
        };
      }
      throw Exception('Unsupported platform');
    } catch (e) {
      throw Exception('Error getting device fingerprint: $e');
    }
  }

  // Enhanced encryption with key rotation
  Future<void> rotateEncryptionKey() async {
    try {
      final newKey = encrypt.Key.fromSecureRandom(32);
      final newIV = encrypt.IV.fromSecureRandom(16);
      
      // Store old key for re-encryption
      final oldKey = _encryptionKey;
      final oldIV = _encryptionIV;
      
      // Update current key and IV
      _encryptionKey = newKey;
      _encryptionIV = newIV;
      _encrypter = encrypt.Encrypter(
        encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc),
      );
      
      // Save new key and IV
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('encryption_key', _encryptionKey.base64);
      await prefs.setString('encryption_iv', _encryptionIV.base64);
      
      // Re-encrypt sensitive data with new key
      await _reEncryptSensitiveData(oldKey, oldIV);
    } catch (e) {
      throw Exception('Error rotating encryption key: $e');
    }
  }

  Future<void> _reEncryptSensitiveData(encrypt.Key oldKey, encrypt.IV oldIV) async {
    // Implementation for re-encrypting existing data with new key
    // This would typically involve fetching all encrypted data and re-encrypting it
  }

  // Privacy controls
  Future<void> updatePrivacySettings(String userId, Map<String, dynamic> settings) async {
    try {
      await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userId)
          .update({
        'privacySettings': settings,
        'lastUpdated': DateTime.now(),
      });

      await logSecurityEvent(
        userId,
        'privacy_settings_updated',
        {'settings': settings},
      );
    } catch (e) {
      throw Exception('Error updating privacy settings: $e');
    }
  }

  Future<Map<String, dynamic>> getPrivacySettings(String userId) async {
    try {
      final settings = await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userId)
          .get();

      return settings.data()?['privacySettings'] ?? {
        'shareTransactionHistory': false,
        'shareLocationData': false,
        'shareAnalytics': false,
        'shareWithPartners': false,
      };
    } catch (e) {
      throw Exception('Error getting privacy settings: $e');
    }
  }

  // Encrypt sensitive data
  String encryptData(String data) {
    try {
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypted = _encrypter.encrypt(data, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Error encrypting data: $e');
    }
  }

  // Decrypt sensitive data
  String decryptData(String encryptedData) {
    try {
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Error decrypting data: $e');
    }
  }

  // Detect anomalies in user activity
  Future<Map<String, dynamic>> detectAnomalies(String userId) async {
    try {
      // Get user's recent activity
      final activities = await FirebaseFirestore.instance
          .collection('user_activities')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      // Prepare data for anomaly detection
      final activityData = activities.docs.map((doc) => doc.data()).toList();

      // Call AI service for anomaly detection
      final response = await http.post(
        Uri.parse('https://api.ai-service.com/detect-anomalies'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'activities': activityData,
        }),
      );

      if (response.statusCode == 200) {
        final anomalies = jsonDecode(response.body);
        await create({
          'userId': userId,
          'type': 'anomaly_detection',
          'anomalies': anomalies,
          'timestamp': DateTime.now(),
        });
        return anomalies;
      } else {
        throw Exception('Failed to detect anomalies');
      }
    } catch (e) {
      throw Exception('Error detecting anomalies: $e');
    }
  }

  // Log security events
  Future<void> logSecurityEvent(
    String userId,
    String eventType,
    Map<String, dynamic> eventData,
  ) async {
    try {
      await create({
        'userId': userId,
        'type': eventType,
        'data': eventData,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Error logging security event: $e');
    }
  }

  // Check for suspicious activities
  Future<bool> checkSuspiciousActivity(String userId) async {
    try {
      final anomalies = await detectAnomalies(userId);
      return anomalies['hasSuspiciousActivity'] ?? false;
    } catch (e) {
      throw Exception('Error checking suspicious activity: $e');
    }
  }

  // Enhanced Smart Alerts
  Future<List<Map<String, dynamic>>> generateSmartAlerts(String userId) async {
    try {
      final alerts = <Map<String, dynamic>>[];
      
      // Get user's recent transactions
      final transactions = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      // Analyze spending patterns
      final spendingAlerts = await _analyzeSpendingPatterns(transactions.docs);
      alerts.addAll(spendingAlerts);

      // Check subscription renewals
      final subscriptionAlerts = await _checkSubscriptionRenewals(userId);
      alerts.addAll(subscriptionAlerts);

      // Check budget limits
      final budgetAlerts = await _checkBudgetLimits(userId);
      alerts.addAll(budgetAlerts);

      // Store alerts
      for (var alert in alerts) {
        await create({
          'userId': userId,
          'type': 'smart_alert',
          'data': alert,
          'timestamp': DateTime.now(),
          'read': false,
        });
      }

      // Send notifications for high-priority alerts
      for (var alert in alerts) {
        if (alert['priority'] == 'high') {
          await _sendNotification(alert['title'], alert['message']);
        }
      }

      return alerts;
    } catch (e) {
      throw Exception('Error generating smart alerts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _analyzeSpendingPatterns(List<DocumentSnapshot> transactions) async {
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    // Group transactions by category
    final categorySpending = <String, double>{};
    final lastWeekCategorySpending = <String, double>{};
    
    for (var doc in transactions) {
      final transaction = doc.data() as Map<String, dynamic>;
      final category = transaction['category'] as String;
      final amount = (transaction['amount'] as num).toDouble();
      final timestamp = (transaction['timestamp'] as Timestamp).toDate();
      
      categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      
      if (timestamp.isAfter(weekAgo)) {
        lastWeekCategorySpending[category] = (lastWeekCategorySpending[category] ?? 0) + amount;
      }
    }
    
    // Compare with last week's spending
    for (var category in categorySpending.keys) {
      final currentSpending = categorySpending[category]!;
      final lastWeekSpending = lastWeekCategorySpending[category] ?? 0;
      
      if (lastWeekSpending > 0) {
        final percentageChange = ((currentSpending - lastWeekSpending) / lastWeekSpending) * 100;
        
        if (percentageChange > 30) {
          alerts.add({
            'type': 'spending_increase',
            'title': 'Spending Alert',
            'message': 'Your spending on $category is ${percentageChange.toStringAsFixed(0)}% higher this week',
            'priority': 'high',
            'category': category,
            'percentageChange': percentageChange,
          });
        }
      }
    }
    
    return alerts;
  }

  Future<List<Map<String, dynamic>>> _checkSubscriptionRenewals(String userId) async {
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    // Get user's subscriptions
    final subscriptions = await FirebaseFirestore.instance
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .get();
    
    for (var doc in subscriptions.docs) {
      final subscription = doc.data();
      final renewalDate = (subscription['renewalDate'] as Timestamp).toDate();
      final daysUntilRenewal = renewalDate.difference(now).inDays;
      
      if (daysUntilRenewal <= 1) {
        alerts.add({
          'type': 'subscription_renewal',
          'title': 'Subscription Renewal',
          'message': 'Your subscription to ${subscription['name']} renews tomorrow',
          'priority': 'high',
          'subscriptionId': doc.id,
          'amount': subscription['amount'],
        });
      }
    }
    
    return alerts;
  }

  Future<List<Map<String, dynamic>>> _checkBudgetLimits(String userId) async {
    final alerts = <Map<String, dynamic>>[];
    
    // Get user's budget settings
    final budgetSettings = await FirebaseFirestore.instance
        .collection('user_settings')
        .doc(userId)
        .get();
    
    final budgets = budgetSettings.data()?['budgets'] as Map<String, dynamic>? ?? {};
    
    // Get current month's spending
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    final transactions = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(monthStart))
        .get();
    
    // Calculate spending by category
    final categorySpending = <String, double>{};
    for (var doc in transactions.docs) {
      final transaction = doc.data();
      final category = transaction['category'] as String;
      final amount = (transaction['amount'] as num).toDouble();
      categorySpending[category] = (categorySpending[category] ?? 0) + amount;
    }
    
    // Check against budget limits
    for (var category in budgets.keys) {
      final budget = (budgets[category] as num).toDouble();
      final spending = categorySpending[category] ?? 0;
      
      if (spending >= budget * 0.9) {
        alerts.add({
          'type': 'budget_limit',
          'title': 'Budget Alert',
          'message': 'You\'ve used ${(spending / budget * 100).toStringAsFixed(0)}% of your $category budget',
          'priority': 'medium',
          'category': category,
          'spending': spending,
          'budget': budget,
        });
      }
    }
    
    return alerts;
  }

  Future<void> _sendNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'smart_alerts',
      'Smart Alerts',
      channelDescription: 'Notifications for smart alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  // Enhanced Spending Freeze Mode
  Future<Map<String, dynamic>> getSpendingFreezeRecommendation(String userId) async {
    try {
      final transactions = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();
      
      final dailySpending = <DateTime, double>{};
      for (var doc in transactions.docs) {
        final transaction = doc.data();
        final date = (transaction['timestamp'] as Timestamp).toDate();
        final amount = (transaction['amount'] as num).toDouble();
        
        final day = DateTime(date.year, date.month, date.day);
        dailySpending[day] = (dailySpending[day] ?? 0) + amount;
      }
      
      // Calculate average daily spending
      final totalSpending = dailySpending.values.fold<double>(0, (sum, amount) => sum + amount);
      final averageSpending = totalSpending / dailySpending.length;
      
      // Get budget settings
      final settings = await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userId)
          .get();
      
      final monthlyBudget = (settings.data()?['monthlyBudget'] as num?)?.toDouble() ?? 0;
      final dailyBudget = monthlyBudget / 30;
      
      // Calculate recommendation
      final shouldFreeze = averageSpending > dailyBudget * 1.2;
      final freezeDuration = shouldFreeze ? const Duration(days: 3) : null;
      
      return {
        'shouldFreeze': shouldFreeze,
        'reason': shouldFreeze ? 'Your daily spending is ${((averageSpending / dailyBudget - 1) * 100).toStringAsFixed(0)}% above budget' : null,
        'recommendedDuration': freezeDuration,
        'averageSpending': averageSpending,
        'dailyBudget': dailyBudget,
      };
    } catch (e) {
      throw Exception('Error getting spending freeze recommendation: $e');
    }
  }

  // Enhanced toggle spending freeze with AI recommendation
  Future<void> toggleSpendingFreeze(String userId, {bool? enable}) async {
    try {
      final recommendation = await getSpendingFreezeRecommendation(userId);
      final shouldEnable = enable ?? recommendation['shouldFreeze'] as bool;
      
      await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userId)
          .update({
        'spendingFreeze': shouldEnable,
        'freezeReason': recommendation['reason'],
        'freezeDuration': recommendation['recommendedDuration']?.inDays,
        'lastUpdated': DateTime.now(),
      });

      await logSecurityEvent(
        userId,
        'spending_freeze_toggle',
        {
          'enabled': shouldEnable,
          'reason': recommendation['reason'],
          'duration': recommendation['recommendedDuration']?.inDays,
        },
      );

      if (shouldEnable) {
        await _sendNotification(
          'Spending Freeze Activated',
          recommendation['reason'] as String,
        );
      }
    } catch (e) {
      throw Exception('Error toggling spending freeze: $e');
    }
  }

  // Enhanced security status with new features
  Future<Map<String, dynamic>> getSecurityStatus(String userId) async {
    try {
      final settings = await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userId)
          .get();

      final anomalies = await detectAnomalies(userId);
      final deviceFingerprint = await getDeviceFingerprint();
      final privacySettings = await getPrivacySettings(userId);

      return {
        'biometricEnabled': settings.data()?['biometricEnabled'] ?? false,
        'spendingFreeze': settings.data()?['spendingFreeze'] ?? false,
        'hasSuspiciousActivity': anomalies['hasSuspiciousActivity'] ?? false,
        'lastSecurityCheck': DateTime.now(),
        'deviceFingerprint': deviceFingerprint,
        'privacySettings': privacySettings,
        'encryptionStatus': {
          'keyLastRotated': settings.data()?['keyLastRotated'] ?? DateTime.now(),
          'encryptionEnabled': true,
        },
      };
    } catch (e) {
      throw Exception('Error getting security status: $e');
    }
  }

  Future<void> checkSecurityStatus() async {
    // TODO: Implement security status check
    await Future.delayed(const Duration(milliseconds: 500)); // Placeholder
  }
} 