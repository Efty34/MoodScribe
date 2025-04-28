import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';
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
      print('Attempting to schedule notification for: $title at $date $time');

      // Parse date
      final dateFormat = DateFormat('MMM dd, yyyy');
      final DateTime todoDate;
      try {
        todoDate = dateFormat.parse(date);
      } catch (e) {
        print('Failed to parse date: $date - $e');
        return;
      }

      // Parse time string - handle different time formats
      TimeOfDay timeOfDay;
      try {
        // Try different time formats
        DateTime parsedTime;
        try {
          // Try standard format (e.g., "1:30 PM")
          parsedTime = DateFormat.jm().parse(time);
        } catch (e) {
          try {
            // Try 24-hour format (e.g., "13:30")
            parsedTime = DateFormat.Hm().parse(time);
          } catch (e2) {
            // Last attempt with a more flexible format
            parsedTime = DateFormat('h:mm a').parse(time);
          }
        }

        timeOfDay = TimeOfDay(
          hour: parsedTime.hour,
          minute: parsedTime.minute,
        );

        print(
            'Successfully parsed time to: ${timeOfDay.hour}:${timeOfDay.minute}');
      } catch (e) {
        print('Failed to parse time: $time - $e');
        return;
      }

      // Combine date and time
      final scheduledDate = DateTime(
        todoDate.year,
        todoDate.month,
        todoDate.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      print('Combined scheduled date: $scheduledDate');

      // Skip if scheduled time is in the past
      if (scheduledDate.isBefore(DateTime.now())) {
        print('Skipping notification for past date: $scheduledDate');
        return;
      }

      // Create a unique notification ID from the todo ID
      final notificationId = todoId.hashCode;

      print('Creating notification with ID: $notificationId');

      // Schedule the notification
      final result = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'todo_channel',
          title: 'Task Reminder',
          body: title,
          notificationLayout: NotificationLayout.Default,
          payload: {
            'todoId': todoId,
            'scheduledTime': scheduledDate.toIso8601String(),
          },
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate),
      );

      print('Notification scheduling result: $result');

      if (result) {
        print('Notification successfully scheduled for: $scheduledDate');
      } else {
        print('Failed to schedule notification');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
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

  // Get todos by completion status
  Stream<QuerySnapshot> getTodosByStatus({required bool isDone}) {
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .where('isDone', isEqualTo: isDone)
        .orderBy('created_at', descending: true)
        .snapshots();
  }
}
