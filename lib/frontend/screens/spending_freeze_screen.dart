import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SpendingFreezeScreen extends StatefulWidget {
  const SpendingFreezeScreen({super.key});

  @override
  State<SpendingFreezeScreen> createState() => _SpendingFreezeScreenState();
}

class _SpendingFreezeScreenState extends State<SpendingFreezeScreen> {
  bool _isLoading = false;
  bool _isFreezeEnabled = false;
  List<Map<String, dynamic>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    try {
      // Mock loading recommendations
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _recommendations = [
          {
            'category': 'Food & Dining',
            'suggestion': 'Consider cooking at home to save on dining expenses.',
          },
          {
            'category': 'Entertainment',
            'suggestion': 'Look for free or low-cost entertainment options.',
          },
          {
            'category': 'Shopping',
            'suggestion': 'Avoid impulse purchases and stick to a shopping list.',
          },
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recommendations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Freeze'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Freeze',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Spending Freeze'),
                    value: _isFreezeEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isFreezeEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AI Recommendations',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = _recommendations[index];
                      return ListTile(
                        title: Text(recommendation['category']),
                        subtitle: Text(recommendation['suggestion']),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadRecommendations,
                    child: const Text('Refresh Recommendations'),
                  ),
                ],
              ),
            ),
    );
  }
} 