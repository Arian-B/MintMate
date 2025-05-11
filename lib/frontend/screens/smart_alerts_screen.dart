import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class SmartAlertsScreen extends StatefulWidget {
  const SmartAlertsScreen({super.key});

  @override
  State<SmartAlertsScreen> createState() => _SmartAlertsScreenState();
}

class _SmartAlertsScreenState extends State<SmartAlertsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading alerts
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _alerts = [
          {
            'type': 'spending',
            'message': 'Unusual spending detected in Food & Dining category.',
          },
          {
            'type': 'subscription',
            'message': 'Your Netflix subscription will renew in 3 days.',
          },
          {
            'type': 'budget',
            'message': 'You are approaching your monthly budget limit.',
          },
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading alerts: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Alerts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alerts',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _alerts.length,
                    itemBuilder: (context, index) {
                      final alert = _alerts[index];
                      return ListTile(
                        title: Text(alert['message']),
                        leading: Icon(
                          alert['type'] == 'spending'
                              ? Icons.warning
                              : alert['type'] == 'subscription'
                                  ? Icons.subscriptions
                                  : Icons.account_balance_wallet,
                          color: Colors.orange,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadAlerts,
                    child: const Text('Refresh Alerts'),
                  ),
                ],
              ),
            ),
    );
  }
} 