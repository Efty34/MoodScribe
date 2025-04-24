import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/todo/empty_state.dart';
import 'package:diary/components/todo/todo_dialogs.dart';
import 'package:diary/components/todo/todo_item.dart';
import 'package:diary/services/todo_service.dart';
import 'package:diary/utils/search_state.dart';
import 'package:flutter/material.dart';

class TodoBuilder extends StatefulWidget {
  final SearchState searchState;
  final bool isDone;

  const TodoBuilder({
    super.key,
    required this.searchState,
    required this.isDone,
  });

  @override
  State<TodoBuilder> createState() => _TodoBuilderState();
}

class _TodoBuilderState extends State<TodoBuilder> {
  final TodoService _todoService = TodoService();

  @override
  void initState() {
    super.initState();
    widget.searchState.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.searchState.removeListener(_onSearchChanged);
    super.dispose();
  }

  Future<bool?> _showUpdateDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) async {
    return TodoDialogs.showUpdateDialog(context, docId, data);
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, String todoId) async {
    return TodoDialogs.showDeleteConfirmation(context, todoId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _todoService.getTodosByStatus(isDone: widget.isDone),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          );
        }

        final todos = snapshot.data!.docs;

        // Filter todos based on search query
        final filteredTodos = widget.searchState.query.isEmpty
            ? todos
            : todos.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = (data['title'] as String).toLowerCase();
                final query = widget.searchState.query.toLowerCase();
                return title.contains(query);
              }).toList();

        if (filteredTodos.isEmpty) {
          if (widget.searchState.query.isNotEmpty) {
            return EmptySearchResults(searchQuery: widget.searchState.query);
          }
          return EmptyTodoList(isDone: widget.isDone);
        }

        return ListView.builder(
          itemCount: filteredTodos.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) {
            final todo = filteredTodos[index];
            final data = todo.data() as Map<String, dynamic>;

            return TodoItem(
              todoId: todo.id,
              data: data,
              searchQuery: widget.searchState.query,
              showUpdateDialog: _showUpdateDialog,
              showDeleteConfirmation: _showDeleteConfirmation,
            );
          },
        );
      },
    );
  }
}
