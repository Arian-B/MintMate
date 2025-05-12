import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_service.dart';
import 'package:crypto/crypto.dart';
import 'security_service.dart';

class PlatformIntegrationService extends BaseService {
  final SecurityService _securityService = SecurityService();

  PlatformIntegrationService() : super(FirebaseFirestore.instance, 'platform_integrations');

  // Encryption methods
  String encryptData(String data) {
    return _securityService.encryptData(data);
  }

  String decryptData(String encryptedData) {
    return _securityService.decryptData(encryptedData);
  }

  @override
  Map<String, dynamic> fromFirestore(DocumentSnapshot doc) {
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> toFirestore(dynamic model) {
    return model as Map<String, dynamic>;
  }

  // Bank Account Integration
  Future<Map<String, dynamic>> connectBankAccount(String userId, String bankName, String accountNumber) async {
    try {
      // TODO: Replace with actual bank API integration
      final response = await http.post(
        Uri.parse('https://api.bank.com/connect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'bankName': bankName,
          'accountNumber': accountNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await create({
          'userId': userId,
          'type': 'bank',
          'bankName': bankName,
          'accountNumber': accountNumber,
          'balance': data['balance'],
          'lastSync': DateTime.now(),
        });
        return data;
      } else {
        throw Exception('Failed to connect bank account');
      }
    } catch (e) {
      throw Exception('Error connecting bank account: $e');
    }
  }

  // Crypto Wallet Integration
  Future<Map<String, dynamic>> connectCryptoWallet(String userId, String walletAddress, String network) async {
    try {
      // TODO: Replace with actual blockchain API integration
      final response = await http.get(
        Uri.parse('https://api.blockchain.com/balance/$walletAddress'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await create({
          'userId': userId,
          'type': 'crypto',
          'walletAddress': walletAddress,
          'network': network,
          'balance': data['balance'],
          'lastSync': DateTime.now(),
        });
        return data;
      } else {
        throw Exception('Failed to connect crypto wallet');
      }
    } catch (e) {
      throw Exception('Error connecting crypto wallet: $e');
    }
  }

  // Stock Broker Integration
  Future<Map<String, dynamic>> connectStockBroker(String userId, String brokerName, String apiKey) async {
    try {
      // TODO: Replace with actual broker API integration
      final response = await http.post(
        Uri.parse('https://api.broker.com/connect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'brokerName': brokerName,
          'apiKey': apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await create({
          'userId': userId,
          'type': 'stock',
          'brokerName': brokerName,
          'portfolio': data['portfolio'],
          'lastSync': DateTime.now(),
        });
        return data;
      } else {
        throw Exception('Failed to connect stock broker');
      }
    } catch (e) {
      throw Exception('Error connecting stock broker: $e');
    }
  }

  // Get aggregated balances
  Future<Map<String, dynamic>> getAggregatedBalances(String userId) async {
    try {
      final integrations = await query(field: 'userId', isEqualTo: userId);
      double totalBalance = 0;
      Map<String, double> balances = {};

      for (var integration in integrations) {
        final type = integration['type'] as String;
        final balance = integration['balance'] as double;
        balances[type] = balance;
        totalBalance += balance;
      }

      return {
        'totalBalance': totalBalance,
        'balances': balances,
        'lastSync': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Error getting aggregated balances: $e');
    }
  }

  // Sync all accounts
  Future<void> syncAllAccounts(String userId) async {
    try {
      final integrations = await query(field: 'userId', isEqualTo: userId);
      
      for (var integration in integrations) {
        final type = integration['type'] as String;
        switch (type) {
          case 'bank':
            await _syncBankAccount(integration);
            break;
          case 'crypto':
            await _syncCryptoWallet(integration);
            break;
          case 'stock':
            await _syncStockBroker(integration);
            break;
        }
      }
    } catch (e) {
      throw Exception('Error syncing accounts: $e');
    }
  }

  Future<void> _syncBankAccount(Map<String, dynamic> integration) async {
    // TODO: Implement real bank sync
  }

  Future<void> _syncCryptoWallet(Map<String, dynamic> integration) async {
    // TODO: Implement real crypto sync
  }

  Future<void> _syncStockBroker(Map<String, dynamic> integration) async {
    // TODO: Implement real stock sync
  }

  // Coinbase Integration
  Future<Map<String, dynamic>> connectCoinbaseWallet(
    String userId,
    String apiKey,
    String apiSecret,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateCoinbaseSignature(timestamp, apiSecret);

      final response = await http.get(
        Uri.parse('https://api.coinbase.com/v2/accounts'),
        headers: {
          'CB-ACCESS-KEY': apiKey,
          'CB-ACCESS-SIGN': signature,
          'CB-ACCESS-TIMESTAMP': timestamp.toString(),
          'CB-VERSION': '2021-04-08',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accounts = data['data'] as List;
        
        // Store encrypted credentials
        final encryptedApiKey = encryptData(apiKey);
        final encryptedApiSecret = encryptData(apiSecret);

        await create({
          'userId': userId,
          'type': 'crypto',
          'platform': 'coinbase',
          'accounts': accounts,
          'apiKey': encryptedApiKey,
          'apiSecret': encryptedApiSecret,
          'lastSync': DateTime.now(),
        });

        return {
          'success': true,
          'accounts': accounts,
        };
      } else {
        throw Exception('Failed to connect Coinbase wallet');
      }
    } catch (e) {
      throw Exception('Error connecting Coinbase wallet: $e');
    }
  }

  // Binance Integration
  Future<Map<String, dynamic>> connectBinanceWallet(
    String userId,
    String apiKey,
    String apiSecret,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryString = 'timestamp=$timestamp';
      final signature = _generateBinanceSignature(queryString, apiSecret);

      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/account?$queryString&signature=$signature'),
        headers: {
          'X-MBX-APIKEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balances = data['balances'] as List;
        
        // Store encrypted credentials
        final encryptedApiKey = encryptData(apiKey);
        final encryptedApiSecret = encryptData(apiSecret);

        await create({
          'userId': userId,
          'type': 'crypto',
          'platform': 'binance',
          'balances': balances,
          'apiKey': encryptedApiKey,
          'apiSecret': encryptedApiSecret,
          'lastSync': DateTime.now(),
        });

        return {
          'success': true,
          'balances': balances,
        };
      } else {
        throw Exception('Failed to connect Binance wallet');
      }
    } catch (e) {
      throw Exception('Error connecting Binance wallet: $e');
    }
  }

  // Zerodha Integration
  Future<Map<String, dynamic>> connectZerodhaAccount(
    String userId,
    String apiKey,
    String apiSecret,
    String requestToken,
  ) async {
    try {
      // Generate session token
      final response = await http.post(
        Uri.parse('https://api.kite.trade/session/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_key': apiKey,
          'request_token': requestToken,
          'checksum': _generateZerodhaChecksum(apiKey, requestToken, apiSecret),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        
        // Get portfolio
        final portfolioResponse = await http.get(
          Uri.parse('https://api.kite.trade/portfolio'),
          headers: {
            'Authorization': 'token $apiKey:$accessToken',
          },
        );

        if (portfolioResponse.statusCode == 200) {
          final portfolioData = jsonDecode(portfolioResponse.body);
          
          // Store encrypted credentials
          final encryptedApiKey = encryptData(apiKey);
          final encryptedApiSecret = encryptData(apiSecret);
          final encryptedAccessToken = encryptData(accessToken);

          await create({
            'userId': userId,
            'type': 'stock',
            'platform': 'zerodha',
            'portfolio': portfolioData,
            'apiKey': encryptedApiKey,
            'apiSecret': encryptedApiSecret,
            'accessToken': encryptedAccessToken,
            'lastSync': DateTime.now(),
          });

          return {
            'success': true,
            'portfolio': portfolioData,
          };
        } else {
          throw Exception('Failed to fetch Zerodha portfolio');
        }
      } else {
        throw Exception('Failed to connect Zerodha account');
      }
    } catch (e) {
      throw Exception('Error connecting Zerodha account: $e');
    }
  }

  // Helper methods for API signatures
  String _generateCoinbaseSignature(int timestamp, String apiSecret) {
    final message = timestamp.toString();
    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmac.convert(utf8.encode(message));
    return digest.toString();
  }

  String _generateBinanceSignature(String queryString, String apiSecret) {
    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmac.convert(utf8.encode(queryString));
    return digest.toString();
  }

  String _generateZerodhaChecksum(String apiKey, String requestToken, String apiSecret) {
    final message = '$apiKey$requestToken$apiSecret';
    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmac.convert(utf8.encode(message));
    return digest.toString();
  }

  // Sync methods for each platform
  Future<void> _syncCoinbaseWallet(Map<String, dynamic> integration) async {
    try {
      final apiKey = decryptData(integration['apiKey']);
      final apiSecret = decryptData(integration['apiSecret']);
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateCoinbaseSignature(timestamp, apiSecret);

      final response = await http.get(
        Uri.parse('https://api.coinbase.com/v2/accounts'),
        headers: {
          'CB-ACCESS-KEY': apiKey,
          'CB-ACCESS-SIGN': signature,
          'CB-ACCESS-TIMESTAMP': timestamp.toString(),
          'CB-VERSION': '2021-04-08',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await update(integration['id'], {
          'accounts': data['data'],
          'lastSync': DateTime.now(),
        });
      }
    } catch (e) {
      throw Exception('Error syncing Coinbase wallet: $e');
    }
  }

  Future<void> _syncBinanceWallet(Map<String, dynamic> integration) async {
    try {
      final apiKey = decryptData(integration['apiKey']);
      final apiSecret = decryptData(integration['apiSecret']);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryString = 'timestamp=$timestamp';
      final signature = _generateBinanceSignature(queryString, apiSecret);

      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/account?$queryString&signature=$signature'),
        headers: {
          'X-MBX-APIKEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await update(integration['id'], {
          'balances': data['balances'],
          'lastSync': DateTime.now(),
        });
      }
    } catch (e) {
      throw Exception('Error syncing Binance wallet: $e');
    }
  }

  Future<void> _syncZerodhaAccount(Map<String, dynamic> integration) async {
    try {
      final apiKey = decryptData(integration['apiKey']);
      final accessToken = decryptData(integration['accessToken']);

      final response = await http.get(
        Uri.parse('https://api.kite.trade/portfolio'),
        headers: {
          'Authorization': 'token $apiKey:$accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await update(integration['id'], {
          'portfolio': data,
          'lastSync': DateTime.now(),
        });
      }
    } catch (e) {
      throw Exception('Error syncing Zerodha account: $e');
    }
  }
} 