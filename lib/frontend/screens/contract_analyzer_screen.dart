import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContractAnalyzerScreen extends StatefulWidget {
  const ContractAnalyzerScreen({super.key});

  @override
  State<ContractAnalyzerScreen> createState() => _ContractAnalyzerScreenState();
}

class _ContractAnalyzerScreenState extends State<ContractAnalyzerScreen> {
  bool _isLoading = false;
  String _analyzedText = '';
  List<String> _keyPoints = [];
  String _riskAssessment = '';

  @override
  void initState() {
    super.initState();
    _analyzeContract();
  }

  Future<void> _analyzeContract() async {
    setState(() => _isLoading = true);
    try {
      // Mock contract analysis
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _analyzedText = 'Contract analyzed: Terms and conditions reviewed.';
        _keyPoints = [
          'Term: 12 months',
          'Payment: Monthly',
          'Cancellation: 30 days notice',
        ];
        _riskAssessment = 'Low risk: Standard terms and conditions.';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing contract: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Analyzer'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyzed Contract',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_analyzedText),
                  const SizedBox(height: 16),
                  Text(
                    'Key Points:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _keyPoints.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_keyPoints[index]),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Risk Assessment: $_riskAssessment',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _analyzeContract,
                    child: const Text('Analyze Another Contract'),
                  ),
                ],
              ),
            ),
    );
  }
} 