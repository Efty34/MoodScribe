import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';
import 'package:diary/mood_buddy/services/gemini_service.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = AuthService().currentUser?.uid;
  final GeminiService _geminiService = GeminiService();

  // Predefined categories
  static const List<String> categories = [
    'exam',
    'submission',
    'shopping',
    'groceries',
    'fitness',
    'self-care',
    'food',
    'social',
    'medicine',
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

  // Determine category using Gemini
  Future<String> _determineCategory(String title) async {
    try {
      final prompt = '''
Analyze this task title and categorize it into one of these categories. Only respond with a single word (the category name in lowercase).

Task: "$title"

Categories and their contexts:
- exam: Academic tests, exams, quizzes, studying, test preparation, exam dates, revision
- submission: Academic assignments, homework, projects, deadlines, papers, reports
- shopping: Non-food items, clothes, electronics, accessories, household items
- groceries: Food items, ingredients, kitchen supplies, fruits, vegetables
- fitness: Exercise, workout, sports, physical activities, gym, running, yoga
- self-care: Meditation, relaxation, personal care, mental health, skincare
- food: Cooking, eating out, food orders, dining, meal preparation, restaurants
- social: Meetings, gatherings, calls, events, parties, social activities
- medicine: Medications, doctor appointments, health-related tasks, medical checkups
- default: Tasks that don't clearly fit into any other category

Response format: Only the category name in lowercase, nothing else.
''';

      String response = await _geminiService.getResponse(prompt);
      response = response.toLowerCase().trim();

      // Remove any punctuation or extra text
      response = response.replaceAll(RegExp(r'[^\w\s]'), '');

      // Extract just the first word
      response = response.split(' ').first;

      // Validate the category
      if (categories.contains(response)) {
        return response;
      }

      print('Invalid category from Gemini: $response for task: $title');
      return 'default';
    } catch (e) {
      print('Error determining category: $e for task: $title');
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
    String? category,
  }) async {
    if (userId == null) return;

    // Use provided category or determine new category using Gemini
    final todoCategory = category != null && category.isNotEmpty
        ? category.toLowerCase()
        : await _determineCategory(title);

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
