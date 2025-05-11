import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class PlatformIntegrationScreen extends StatefulWidget {
  const PlatformIntegrationScreen({super.key});

  @override
  State<PlatformIntegrationScreen> createState() => _PlatformIntegrationScreenState();
}

class _PlatformIntegrationScreenState extends State<PlatformIntegrationScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _integrations = [];

  @override
  void initState() {
    super.initState();
    _loadIntegrations();
  }

  Future<void> _loadIntegrations() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading integrations
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _integrations = [
          {
            'name': 'Bank Account',
            'status': 'Connected',
          },
          {
            'name': 'Crypto Wallet',
            'status': 'Not Connected',
          },
          {
            'name': 'Stock Brokerage',
            'status': 'Not Connected',
          },
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading integrations: $e')),
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _integrations.length,
                    itemBuilder: (context, index) {
                      final integration = _integrations[index];
                      return ListTile(
                        title: Text(integration['name']),
                        subtitle: Text(integration['status']),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement connection logic
                          },
                          child: const Text('Connect'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadIntegrations,
                    child: const Text('Refresh Integrations'),
                  ),
                ],
              ),
            ),
    );
  }
} 