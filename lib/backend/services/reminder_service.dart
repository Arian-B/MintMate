import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder.dart';
import 'base_service.dart';
import 'notification_service.dart';

class ReminderService extends BaseService<Reminder> {
  final NotificationService notificationService;
  ReminderService(this.notificationService)
      : super(FirebaseFirestore.instance, 'reminders');

  @override
  Reminder fromFirestore(DocumentSnapshot doc) {
    return Reminder.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(Reminder model) {
    return model.toFirestore();
  }

  // Create a new reminder and schedule notification
  Future<Reminder> createReminder(Reminder reminder) async {
    final created = await create(reminder);
    if (reminder.isEnabled) {
      scheduleReminderNotification(created);
    }
    return created;
  }

  // Update a reminder and reschedule notification
  Future<Reminder> updateReminder(Reminder reminder) async {
    final updated = await update(reminder.id, reminder);
    if (reminder.isEnabled) {
      scheduleReminderNotification(updated);
    }
    return updated;
  }

  // Delete a reminder and cancel notification
  Future<void> deleteReminder(String id) async {
    await delete(id);
    // Optionally: cancel scheduled notification
  }

  // Get all reminders for a user
  Stream<List<Reminder>> getReminders(String userId) {
    return stream().map((reminders) => reminders.where((r) => r.userId == userId).toList());
  }

  // Schedule a local notification for a reminder
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    await notificationService.showLocalNotification(
      title: reminder.title,
      body: reminder.description ?? 'You have a reminder!',
    );
    // For real scheduling, use a background task or plugin for scheduled notifications
  }
} 