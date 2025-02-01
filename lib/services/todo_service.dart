import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';
import 'package:diary/mood_buddy/services/gemini_service.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = AuthService().currentUser?.uid;
  final GeminiService _geminiService = GeminiService();

  // Predefined categories
  static const List<String> categories = [
    'submission',
    'shopping',
    'groceries',
    'fitness',
    'self-care',
    'social',
    'medicine',
    'default'
  ];

  // Get todos for current user
  Stream<QuerySnapshot> getTodos() {
    if (userId == null) return Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // Determine category using Gemini
  Future<String> _determineCategory(String title) async {
    try {
      final prompt = '''
Analyze this task and categorize it into one of these categories: submission, shopping, groceries, fitness, self-care, social, medicine, default.
Only respond with one word (the category).

Task: $title

Rules:
- submission: assignments, homework, projects, deadlines
- shopping: buying non-food items, clothes, electronics
- groceries: food items, ingredients, kitchen supplies
- fitness: exercise, workout, sports, physical activities
- self-care: meditation, relaxation, personal care
- social: meetings, gatherings, calls, events
- medicine: medications, doctor appointments, health-related
- default: if it doesn't fit in any other category

Category:''';

      String response = await _geminiService.getResponse(prompt);
      response = response.toLowerCase().trim();

      // Check if the response is a valid category
      if (categories.contains(response)) {
        return response;
      }
      return 'default';
    } catch (e) {
      print('Error determining category: $e');
      return 'default';
    }
  }

  // Add new todo
  Future<void> addTodo({
    required String title,
    String? date,
    String? time,
  }) async {
    if (userId == null) return;

    // Determine category using Gemini
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

  // Update todo
  Future<void> updateTodo({
    required String todoId,
    required String title,
    String? date,
    String? time,
  }) async {
    if (userId == null) return;

    // Determine new category using Gemini
    final category = await _determineCategory(title);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(todoId)
        .update({
      'title': title,
      'date': date ?? '',
      'time': time ?? '',
      'category': category,
    });
  }

  // Get todos by category
  Stream<QuerySnapshot> getTodosByCategory(String category) {
    if (userId == null) return Stream.empty();

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
}
