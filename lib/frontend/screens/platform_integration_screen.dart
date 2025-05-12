import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/platform_integration_service.dart';
import 'package:mintmate/backend/services/auth_service.dart';

class PlatformIntegrationScreen extends StatefulWidget {
  const PlatformIntegrationScreen({super.key});

  @override
  State<PlatformIntegrationScreen> createState() => _PlatformIntegrationScreenState();
}

class _PlatformIntegrationScreenState extends State<PlatformIntegrationScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _integrations = [];
  final _platformService = PlatformIntegrationService();

  // Form controllers
  final _coinbaseApiKeyController = TextEditingController();
  final _coinbaseApiSecretController = TextEditingController();
  final _binanceApiKeyController = TextEditingController();
  final _binanceApiSecretController = TextEditingController();
  final _zerodhaApiKeyController = TextEditingController();
  final _zerodhaApiSecretController = TextEditingController();
  final _zerodhaRequestTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIntegrations();
  }

  @override
  void dispose() {
    _coinbaseApiKeyController.dispose();
    _coinbaseApiSecretController.dispose();
    _binanceApiKeyController.dispose();
    _binanceApiSecretController.dispose();
    _zerodhaApiKeyController.dispose();
    _zerodhaApiSecretController.dispose();
    _zerodhaRequestTokenController.dispose();
    super.dispose();
  }

  Future<void> _loadIntegrations() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        final integrations = await _platformService.query(field: 'userId', isEqualTo: userId);
        setState(() {
          _integrations = integrations.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading integrations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectCoinbase() async {
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        await _platformService.connectCoinbaseWallet(
          userId,
          _coinbaseApiKeyController.text,
          _coinbaseApiSecretController.text,
        );
        await _loadIntegrations();
        Navigator.pop(context); // Close dialog
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting Coinbase: $e')),
      );
    }
  }

  Future<void> _connectBinance() async {
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        await _platformService.connectBinanceWallet(
          userId,
          _binanceApiKeyController.text,
          _binanceApiSecretController.text,
        );
        await _loadIntegrations();
        Navigator.pop(context); // Close dialog
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting Binance: $e')),
      );
    }
  }

  Future<void> _connectZerodha() async {
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        await _platformService.connectZerodhaAccount(
          userId,
          _zerodhaApiKeyController.text,
          _zerodhaApiSecretController.text,
          _zerodhaRequestTokenController.text,
        );
        await _loadIntegrations();
        Navigator.pop(context); // Close dialog
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting Zerodha: $e')),
      );
    }
  }

  void _showConnectDialog(String platform) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect $platform'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (platform == 'Coinbase') ...[
                TextField(
                  controller: _coinbaseApiKeyController,
                  decoration: const InputDecoration(labelText: 'API Key'),
                ),
                TextField(
                  controller: _coinbaseApiSecretController,
                  decoration: const InputDecoration(labelText: 'API Secret'),
                  obscureText: true,
                ),
              ] else if (platform == 'Binance') ...[
                TextField(
                  controller: _binanceApiKeyController,
                  decoration: const InputDecoration(labelText: 'API Key'),
                ),
                TextField(
                  controller: _binanceApiSecretController,
                  decoration: const InputDecoration(labelText: 'API Secret'),
                  obscureText: true,
                ),
              ] else if (platform == 'Zerodha') ...[
                TextField(
                  controller: _zerodhaApiKeyController,
                  decoration: const InputDecoration(labelText: 'API Key'),
                ),
                TextField(
                  controller: _zerodhaApiSecretController,
                  decoration: const InputDecoration(labelText: 'API Secret'),
                  obscureText: true,
                ),
                TextField(
                  controller: _zerodhaRequestTokenController,
                  decoration: const InputDecoration(labelText: 'Request Token'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              switch (platform) {
                case 'Coinbase':
                  _connectCoinbase();
                  break;
                case 'Binance':
                  _connectBinance();
                  break;
                case 'Zerodha':
                  _connectZerodha();
                  break;
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncIntegration(Map<String, dynamic> integration) async {
    try {
      setState(() => _isLoading = true);
      await _platformService.syncAllAccounts(integration['userId']);
      await _loadIntegrations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error syncing integration: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteIntegration(Map<String, dynamic> integration) async {
    try {
      setState(() => _isLoading = true);
      await _platformService.delete(integration['id']);
      await _loadIntegrations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting integration: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Integration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIntegrations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected Platforms',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_integrations.isEmpty)
                    Center(
                      child: Text(
                        'No platforms connected yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _integrations.length,
                      itemBuilder: (context, index) {
                        final integration = _integrations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            leading: Icon(
                              _getPlatformIcon(integration['platform'] as String? ?? ''),
                              color: _getPlatformColor(integration['platform'] as String? ?? ''),
                            ),
                            title: Text(
                              integration['platform'] as String? ?? 'Unknown Platform',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Last synced: ${_formatLastSync(integration['lastSync'] as DateTime?)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () => _syncIntegration(integration),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteIntegration(integration),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Available Platforms',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildPlatformCard('Coinbase', 'crypto'),
                      _buildPlatformCard('Binance', 'crypto'),
                      _buildPlatformCard('Zerodha', 'stock'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlatformCard(String platform, String type) {
    final isConnected = _integrations.any(
      (integration) => integration['platform'] == platform.toLowerCase(),
    );

    return Card(
      child: InkWell(
        onTap: isConnected ? null : () => _showConnectDialog(platform),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getPlatformIcon(platform.toLowerCase()),
                size: 32,
                color: _getPlatformColor(platform.toLowerCase()),
              ),
              const SizedBox(height: 8),
              Text(
                platform,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isConnected ? 'Connected' : 'Connect',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isConnected ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'coinbase':
        return Icons.currency_bitcoin;
      case 'binance':
        return Icons.currency_bitcoin;
      case 'zerodha':
        return Icons.show_chart;
      default:
        return Icons.link;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'coinbase':
        return Colors.blue;
      case 'binance':
        return Colors.amber;
      case 'zerodha':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
} 