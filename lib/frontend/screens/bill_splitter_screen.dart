import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/group_expense_service.dart';
import 'package:mintmate/backend/models/group_expense.dart';

class BillSplitterScreen extends StatefulWidget {
  const BillSplitterScreen({super.key});

  @override
  _BillSplitterScreenState createState() => _BillSplitterScreenState();
}

class _BillSplitterScreenState extends State<BillSplitterScreen> {
  final GroupExpenseService _groupExpenseService = GroupExpenseService();
  bool _isLoading = false;
  List<GroupExpense> _expenses = [];
  Map<String, Map<String, double>> _settlements = {};
  final List<String> _groups = ['Group 1', 'Group 2', 'Group 3'];
  String _selectedGroup = 'Group 1';

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
        _groupExpenseService.getExpensesForGroup(_selectedGroup).listen((expenses) {
          setState(() {
            _expenses = expenses;
          });
        });
        _settlements = await _groupExpenseService.calculateSettlements(_selectedGroup);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MateSplit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _showCreateGroupDialog,
          ),
        ],
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
                      _buildGroupSelector(),
                      const SizedBox(height: 24),
                      _buildExpenseList(),
                      const SizedBox(height: 24),
                      _buildSettlements(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupSelector() {
    return DropdownButton<String>(
      value: _selectedGroup,
      items: _groups.map((String group) {
        return DropdownMenuItem<String>(
          value: group,
          child: Text(group),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedGroup = newValue;
          });
          _loadData();
        }
      },
    );
  }

  Widget _buildExpenseList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expenses',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _expenses.length,
          itemBuilder: (context, index) {
            final expense = _expenses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(expense.description),
                subtitle: Text('Paid by: ${expense.paidBy}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.blue),
                      onPressed: () => _showSplits(expense),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editExpense(expense),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteExpense(expense),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettlements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settlements',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _settlements.length,
          itemBuilder: (context, index) {
            final debtor = _settlements.keys.elementAt(index);
            final creditor = _settlements[debtor]!.keys.first;
            final amount = _settlements[debtor]![creditor]!;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('$debtor owes $creditor'),
                trailing: Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showAddExpenseDialog() async {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final List<String> friends = ['John', 'Sarah', 'Mike', 'Emma'];
    List<String> selectedFriends = [];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Split between:'),
              ...friends.map((friend) => CheckboxListTile(
                    title: Text(friend),
                    value: selectedFriends.contains(friend),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedFriends.add(friend);
                        } else {
                          selectedFriends.remove(friend);
                        }
                      });
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final description = descriptionController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (description.isNotEmpty && amount > 0) {
                Navigator.pop(context, {
                  'description': description,
                  'amount': amount,
                  'participants': selectedFriends,
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final userId = context.read<AuthService>().currentUser?.uid;
        if (userId != null) {
          final expense = GroupExpense(
            id: '',
            groupId: 'group1',
            description: result['description'],
            amount: result['amount'],
            paidBy: userId,
            participants: [userId, ...result['participants']],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _groupExpenseService.createExpense(expense);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding expense: $e')),
        );
      }
    }
  }

  Future<void> _deleteExpense(GroupExpense expense) async {
    try {
      await _groupExpenseService.deleteExpense(expense.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting expense: $e')),
      );
    }
  }

  Future<void> _editExpense(GroupExpense expense) async {
    final descriptionController = TextEditingController(text: expense.description);
    final amountController = TextEditingController(text: expense.amount.toString());
    final List<String> friends = ['John', 'Sarah', 'Mike', 'Emma'];
    List<String> selectedFriends = List.from(expense.participants);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Split between:'),
              ...friends.map((friend) => CheckboxListTile(
                    title: Text(friend),
                    value: selectedFriends.contains(friend),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedFriends.add(friend);
                        } else {
                          selectedFriends.remove(friend);
                        }
                      });
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final description = descriptionController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (description.isNotEmpty && amount > 0) {
                Navigator.pop(context, {
                  'description': description,
                  'amount': amount,
                  'participants': selectedFriends,
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final updatedExpense = expense.copyWith(
          description: result['description'],
          amount: result['amount'],
          participants: result['participants'],
          updatedAt: DateTime.now(),
        );
        await _groupExpenseService.updateExpense(updatedExpense);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating expense: $e')),
        );
      }
    }
  }

  Future<void> _showSplits(GroupExpense expense) async {
    final splits = _groupExpenseService.calculateSplits(expense);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: ₹${expense.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Splits:'),
            ...splits.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('${entry.key}: ₹${entry.value.toStringAsFixed(2)}'),
                )),
          ],
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

  Future<void> _showCreateGroupDialog() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Group Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _groups.add(result);
        _selectedGroup = result;
      });
      _loadData();
    }
  }
} 