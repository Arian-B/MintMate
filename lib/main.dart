import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/services/firebase_service.dart';
import 'backend/services/auth_service.dart';
import 'frontend/screens/dashboard_screen.dart';
import 'frontend/screens/expense_tracking_screen.dart';
import 'frontend/screens/budget_builder_screen.dart';
import 'frontend/screens/bill_tracker_screen.dart';
import 'frontend/screens/bill_splitter_screen.dart';
import 'frontend/screens/expense_calculator_screen.dart';
import 'frontend/screens/reminders_screen.dart';
import 'backend/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'MintMate',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ExpenseTrackingScreen(),
    const BudgetBuilderScreen(),
    const BillTrackerScreen(),
    const BillSplitterScreen(),
    const ExpenseCalculatorScreen(),
    const RemindersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MintMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Show profile
            },
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
        children: const [
          NavigationDrawerDestination(
            icon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.receipt_long),
            label: Text('Expense Tracking'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: Text('Budget Builder'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.payment),
            label: Text('Bill Tracker'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.group),
            label: Text('Bill Splitter'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.calculate),
            label: Text('Expense Calculator'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.alarm),
            label: Text('Reminders'),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
    );
  }
}
