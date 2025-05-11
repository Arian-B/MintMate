import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mintmate/backend/services/reminder_service.dart';
import 'package:mintmate/backend/models/reminder.dart';
import 'package:mintmate/backend/services/auth_service.dart';
import 'package:mintmate/backend/services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late ReminderService _reminderService;
  List<Reminder> _reminders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reminderService = ReminderService(Provider.of<NotificationService>(context, listen: false));
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final userId = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
      if (userId != null) {
        _reminderService.getReminders(userId).listen((reminders) {
          setState(() {
            _reminders = reminders;
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reminders: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addReminder() async {
    final result = await showDialog<Reminder>(
      context: context,
      builder: (context) => const AddReminderDialog(),
    );

    if (result != null) {
      try {
        await _reminderService.createReminder(result);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding reminder: $e')),
        );
      }
    }
  }

  Future<void> _editReminder(Reminder reminder) async {
    final result = await showDialog<Reminder>(
      context: context,
      builder: (context) => AddReminderDialog(reminder: reminder),
    );

    if (result != null) {
      try {
        await _reminderService.updateReminder(result);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reminder: $e')),
        );
      }
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    try {
      await _reminderService.deleteReminder(reminder.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting reminder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return ListTile(
                  title: Text(reminder.title),
                  subtitle: Text(reminder.description ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editReminder(reminder),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteReminder(reminder),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddReminderDialog extends StatefulWidget {
  final Reminder? reminder;
  const AddReminderDialog({super.key, this.reminder});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'custom';
  bool _isRecurring = false;
  String? _recurringPeriod;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description ?? '';
      _selectedDate = widget.reminder!.dateTime;
      _selectedType = widget.reminder!.type;
      _isRecurring = widget.reminder!.isRecurring;
      _recurringPeriod = widget.reminder!.recurringPeriod;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            ListTile(
              title: const Text('Date & Time'),
              subtitle: Text(_selectedDate.toString()),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: ['bill', 'goal', 'custom'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Recurring'),
              value: _isRecurring,
              onChanged: (bool value) {
                setState(() {
                  _isRecurring = value;
                });
              },
            ),
            if (_isRecurring)
              DropdownButtonFormField<String>(
                value: _recurringPeriod,
                items: ['daily', 'weekly', 'monthly'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _recurringPeriod = newValue;
                  });
                },
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
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final userId = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
      if (userId != null) {
        final reminder = Reminder(
          id: widget.reminder?.id ?? '',
          userId: userId,
          title: _titleController.text,
          description: _descriptionController.text,
          dateTime: _selectedDate,
          type: _selectedType,
          isRecurring: _isRecurring,
          recurringPeriod: _recurringPeriod,
          isEnabled: true,
          createdAt: widget.reminder?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        Navigator.pop(context, reminder);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 