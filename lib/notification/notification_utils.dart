import 'dart:io' show Platform;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for handling and debugging todo notifications
class NotificationUtils {
  /// Check if notification permissions are granted
  static Future<bool> checkPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    final arePermissionsAllowed = await AwesomeNotifications()
        .checkPermissionList(channelKey: 'todo_channel', permissions: [
      NotificationPermission.Alert,
      NotificationPermission.Sound,
      NotificationPermission.Badge,
      NotificationPermission.Vibration,
      NotificationPermission.Light,
      NotificationPermission.CriticalAlert,
    ]);

    // Print for debugging
    debugPrint('Notification permission is allowed: $isAllowed');
    debugPrint('Specific permissions: $arePermissionsAllowed');

    return isAllowed;
  }

  /// Request all necessary notification permissions
  static Future<void> requestPermissions() async {
    await AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Badge,
        NotificationPermission.Vibration,
        NotificationPermission.Light,
        NotificationPermission.CriticalAlert,
      ],
    );
  }

  /// Schedule a test notification for a specific date and time
  static Future<bool> scheduleTestNotification({
    required DateTime scheduledDate,
  }) async {
    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    // Log the scheduled date for debugging
    debugPrint(
        'Scheduling test notification for: ${scheduledDate.toIso8601String()}');

    // The test notification will use both channels to help identify any channel-specific issues
    final result = await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'todo_channel', // Use the todo-specific channel
        title: 'Test Todo Reminder',
        body:
            'This is a test todo reminder scheduled for ${DateFormat('MMM dd, yyyy HH:mm').format(scheduledDate)}',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        payload: {
          'isTest': 'true',
          'scheduledTime': scheduledDate.toIso8601String(),
        },
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledDate,
        allowWhileIdle: true,
        preciseAlarm: true,
        repeats: false,
      ),
    );

    debugPrint('Test notification schedule result: $result');
    return result;
  }

  /// Debug all scheduled notifications
  static Future<void> debugScheduledNotifications() async {
    final activeSchedules =
        await AwesomeNotifications().listScheduledNotifications();

    debugPrint('=== SCHEDULED NOTIFICATIONS ===');
    debugPrint('Total count: ${activeSchedules.length}');

    for (int i = 0; i < activeSchedules.length; i++) {
      final schedule = activeSchedules[i];
      debugPrint('----- Notification ${i + 1} -----');
      debugPrint('ID: ${schedule.content?.id}');
      debugPrint('Title: ${schedule.content?.title}');
      debugPrint('Body: ${schedule.content?.body}');
      debugPrint('Channel: ${schedule.content?.channelKey}');
      debugPrint('Schedule: ${schedule.schedule?.toMap()}');
      debugPrint('Payload: ${schedule.content?.payload}');
    }
    debugPrint('==============================');
  }

  /// Parse date and time strings into a DateTime object
  static DateTime? parseDateTimeStrings(String date, String time) {
    try {
      // First try the expected format: date = 'yyyy-MM-dd', time = 'HH:mm'
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      return dateFormat.parse('$date $time');
    } catch (e) {
      debugPrint('Error parsing date/time: $e');

      // Try multiple different date formats
      try {
        // Try format "MMM dd, yyyy" (e.g., "Apr 28, 2025")
        final parsedDate = DateFormat('MMM dd, yyyy').parse(date);
        debugPrint('Successfully parsed date with format: MMM dd, yyyy');

        DateTime? parsedTime;

        // Try different time formats
        try {
          // Try 12-hour format with AM/PM (e.g., "5:14 PM")
          parsedTime = DateFormat('h:mm a').parse(time);
          debugPrint('Successfully parsed time with format: h:mm a');
        } catch (e) {
          try {
            // Try 24-hour format (e.g., "17:14")
            parsedTime = DateFormat('HH:mm').parse(time);
            debugPrint('Successfully parsed time with format: HH:mm');
          } catch (e) {
            debugPrint('Failed to parse time: $e');
            return null;
          }
        }

        // Combine date and time
        final combinedDateTime = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          parsedTime!.hour,
          parsedTime.minute,
        );

        debugPrint('Parsed time to: ${parsedTime.hour}:${parsedTime.minute}');
        debugPrint('Fallback combined scheduled date: $combinedDateTime');

        return combinedDateTime;
      } catch (e) {
        debugPrint('Error on format "MMM dd, yyyy": $e');

        // Try alternative formats like 'dd-MM-yyyy'
        try {
          final parts = date.split('-');
          if (parts.length == 3) {
            final reformattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
            final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
            return dateFormat.parse('$reformattedDate $time');
          }
        } catch (e) {
          debugPrint('Error on second parsing attempt: $e');
        }
      }

      return null;
    }
  }

  /// Improved scheduling of todo notifications
  static Future<bool> scheduleImprovedTodoNotification({
    required String todoId,
    required String title,
    required String date,
    required String time,
  }) async {
    try {
      // First ensure permissions are granted
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        await requestPermissions();
      }

      // Parse the date and time
      final scheduledDate = parseDateTimeStrings(date, time);
      if (scheduledDate == null) {
        debugPrint('Failed to parse date and time: date=$date, time=$time');
        return false;
      }

      // Check if the date is in the past
      if (scheduledDate.isBefore(DateTime.now())) {
        debugPrint('Scheduled date is in the past: $scheduledDate');
        return false;
      }

      // Create a unique notification ID from the todo ID
      final notificationId = todoId.hashCode;

      debugPrint(
          'Creating improved todo notification with ID: $notificationId');
      debugPrint('Scheduled for: ${scheduledDate.toIso8601String()}');

      // Schedule the notification with both allowWhileIdle and preciseAlarm
      final result = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'todo_channel', // Use the dedicated todo channel
          title: 'Task Reminder',
          body: title,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          criticalAlert: true, // Use critical alert for important reminders
          payload: {
            'todoId': todoId,
            'scheduledTime': scheduledDate.toIso8601String(),
          },
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledDate,
          allowWhileIdle: true,
          preciseAlarm: true,
          repeats: false,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'MARK_DONE',
            label: 'Mark Done',
          ),
        ],
      );

      debugPrint('Todo notification scheduling result: $result');

      // If successful, log the scheduled notification details
      if (result) {
        debugNotification(notificationId, title, scheduledDate);
      }

      return result;
    } catch (e) {
      debugPrint('Error scheduling todo notification: $e');
      return false;
    }
  }

  /// Helper method to debug notification details
  static void debugNotification(int id, String title, DateTime scheduledDate) {
    debugPrint('=== SCHEDULED TODO NOTIFICATION ===');
    debugPrint('ID: $id');
    debugPrint('Title: $title');
    debugPrint('Scheduled for: ${scheduledDate.toIso8601String()}');
    debugPrint('Scheduled datetime parts:');
    debugPrint('  Year: ${scheduledDate.year}');
    debugPrint('  Month: ${scheduledDate.month}');
    debugPrint('  Day: ${scheduledDate.day}');
    debugPrint('  Hour: ${scheduledDate.hour}');
    debugPrint('  Minute: ${scheduledDate.minute}');
    debugPrint('================================');
  }

  /// Check exact alarm permission (required on Android 12+)
  static Future<bool> checkExactAlarmPermission() async {
    // Check if notifications are allowed in general first
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();

    // Since ScheduleExactAlarm is not available as a constant,
    // we'll fall back to general notification permission check
    debugPrint('General notification permission: $isAllowed');

    return isAllowed;
  }

  /// Request exact alarm permission
  static Future<void> requestExactAlarmPermission() async {
    // Request general notification permissions instead since
    // ScheduleExactAlarm constant doesn't exist
    await AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Badge,
        NotificationPermission.Vibration,
      ],
    );

    // Debug message about exact alarm permission
    debugPrint(
        'Note: For Android 12+, exact alarm permission must be granted in system settings');
  }

  /// Show a dialog to guide users to enable exact alarm permission
  static Future<void> showExactAlarmPermissionDialog(
      BuildContext context) async {
    if (!Platform.isAndroid) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exact Alarm Permission'),
        content: const Text(
          'For reliable notifications, this app needs permission to schedule exact alarms.\n\n'
          'Please go to Settings > Apps > MoodScribe > Permissions > Alarms & Reminders and enable "Allow precise alarms".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAndroidSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Helper method to open Android system settings
  static Future<void> _openAndroidSettings() async {
    try {
      await AwesomeNotifications().showNotificationConfigPage();
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }
}
