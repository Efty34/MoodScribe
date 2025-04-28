import 'package:awesome_notifications/awesome_notifications.dart';
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
      ReceivedNotification receivedNotification) async {
    debugPrint(
        'Notification action received: ${receivedNotification.toMap().toString()}');

    // Navigate according to notification payload data
    if (receivedNotification.payload != null &&
        receivedNotification.payload!.containsKey('scheduledTime')) {
      debugPrint(
          'This notification was scheduled for: ${receivedNotification.payload!['scheduledTime']}');
    }
  }

  /// Check all active scheduled notifications
  static Future<void> checkActiveScheduledNotifications() async {
    final activeSchedules =
        await AwesomeNotifications().listScheduledNotifications();
    debugPrint('Active scheduled notifications: ${activeSchedules.length}');

    for (var schedule in activeSchedules) {
      debugPrint(
          'Scheduled notification: ${schedule.content?.id} at ${schedule.schedule?.toMap()}');
    }
  }
}
