import 'package:diary/components/todo/todo_dialogs.dart';
import 'package:diary/services/todo_service.dart';
import 'package:diary/utils/app_snackbar.dart';
import 'package:flutter/material.dart';

class TodoServiceProvider extends ChangeNotifier {
  final TodoService _todoService = TodoService();
  List<Map<String, dynamic>> _todos = [];

  List<Map<String, dynamic>> get todos => _todos;

  // Fetch todos from Firestore
  Future<void> fetchTodos() async {
    try {
      final snapshot = await _todoService.getTodos().first;
      _todos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error fetching todos: $e');
      rethrow;
    }
  }

  // Delete a todo
  Future<void> deleteTodo(BuildContext context, String id) async {
    try {
      final shouldDelete =
          await TodoDialogs.showDeleteConfirmation(context, id);
      if (shouldDelete) {
        await _todoService.deleteTodo(id);
        _todos.removeWhere((todo) => todo['id'] == id);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting todo: $e');
      // Show error snackbar
      if (context.mounted) {
        AppSnackBar.show(
          context: context,
          message: 'Failed to delete task: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
      rethrow;
    }
  }

  // Update todo completion status
  Future<void> toggleTodoCompletion(
      BuildContext context, String id, bool isCompleted) async {
    try {
      await _todoService.updateTodoCompletion(id, isCompleted);
      final index = _todos.indexWhere((todo) => todo['id'] == id);
      if (index != -1) {
        _todos[index]['isCompleted'] = isCompleted;
        notifyListeners();
      }

      // Show completion status message
      if (context.mounted) {
        AppSnackBar.show(
          context: context,
          message:
              isCompleted ? 'Task completed! 🎉' : 'Task marked as incomplete',
          type: isCompleted ? SnackBarType.success : SnackBarType.info,
        );
      }
    } catch (e) {
      print('Error updating todo completion: $e');
      // Show error snackbar
      if (context.mounted) {
        AppSnackBar.show(
          context: context,
          message: 'Failed to update task status',
          type: SnackBarType.error,
        );
      }
      rethrow;
    }
  }

  // Update a todo
  Future<void> updateTodo(BuildContext context, String id) async {
    try {
      final todo = _todos.firstWhere((t) => t['id'] == id);
      final updated = await TodoDialogs.showUpdateDialog(context, id, todo);
      if (updated == true) {
        await fetchTodos(); // Refresh the list
      }
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }
}
