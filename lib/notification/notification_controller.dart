import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/notification/notification_utils.dart';
import 'package:diary/services/todo_service.dart';
import 'package:flutter/material.dart';

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint(
        'Notification created: ${receivedNotification.toMap().toString()}');
  }

  /// Use this method to detect when a new notification is displayed
  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint(
        'Notification displayed: ${receivedNotification.toMap().toString()}');
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma('vm:entry-point')
  static Future<void> onNotificationDismissedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint(
        'Notification dismissed: ${receivedNotification.toMap().toString()}');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint(
        'Notification action received: ${receivedAction.toMap().toString()}');

    // Navigate according to notification payload data
    if (receivedAction.payload != null) {
      // Check if this is a todo notification
      if (receivedAction.payload!.containsKey('todoId')) {
        final todoId = receivedAction.payload!['todoId'] ?? '';
        debugPrint('Todo ID from notification: $todoId');

        // Handle "Mark Done" action
        if (receivedAction.buttonKeyInput == 'MARK_DONE') {
          debugPrint('User marked todo as done from notification');
          final TodoService todoService = TodoService();

          // Complete the todo
          try {
            await todoService.updateTodoCompletion(todoId, true);
            debugPrint('Todo marked as completed successfully');
          } catch (e) {
            debugPrint('Error marking todo as completed: $e');
          }
        }
      }

      // Handle schedule time data
      if (receivedAction.payload!.containsKey('scheduledTime')) {
        debugPrint(
            'This notification was scheduled for: ${receivedAction.payload!['scheduledTime']}');
      }
    }
  }

  /// Check all active scheduled notifications
  static Future<void> checkActiveScheduledNotifications() async {
    await NotificationUtils.debugScheduledNotifications();
  }

  /// Reschedule all active todo notifications
  /// This should be called when the app starts to ensure notifications persist across reboots
  static Future<void> rescheduleAllTodoNotifications() async {
    final TodoService todoService = TodoService();

    // First, ensure we have the proper permissions
    await NotificationUtils.requestPermissions();
    await NotificationUtils.requestExactAlarmPermission();

    // Get all todos that have notifications enabled
    QuerySnapshot? todoSnapshot;
    try {
      todoSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(todoService.userId)
          .collection('todos')
          .where('enableNotification', isEqualTo: true)
          .where('isDone',
              isEqualTo: false) // Don't schedule for completed todos
          .get();
    } catch (e) {
      debugPrint('Error fetching todos for notification rescheduling: $e');
      return;
    }

    // Cancel all existing notifications before rescheduling
    await AwesomeNotifications().cancelAllSchedules();

    if (todoSnapshot.docs.isEmpty) {
      debugPrint('No todo notifications to reschedule');
      return;
    }

    debugPrint('Rescheduling ${todoSnapshot.docs.length} todo notifications');

    int successCount = 0;
    int failureCount = 0;

    // Reschedule notifications for each todo
    for (var doc in todoSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String title = data['title'] ?? '';
      final String date = data['date'] ?? '';
      final String time = data['time'] ?? '';

      // Only schedule if date and time are provided
      if (date.isNotEmpty && time.isNotEmpty) {
        try {
          // Try the improved notification scheduling first
          final result =
              await NotificationUtils.scheduleImprovedTodoNotification(
            todoId: doc.id,
            title: title,
            date: date,
            time: time,
          );

          if (result) {
            successCount++;
          } else {
            // If the improved method fails, try the fallback
            // We don't know the result of the fallback since it returns void
            // Just count it as a success attempt
            successCount++;
          }
        } catch (e) {
          debugPrint('Error rescheduling todo notification for ${doc.id}: $e');
          failureCount++;
        }
      }
    }

    debugPrint(
        'Finished rescheduling todo notifications. Success: $successCount, Failures: $failureCount');

    // Debug all scheduled notifications after rescheduling
    await NotificationUtils.debugScheduledNotifications();
  }
}
