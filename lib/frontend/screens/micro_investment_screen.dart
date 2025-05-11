import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/ai_service.dart';

class MicroInvestmentScreen extends StatefulWidget {
  const MicroInvestmentScreen({super.key});

  @override
  State<MicroInvestmentScreen> createState() => _MicroInvestmentScreenState();
}

class _MicroInvestmentScreenState extends State<MicroInvestmentScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _investmentOptions = [];
  String _riskProfile = 'Moderate';

  @override
  void initState() {
    super.initState();
    _loadInvestmentOptions();
  }

  Future<void> _loadInvestmentOptions() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading investment options
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _investmentOptions = [
          {
            'name': 'Tech Stocks',
            'risk': 'High',
            'return': '15%',
          },
          {
            'name': 'Bonds',
            'risk': 'Low',
            'return': '5%',
          },
          {
            'name': 'Real Estate',
            'risk': 'Moderate',
            'return': '10%',
          },
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading investment options: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro-Investment Automator'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Investment Options',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _investmentOptions.length,
                    itemBuilder: (context, index) {
                      final option = _investmentOptions[index];
                      return ListTile(
                        title: Text(option['name']),
                        subtitle: Text('Risk: ${option['risk']}, Return: ${option['return']}'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Risk Profile: $_riskProfile',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadInvestmentOptions,
                    child: const Text('Refresh Investment Options'),
                  ),
                ],
              ),
            ),
    );
  }
} 