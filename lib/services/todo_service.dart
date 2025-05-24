import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';
import 'package:diary/notification/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = AuthService().currentUser?.uid;
  // API endpoint for category determination
  final String _categoryApiUrl =
      'https://mood-scribe-recommendation-ai-agent.vercel.app/api/todo/category';

  // Predefined categories
  static const List<String> categories = [
    'work',
    'personal',
    'health',
    'finance',
    'shopping',
    'education',
    'travel',
    'home',
    'fitness',
    'default'
  ];

  // Get todos for current user
  Stream<QuerySnapshot> getTodos() {
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // Backend API call to determine category
  Future<String> _determineCategory(String title) async {
    try {
      final requestData = {
        'task': title,
      };

      final response = await http.post(
        Uri.parse(_categoryApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Get category from response and convert to lowercase for consistency
        String category = data['category']?.toString().toLowerCase() ?? '';

        // No need to validate against predefined categories
        // as we're trusting the backend's response
        if (category.isNotEmpty) {
          return category;
        }

        print('Empty category from API for task: $title');
        return 'default';
      } else {
        print(
            'API error: ${response.statusCode} - ${response.body} for task: $title');
        return 'default';
      }
    } catch (e) {
      print('Error determining category: $e for task: $title');
      return 'default';
    }
  }

  // Schedule a notification for a todo
  Future<void> scheduleNotification({
    required String todoId,
    required String title,
    required String date,
    required String time,
  }) async {
    // Skip if date or time is not set
    if (date.isEmpty || time.isEmpty) return;

    try {
      // Use the improved notification scheduling from NotificationUtils
      final result = await NotificationUtils.scheduleImprovedTodoNotification(
        todoId: todoId,
        title: title,
        date: date,
        time: time,
      );

      if (!result) {
        // If the improved method fails, try the fallback method
        debugPrint('Improved notification failed. Trying fallback method...');
        await _scheduleFallbackNotification(todoId, title, date, time);
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Fallback notification method using the original approach
  Future<void> _scheduleFallbackNotification(
    String todoId,
    String title,
    String date,
    String time,
  ) async {
    try {
      debugPrint(
          'Fallback: Scheduling notification for: $title at $date $time');

      // First ensure permissions are granted
      await NotificationUtils.requestPermissions();
      await NotificationUtils.requestExactAlarmPermission();

      // Try multiple date formats
      DateTime? scheduledDate;

      // Try different date format parsers
      final List<DateFormat> dateFormats = [
        DateFormat('MMM dd, yyyy'), // "Apr 28, 2025"
        DateFormat('yyyy-MM-dd'), // "2025-04-28"
        DateFormat('dd-MM-yyyy'), // "28-04-2025"
        DateFormat('dd/MM/yyyy'), // "28/04/2025"
      ];

      DateTime? todoDate;
      for (var format in dateFormats) {
        try {
          todoDate = format.parse(date);
          debugPrint('Successfully parsed date with format: ${format.pattern}');
          break;
        } catch (e) {
          // Continue to next format
        }
      }

      if (todoDate == null) {
        debugPrint('Failed to parse date with any format: $date');
        return;
      }

      // Parse time string - handle different time formats
      TimeOfDay? timeOfDay;
      try {
        // Try different time formats
        DateTime? parsedTime;

        // List of time formats to try
        final List<DateFormat> timeFormats = [
          DateFormat.jm(), // "1:30 PM"
          DateFormat.Hm(), // "13:30"
          DateFormat('h:mm a'), // "1:30 pm"
          DateFormat('HH:mm'), // "13:30"
        ];

        for (var format in timeFormats) {
          try {
            parsedTime = format.parse(time);
            debugPrint(
                'Successfully parsed time with format: ${format.pattern}');
            break;
          } catch (e) {
            // Continue to next format
          }
        }

        if (parsedTime != null) {
          timeOfDay = TimeOfDay(
            hour: parsedTime.hour,
            minute: parsedTime.minute,
          );
          debugPrint('Parsed time to: ${timeOfDay.hour}:${timeOfDay.minute}');
        } else {
          // Try to manually parse HH:MM format
          final parts = time.split(':');
          if (parts.length == 2) {
            final hour = int.tryParse(parts[0].trim());

            // Handle the second part which might have AM/PM
            String minutePart = parts[1].trim();
            int? minute;
            bool isPM = false;

            if (minutePart.toLowerCase().contains('pm')) {
              isPM = true;
              minutePart = minutePart.toLowerCase().replaceAll('pm', '').trim();
            } else if (minutePart.toLowerCase().contains('am')) {
              minutePart = minutePart.toLowerCase().replaceAll('am', '').trim();
            }

            minute = int.tryParse(minutePart);

            if (hour != null && minute != null) {
              int adjustedHour = hour;
              // Adjust hour for PM if in 12-hour format
              if (isPM && hour < 12) {
                adjustedHour += 12;
              }

              timeOfDay = TimeOfDay(hour: adjustedHour, minute: minute);
              debugPrint(
                  'Manually parsed time to: ${timeOfDay.hour}:${timeOfDay.minute}');
            }
          }
        }
      } catch (e) {
        debugPrint('Error in time parsing: $e');
      }

      if (timeOfDay == null) {
        debugPrint('Failed to parse time with any method: $time');
        return;
      }

      // Combine date and time
      scheduledDate = DateTime(
        todoDate.year,
        todoDate.month,
        todoDate.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      debugPrint('Fallback combined scheduled date: $scheduledDate');

      // Skip if scheduled time is in the past
      if (scheduledDate.isBefore(DateTime.now())) {
        debugPrint('Skipping notification for past date: $scheduledDate');
        return;
      }

      // Create a unique notification ID from the todo ID
      final notificationId = todoId.hashCode;

      // Schedule the notification with both channels
      for (String channelKey in ['notification_channel', 'todo_channel']) {
        final result = await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId + (channelKey == 'todo_channel' ? 1 : 0),
            channelKey: channelKey,
            title: 'Task Reminder',
            body: title,
            wakeUpScreen: true,
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.Default,
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

        debugPrint(
            'Fallback notification scheduling result for $channelKey: $result');
      }

      // Debug current scheduled notifications
      await NotificationUtils.debugScheduledNotifications();
    } catch (e) {
      debugPrint('Error in fallback notification: $e');
    }
  }

  // Cancel a scheduled notification for a todo
  Future<void> cancelNotification(String todoId) async {
    final notificationId = todoId.hashCode;
    await AwesomeNotifications().cancel(notificationId);
  }

  // Add new todo - includes notification handling
  Future<void> addTodo({
    required String title,
    String? date,
    String? time,
    bool enableNotification = false,
  }) async {
    if (userId == null) return;

    try {
      // Determine category using backend API
      final category = await _determineCategory(title);

      // Add document to Firestore and get the new document ID
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('todos')
          .add({
        'title': title,
        'date': date ?? '',
        'time': time ?? '',
        'isDone': false,
        'category': category,
        'enableNotification': enableNotification,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Schedule notification if enabled and date/time are provided
      if (enableNotification &&
          date != null &&
          date.isNotEmpty &&
          time != null &&
          time.isNotEmpty) {
        try {
          await scheduleNotification(
            todoId: docRef.id,
            title: title,
            date: date,
            time: time,
          );
        } catch (e) {
          print('Error scheduling notification: $e');
          // Continue even if notification scheduling fails
        }
      }
    } catch (e) {
      print('Error adding todo: $e');
      throw e; // Re-throw to allow UI to handle the error
    }
  }

  // Update todo - includes notification handling
  Future<void> updateTodo({
    required String todoId,
    required String title,
    String? date,
    String? time,
    bool? enableNotification,
    String?
        category, // This param will be ignored as category is determined by backend
  }) async {
    if (userId == null) return;

    // Always determine new category using backend API
    final todoCategory = await _determineCategory(title);

    final Map<String, dynamic> updateData = {
      'title': title,
      'date': date ?? '',
      'time': time ?? '',
      'category': todoCategory,
    };

    // Only include enableNotification in the update if it was provided
    if (enableNotification != null) {
      updateData['enableNotification'] = enableNotification;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todoId)
        .update(updateData);

    // Handle notification scheduling/cancellation
    if (enableNotification == true && date != null && time != null) {
      await scheduleNotification(
        todoId: todoId,
        title: title,
        date: date,
        time: time,
      );
    } else if (enableNotification == false) {
      await cancelNotification(todoId);
    }
  }

  // Update todo completion status
  Future<void> updateTodoCompletion(String todoId, bool isCompleted) async {
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todoId)
        .update({
      'isDone': isCompleted,
    });
  }

  // Get todos by category
  Stream<QuerySnapshot> getTodosByCategory(String category) {
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .where('category', isEqualTo: category)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // Toggle todo completion
  Future<void> toggleTodoStatus({
    required String todoId,
    required bool isDone,
  }) async {
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todoId)
        .update({
      'isDone': isDone,
    });
  }

  // Delete todo - also cancels any scheduled notification
  Future<void> deleteTodo(String todoId) async {
    if (userId == null) return;

    // Cancel any scheduled notification
    await cancelNotification(todoId);

    // Delete the todo document
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todoId)
        .delete();
  }
}
