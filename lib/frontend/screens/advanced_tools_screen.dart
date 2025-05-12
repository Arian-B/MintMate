import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/feature_card.dart';
import '../theme/app_theme.dart';
import '../../backend/services/document_analysis_service.dart';
import '../../backend/services/security_service.dart';
import '../../backend/services/ai_service.dart';
import 'document_analysis_screen.dart';
import 'security_center_screen.dart';
import 'ai_insights_screen.dart';
import 'smart_alerts_screen.dart';

class AdvancedToolsScreen extends StatefulWidget {
  const AdvancedToolsScreen({Key? key}) : super(key: key);

  @override
  AdvancedToolsScreenState createState() => AdvancedToolsScreenState();
}

class AdvancedToolsScreenState extends State<AdvancedToolsScreen> {
  final DocumentAnalysisService _documentService = DocumentAnalysisService();
  final SecurityService _securityService = SecurityService();
  final AIService _aiService = AIService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Advanced Tools',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildToolsGrid(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Tools',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Powerful tools to enhance your financial management',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildToolsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        FeatureCard(
          title: 'Document Analysis',
          icon: Icons.description,
          onTap: () => _navigateToDocumentAnalysis(),
          gradient: AppTheme.gradientBlue,
        ),
        FeatureCard(
          title: 'Security Center',
          icon: Icons.security,
          onTap: () => _navigateToSecurityCenter(),
          gradient: AppTheme.gradientGreen,
        ),
        FeatureCard(
          title: 'AI Insights',
          icon: Icons.psychology,
          onTap: () => _navigateToAIInsights(),
          gradient: AppTheme.gradientPurple,
        ),
        FeatureCard(
          title: 'Smart Alerts',
          icon: Icons.notifications_active,
          onTap: () => _navigateToSmartAlerts(),
          gradient: AppTheme.gradientOrange,
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.description,
                  title: 'Document Analyzed',
                  subtitle: 'Rental Agreement',
                  time: '2 hours ago',
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.security,
                  title: 'Security Scan',
                  subtitle: 'No threats detected',
                  time: '5 hours ago',
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.psychology,
                  title: 'AI Analysis',
                  subtitle: 'Spending pattern updated',
                  time: '1 day ago',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
      ),
    );
  }

  void _navigateToDocumentAnalysis() {
    _documentService.initializeAnalysis();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DocumentAnalysisScreen()),
    );
  }

  void _navigateToSecurityCenter() {
    _securityService.checkSecurityStatus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecurityCenterScreen()),
    );
  }

  void _navigateToAIInsights() {
    _aiService.generateInsights();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIInsightsScreen()),
    );
  }

  void _navigateToSmartAlerts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SmartAlertsScreen()),
    );
  }
} 