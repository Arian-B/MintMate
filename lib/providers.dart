import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'backend/services/user_service.dart';
import 'backend/services/account_service.dart';
import 'backend/services/transaction_service.dart';
import 'backend/services/goal_service.dart';

final firestore = FirebaseFirestore.instance;

final appProviders = [
  Provider<UserService>(create: (_) => UserService(firestore)),
  Provider<AccountService>(create: (_) => AccountService(firestore)),
  Provider<TransactionService>(create: (_) => TransactionService(firestore)),
  Provider<GoalService>(create: (_) => GoalService(firestore)),
]; 