import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/models/savings_bucket.dart';
import 'package:mintmate/backend/services/savings_bucket_service.dart';

class FundsManagerScreen extends StatefulWidget {
  const FundsManagerScreen({super.key});

  @override
  State<FundsManagerScreen> createState() => _FundsManagerScreenState();
}

class _FundsManagerScreenState extends State<FundsManagerScreen> {
  final SavingsBucketService _savingsService = SavingsBucketService();
  Map<String, double> _savingsBuckets = {};
  Map<String, dynamic> _recommendations = {};
  bool _isLoading = false;
  List<SavingsBucket> _savingsBucketsList = [];
  Map<String, dynamic> _savingsStats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        _savingsService.getBucketsForUser(userId).listen((buckets) {
          setState(() {
            _savingsBucketsList = buckets;
            _savingsBuckets = {
              for (var bucket in _savingsBucketsList) bucket.name: bucket.currentAmount,
            };
          });
        });

        _savingsStats = await _savingsService.getSavingsStats(userId);
        _recommendations = await _savingsService.getSavingsRecommendations(userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addFunds(String bucket, double amount) async {
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        final currentAmount = _savingsBuckets[bucket] ?? 0.0;
        final bucketObj = _savingsBucketsList.firstWhere((b) => b.name == bucket);
        final updatedBucket = bucketObj.copyWith(
          currentAmount: currentAmount + amount,
          updatedAt: DateTime.now(),
        );
        await _savingsService.updateBucket(updatedBucket);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding funds: $e')),
      );
    }
  }

  Future<void> _showAddFundsDialog(String bucketName) async {
    if (!mounted) return;
    
    final amountController = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to $bucketName'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      try {
        final userId = context.read<AuthService>().currentUser?.uid;
        if (userId != null) {
          final bucket = _savingsBucketsList.firstWhere(
            (b) => b.name == bucketName,
            orElse: () => throw Exception('Bucket not found'),
          );
          
          final updatedBucket = bucket.copyWith(
            currentAmount: bucket.currentAmount + result,
            updatedAt: DateTime.now(),
          );
          
          await _savingsService.updateBucket(updatedBucket);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating bucket: $e')),
          );
        }
      }
    }
  }

  Future<void> _createBucket(String name, double target) async {
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        final newBucket = SavingsBucket(
          id: '',
          userId: userId,
          name: name,
          description: '',
          targetAmount: target,
          currentAmount: 0.0,
          currency: 'INR',
          targetDate: DateTime.now().add(const Duration(days: 30)),
          completedDate: null,
          relatedAccountIds: [],
          metadata: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _savingsService.createBucket(newBucket);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating bucket: $e')),
      );
    }
  }

  void _showCreateBucketDialog() {
    final nameController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Savings Bucket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Bucket Name'),
            ),
            TextField(
              controller: targetController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final target = double.tryParse(targetController.text) ?? 0.0;
              if (name.isNotEmpty) {
                _createBucket(name, target);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MateFunds'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSavingsOverview(),
                      const SizedBox(height: 24),
                      _buildAISuggestions(),
                      const SizedBox(height: 24),
                      _buildSavingsBuckets(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBucketDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSavingsOverview() {
    final totalTarget = _savingsStats['totalTarget'] ?? 0.0;
    final totalSaved = _savingsStats['totalSaved'] ?? 0.0;
    final completionRate = _savingsStats['completionRate'] ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Savings Overview',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Total Target', '₹${totalTarget.toStringAsFixed(2)}'),
                _buildStatItem('Total Saved', '₹${totalSaved.toStringAsFixed(2)}'),
                _buildStatItem('Completion', '${completionRate.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: completionRate / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAISuggestions() {
    final tips = _recommendations['tips'] as List? ?? [];
    final monthlySavings = _recommendations['monthlySavings'] ?? 0.0;
    final suggestedTarget = _recommendations['suggestedMonthlyTarget'] ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'AI Suggestions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tips.isNotEmpty) ...[
              ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(tip)),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            Text(
              'Monthly Savings: ₹${monthlySavings.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suggested Target: ₹${suggestedTarget.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsBuckets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Savings Buckets',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _savingsBucketsList.length,
          itemBuilder: (context, index) {
            final bucket = _savingsBucketsList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(bucket.name),
                subtitle: Text(
                  '₹${bucket.currentAmount.toStringAsFixed(2)} / ₹${bucket.targetAmount.toStringAsFixed(2)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${bucket.progressPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '${bucket.remainingTime.inDays} days left',
                      style: TextStyle(
                        fontSize: 12,
                        color: bucket.isOverdue ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                onTap: () => _showBucketDetails(bucket),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showBucketDetails(SavingsBucket bucket) async {
    if (!mounted) return;
    
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bucket.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${bucket.description}'),
            const SizedBox(height: 8),
            Text('Target Amount: ₹${bucket.targetAmount.toStringAsFixed(2)}'),
            Text('Current Amount: ₹${bucket.currentAmount.toStringAsFixed(2)}'),
            Text('Progress: ${bucket.progressPercentage.toStringAsFixed(1)}%'),
            Text('Target Date: ${bucket.targetDate.toString().split(' ')[0]}'),
            if (bucket.isOverdue)
              const Text(
                'This bucket is overdue!',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _showAddFundsDialog(bucket.name);
              Navigator.pop(context);
            },
            child: const Text('Add Funds'),
          ),
        ],
      ),
    );
  }
} 