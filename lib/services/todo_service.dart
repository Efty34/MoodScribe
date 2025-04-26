import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';
import 'package:http/http.dart' as http;

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

  // Add new todo - only requires title from frontend
  Future<void> addTodo({
    required String title,
    String? date,
    String? time,
  }) async {
    if (userId == null) return;

    // Determine category using backend API
    final category = await _determineCategory(title);

    await _firestore.collection('users').doc(userId).collection('todos').add({
      'title': title,
      'date': date ?? '',
      'time': time ?? '',
      'isDone': false,
      'category': category,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Update todo - only requires title from frontend, category is determined by backend
  Future<void> updateTodo({
    required String todoId,
    required String title,
    String? date,
    String? time,
    String?
        category, // This param will be ignored as category is determined by backend
  }) async {
    if (userId == null) return;

    // Always determine new category using backend API
    final todoCategory = await _determineCategory(title);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todoId)
        .update({
      'title': title,
      'date': date ?? '',
      'time': time ?? '',
      'category': todoCategory,
    });
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

  // Delete todo
  Future<void> deleteTodo(String todoId) async {
    if (userId == null) return;

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
