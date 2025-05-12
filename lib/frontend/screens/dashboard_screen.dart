import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bill_tracker_screen.dart';
import 'budget_builder_screen.dart';
import 'bill_splitter_screen.dart';
import 'expense_calculator_screen.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/notification_service.dart';
import 'reminders_screen.dart';
import 'package:mintmate/backend/services/ai_service.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/net_worth_service.dart';
import 'package:intl/intl.dart';
import 'package:mintmate/backend/services/spending_service.dart';
import 'package:mintmate/frontend/widgets/spending_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();
  final NetWorthService _netWorthService = NetWorthService();
  final SpendingService _spendingService = SpendingService();
  String _dailyTip = '';
  bool _isLoadingTip = true;
  Map<String, dynamic> _netWorth = {};
  bool _isLoadingNetWorth = true;
  List<Map<String, dynamic>> _spendingData = [];
  bool _isLoadingSpending = true;
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _loadDailyTip();
    _loadNetWorth();
    _loadSpendingData();
  }

  Future<void> _loadDailyTip() async {
    setState(() => _isLoadingTip = true);
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        final tip = await _aiService.generateDailyTip(userId);
        setState(() {
          _dailyTip = tip;
          _isLoadingTip = false;
        });
      }
    } catch (e) {
      setState(() {
        _dailyTip = 'Unable to load daily tip. Please try again later.';
        _isLoadingTip = false;
      });
    }
  }

  Future<void> _loadNetWorth() async {
    setState(() => _isLoadingNetWorth = true);
    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId != null) {
        // Calculate initial net worth
        await _netWorthService.calculateNetWorth(userId);
        
        // Watch for changes
        _netWorthService.watchNetWorth(userId).listen((netWorth) {
          setState(() {
            _netWorth = netWorth;
            _isLoadingNetWorth = false;
          });
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingNetWorth = false;
      });
    }
  }

  Future<void> _loadSpendingData() async {
    setState(() {
      _isLoadingSpending = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final data = await _spendingService.getSpendingData(
          userId,
          period: _selectedPeriod,
        );
        setState(() {
          _spendingData = data;
          _isLoadingSpending = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSpending = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildNetWorthCard(context),
                const SizedBox(height: 16),
                _buildSpendingSnapshot(context),
                const SizedBox(height: 16),
                _buildGoalProgress(context),
                const SizedBox(height: 16),
                _buildMateSays(context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 16),
                _buildPeriodSelector(),
                const SizedBox(height: 16),
                SpendingChart(
                  spendingData: _spendingData,
                  period: _selectedPeriod,
                  isLoading: _isLoadingSpending,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back! 👋',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Your financial journey continues...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                // TODO: Implement profile
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetWorthCard(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Worth',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadNetWorth,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoadingNetWorth
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(_netWorth['netWorth'] ?? 0),
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_netWorth['netWorthChange'] != null) ...[
                        Row(
                          children: [
                            Icon(
                              (_netWorth['netWorthChange']['isPositive'] as bool)
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: (_netWorth['netWorthChange']['isPositive'] as bool)
                                  ? Colors.green
                                  : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_netWorth['netWorthChange']['isPositive'] ? '+' : ''}${currencyFormat.format(_netWorth['netWorthChange']['amount'])} (${_netWorth['netWorthChange']['percentage'].toStringAsFixed(1)}%)',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: (_netWorth['netWorthChange']['isPositive'] as bool)
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildNetWorthBreakdown(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Breakdown',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildBreakdownItem(
          'Assets',
          _netWorth['totalAssets'] ?? 0,
          _netWorth['assetsByType'] ?? {},
        ),
        const SizedBox(height: 8),
        _buildBreakdownItem(
          'Liabilities',
          _netWorth['totalLiabilities'] ?? 0,
          _netWorth['liabilitiesByType'] ?? {},
          isLiability: true,
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(String title, double total, Map<String, double> items, {bool isLiability = false}) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              currencyFormat.format(total),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isLiability ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...items.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  currencyFormat.format(entry.value),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isLiability ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildSpendingSnapshot(BuildContext context) {
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
              'Spending Snapshot',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // TODO: Add spending chart
            Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Spending Chart Coming Soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(BuildContext context) {
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
              'Goal Progress',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalItem('New Laptop', 0.7),
            const SizedBox(height: 12),
            _buildGoalItem('Travel Fund', 0.3),
            const SizedBox(height: 12),
            _buildGoalItem('Emergency Fund', 0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String goal, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              goal,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }

  Widget _buildMateSays(BuildContext context) {
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
                Icon(Icons.lightbulb_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Mate Says',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingTip
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    _dailyTip,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _loadDailyTip,
                icon: const Icon(Icons.refresh),
                label: const Text('New Tip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
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
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(context, 'Add Expense', Icons.add_circle_outline),
            _buildActionCard(context, 'Track Bills', Icons.receipt_long_outlined),
            _buildActionCard(context, 'Set Budget', Icons.pie_chart_outline),
            _buildActionCard(context, 'Split Bill', Icons.people_outline),
            _buildActionCard(context, 'Calculate', Icons.calculate_outlined),
            _buildActionCard(context, 'Test Notification', Icons.notifications_active),
            _buildActionCard(context, 'Reminders', Icons.alarm),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          if (title == 'Set Budget') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BudgetBuilderScreen()),
            );
          } else if (title == 'Track Bills') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BillTrackerScreen()),
            );
          } else if (title == 'Split Bill') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BillSplitterScreen()),
            );
          } else if (title == 'Calculate') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExpenseCalculatorScreen()),
            );
          } else if (title == 'Test Notification') {
            final notificationService = Provider.of<NotificationService>(context, listen: false);
            await notificationService.showLocalNotification(
              title: 'Test Notification',
              body: 'This is a test notification from MintMate!',
            );
          } else if (title == 'Reminders') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RemindersScreen()),
            );
          } else {
            // TODO: Implement other actions
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Spending Analytics',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButton<String>(
          value: _selectedPeriod,
          items: const [
            DropdownMenuItem(
              value: 'week',
              child: Text('This Week'),
            ),
            DropdownMenuItem(
              value: 'month',
              child: Text('This Month'),
            ),
            DropdownMenuItem(
              value: 'year',
              child: Text('This Year'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadSpendingData();
            }
          },
        ),
      ],
    );
  }
} 