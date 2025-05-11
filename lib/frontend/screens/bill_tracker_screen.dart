import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/bill_service.dart';
import 'package:mintmate/backend/models/bill.dart';
import 'package:fl_chart/fl_chart.dart';

class BillTrackerScreen extends StatefulWidget {
  const BillTrackerScreen({super.key});

  @override
  State<BillTrackerScreen> createState() => _BillTrackerScreenState();
}

class _BillTrackerScreenState extends State<BillTrackerScreen> {
  final BillService _billService = BillService();
  List<Bill> _bills = [];
  List<Bill> _upcomingBills = [];
  List<Bill> _overdueBills = [];
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        // Load all bills
        _billService.getBills(userId).listen((bills) {
          setState(() {
            _bills = bills;
          });
        });

        // Load upcoming bills
        _billService.getUpcomingBills(userId).listen((bills) {
          setState(() {
            _upcomingBills = bills;
          });
        });

        // Load overdue bills
        _billService.getOverdueBills(userId).listen((bills) {
          setState(() {
            _overdueBills = bills;
          });
        });

        // Load stats
        _stats = await _billService.getBillStats(userId);
        
        // Load suggestions
        _suggestions = await _billService.getSubscriptionSuggestions(userId);
        
        // Schedule reminders for upcoming bills
        await _billService.scheduleReminders(userId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bills: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddBillDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategory = 'Utilities';
    bool isRecurring = false;
    String? recurringPeriod;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Bill Name'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹',
                  ),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: [
                    'Utilities',
                    'Rent',
                    'Insurance',
                    'Subscription',
                    'Loan',
                    'Other',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Recurring Bill'),
                  trailing: Switch(
                    value: isRecurring,
                    onChanged: (bool value) {
                      setState(() {
                        isRecurring = value;
                      });
                    },
                  ),
                ),
                if (isRecurring)
                  DropdownButtonFormField<String>(
                    value: recurringPeriod,
                    items: [
                      'monthly',
                      'weekly',
                      'yearly',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        recurringPeriod = newValue;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Recurring Period'),
                  ),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(selectedDate.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = context.read<AuthService>().currentUser?.uid;
                if (userId != null) {
                  final bill = Bill(
                    id: '', // Will be set by Firestore
                    userId: userId,
                    name: nameController.text,
                    amount: double.parse(amountController.text),
                    dueDate: selectedDate,
                    frequency: recurringPeriod ?? 'monthly',
                    isActive: true,
                    isPaid: false,
                    lastPaidDate: null,
                    category: selectedCategory,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await _billService.createBill(bill);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bill Analytics'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryPieChart(),
              const SizedBox(height: 24),
              _buildMonthlyBarChart(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    final Map<String, double> categoryTotals = {};
    for (var bill in _bills) {
      categoryTotals[bill.category ?? 'Other'] = (categoryTotals[bill.category ?? 'Other'] ?? 0) + bill.amount;
    }

    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final sections = categoryTotals.entries.map((e) => PieChartSectionData(
      value: e.value,
      title: '${(e.value / total * 100).toStringAsFixed(1)}%',
      radius: 100,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    )).toList();

    return Column(
      children: [
        Text(
          'Bill Categories',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBarChart() {
    final Map<String, double> monthlyTotals = {};
    for (var bill in _bills) {
      final monthKey = '${bill.dueDate.year}-${bill.dueDate.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + bill.amount;
    }

    final sortedMonths = monthlyTotals.keys.toList()..sort();
    final spots = sortedMonths.asMap().entries.map((e) => FlSpot(e.key.toDouble(), monthlyTotals[e.value] ?? 0)).toList();

    return Column(
      children: [
        Text(
          'Monthly Bill Trends',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: monthlyTotals.values.fold(0.0, (max, amount) => amount > max ? amount : max).toDouble(),
              barGroups: spots.map((spot) => BarChartGroupData(
                x: spot.x.toInt(),
                barRods: [
                  BarChartRodData(
                    toY: (spot.y ?? 0).toDouble(),
                    color: Colors.blue,
                    width: 20,
                  ),
                ],
              )).toList(),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= sortedMonths.length) return const Text('');
                      return Text(sortedMonths[value.toInt()].substring(5));
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MateBills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBills,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStats(),
                      const SizedBox(height: 24),
                      if (_overdueBills.isNotEmpty) ...[
                        _buildSectionTitle('Overdue Bills'),
                        _buildBillList(_overdueBills, true),
                        const SizedBox(height: 24),
                      ],
                      if (_upcomingBills.isNotEmpty) ...[
                        _buildSectionTitle('Upcoming Bills'),
                        _buildBillList(_upcomingBills, false),
                        const SizedBox(height: 24),
                      ],
                      if (_suggestions.isNotEmpty) ...[
                        _buildSectionTitle('Smart Suggestions'),
                        _buildSuggestions(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBillDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bill Overview',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Total',
                  '₹${_stats['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                ),
                _buildStatItem(
                  'Upcoming',
                  '₹${_stats['upcomingAmount']?.toStringAsFixed(2) ?? '0.00'}',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  'Unpaid',
                  '₹${_stats['unpaidAmount']?.toStringAsFixed(2) ?? '0.00'}',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
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
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBillList(List<Bill> bills, bool isOverdue) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: Text(
              bill.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due: ${bill.dueDate.toString().split(' ')[0]}',
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                ),
                if (bill.frequency != 'monthly')
                  Text(
                    'Recurring: ${bill.frequency}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${bill.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () => _billService.markBillAsPaid(bill.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      suggestion['type'] == 'consolidation'
                          ? Icons.merge_type
                          : Icons.warning,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion['suggestion'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                if (suggestion['type'] == 'consolidation') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Total: ₹${suggestion['totalAmount'].toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
} 