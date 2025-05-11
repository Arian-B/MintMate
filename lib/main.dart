import 'package:flutter/material.dart';
import 'frontend/theme/app_theme.dart';
import 'frontend/screens/dashboard_screen.dart';

void main() {
  runApp(const MintMateApp());
}

class MintMateApp extends StatelessWidget {
  const MintMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MintMate',
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
