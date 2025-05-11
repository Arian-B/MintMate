import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmartSecurityScreen extends StatefulWidget {
  const SmartSecurityScreen({super.key});

  @override
  State<SmartSecurityScreen> createState() => _SmartSecurityScreenState();
}

class _SmartSecurityScreenState extends State<SmartSecurityScreen> {
  bool _isLoading = false;
  bool _biometricEnabled = false;
  bool _encryptionEnabled = false;
  bool _anomalyDetectionEnabled = false;
  Map<String, bool> _privacyControls = {
    'Location': false,
    'Camera': false,
    'Microphone': false,
  };

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading security settings
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _biometricEnabled = true;
        _encryptionEnabled = true;
        _anomalyDetectionEnabled = false;
        _privacyControls = {
          'Location': true,
          'Camera': false,
          'Microphone': false,
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading security settings: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Security'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Biometric Authentication'),
                    value: _biometricEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('End-to-End Encryption'),
                    value: _encryptionEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _encryptionEnabled = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('AI Anomaly Detection'),
                    value: _anomalyDetectionEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _anomalyDetectionEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Privacy Controls',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ..._privacyControls.entries.map((entry) {
                    return SwitchListTile(
                      title: Text(entry.key),
                      value: entry.value,
                      onChanged: (bool value) {
                        setState(() {
                          _privacyControls[entry.key] = value;
                        });
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadSecuritySettings,
                    child: const Text('Refresh Security Settings'),
                  ),
                ],
              ),
            ),
    );
  }
} 