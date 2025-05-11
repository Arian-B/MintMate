import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  bool _isLoading = false;
  String _scannedText = '';
  String _suggestedCategory = '';

  @override
  void initState() {
    super.initState();
    _scanReceipt();
  }

  Future<void> _scanReceipt() async {
    setState(() => _isLoading = true);
    try {
      // Mock OCR scanning
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _scannedText = 'Receipt scanned: Total amount: ₹500, Date: 2023-10-01';
        _suggestedCategory = 'Food & Dining';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning receipt: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Scanner'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanned Receipt',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_scannedText),
                  const SizedBox(height: 16),
                  Text(
                    'Suggested Category: $_suggestedCategory',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _scanReceipt,
                    child: const Text('Scan Another Receipt'),
                  ),
                ],
              ),
            ),
    );
  }
} 