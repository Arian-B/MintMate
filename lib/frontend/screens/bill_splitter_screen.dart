import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/group_expense_service.dart';
import 'package:mintmate/backend/models/group_expense.dart';

class BillSplitterScreen extends StatefulWidget {
  const BillSplitterScreen({super.key});

  @override
  State<BillSplitterScreen> createState() => _BillSplitterScreenState();
}

class _BillSplitterScreenState extends State<BillSplitterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedGroupId;
  bool _isLoading = true;
  List<GroupExpense> _expenses = [];
  List<Map<String, dynamic>> _settlements = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final groupExpenseService = Provider.of<GroupExpenseService>(context, listen: false);
      
      // Load user's groups
      final groups = await groupExpenseService.getUserGroups(authService.currentUser!.uid);
      
      if (groups.isNotEmpty) {
        _selectedGroupId = groups.first.id;
        await _loadExpenses();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadExpenses() async {
    if (_selectedGroupId == null) return;

    try {
      final groupExpenseService = Provider.of<GroupExpenseService>(context, listen: false);
      final expenses = await groupExpenseService.getGroupExpenses(_selectedGroupId!);
      final settlements = await groupExpenseService.calculateSettlements(_selectedGroupId!);
      
      setState(() {
        _expenses = expenses;
        _settlements = settlements;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading expenses: $e')),
      );
    }
  }

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final groupExpenseService = Provider.of<GroupExpenseService>(context, listen: false);
      
      // Get the current group to get its members
      final groups = await groupExpenseService.getUserGroups(authService.currentUser!.uid);
      final currentGroup = groups.firstWhere((g) => g.id == _selectedGroupId);
      
      if (currentGroup.members == null || currentGroup.members!.isEmpty) {
        throw Exception('No members found in the group');
      }

      await groupExpenseService.addExpense(
        groupId: _selectedGroupId!,
        paidBy: authService.currentUser!.uid,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        participants: currentGroup.members!,
        context: {
          'title': _titleController.text,
          'description': _descriptionController.text,
        },
      );
      
      await _loadExpenses();
      
      _titleController.clear();
      _amountController.clear();
      _descriptionController.clear();
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding expense: $e')),
      );
    }
  }

  Future<void> _editExpense(GroupExpense expense) async {
    _titleController.text = expense.name ?? expense.description;
    _amountController.text = expense.amount.toString();
    _descriptionController.text = expense.description;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid amount';
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final groupExpenseService = Provider.of<GroupExpenseService>(context, listen: false);
        final updatedExpense = expense.copyWith(
          name: _titleController.text,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text,
          updatedAt: DateTime.now(),
        );
        
        await groupExpenseService.updateExpense(updatedExpense);
        await _loadExpenses();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating expense: $e')),
        );
      }
    }
  }

  Future<void> _deleteExpense(GroupExpense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final groupExpenseService = Provider.of<GroupExpenseService>(context, listen: false);
        await groupExpenseService.deleteExpense(expense.id);
        await _loadExpenses();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting expense: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bill Splitter',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExpenseDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildGroupSelector(),
          Expanded(
            child: _expenses.isEmpty
                ? Center(
                    child: Text(
                      'No expenses yet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return _buildExpenseCard(expense);
                    },
                  ),
          ),
          if (_settlements.isNotEmpty) _buildSettlementsSection(),
        ],
      ),
    );
  }

  Widget _buildGroupSelector() {
    return Consumer<GroupExpenseService>(
      builder: (context, service, child) {
        return FutureBuilder<List<GroupExpense>>(
          future: service.getUserGroups(Provider.of<AuthService>(context, listen: false).currentUser!.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final groups = snapshot.data!;
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Group',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedGroupId,
                    items: groups.map((group) {
                      return DropdownMenuItem(
                        value: group.id,
                        child: Text(group.name ?? group.description),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedGroupId = value);
                      _loadExpenses();
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpenseCard(GroupExpense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          expense.name ?? expense.description,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${expense.amount.toStringAsFixed(2)}'),
            if (expense.description.isNotEmpty)
              Text(
                expense.description,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editExpense(expense),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteExpense(expense),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settlements',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ..._settlements.map((settlement) {
            return ListTile(
              title: Text(
                '${settlement['from']} → ${settlement['to']}',
                style: GoogleFonts.poppins(),
              ),
              subtitle: Text(
                '\$${settlement['amount'].toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Expense',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid amount';
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _addExpense,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
} 