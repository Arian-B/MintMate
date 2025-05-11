import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'funds_manager_screen.dart';
import 'bill_tracker_screen.dart';
import 'budget_builder_screen.dart';
import 'bill_splitter_screen.dart';
import 'expense_calculator_screen.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/notification_service.dart';
import 'reminders_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              'Net Worth',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹25,000',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem('Cash', '₹15,000'),
                _buildBalanceItem('Crypto', '₹5,000'),
                _buildBalanceItem('Stocks', '₹5,000'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, String amount) {
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
          amount,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
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
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
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
            const SizedBox(height: 12),
            Text(
              'Consider setting up automatic transfers to your savings account right after you receive your paycheck. This way, you\'ll save before you spend!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
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
} 