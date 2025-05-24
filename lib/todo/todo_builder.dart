import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/todo/empty_state.dart';
import 'package:diary/components/todo/todo_dialogs.dart';
import 'package:diary/components/todo/todo_item.dart';
import 'package:diary/services/todo_service.dart';
import 'package:diary/utils/search_state.dart';
import 'package:flutter/material.dart';

class TodoBuilder extends StatefulWidget {
  final SearchState searchState;

  const TodoBuilder({
    super.key,
    required this.searchState,
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
      stream: _todoService.getTodos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
                strokeWidth: 3,
              ),
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
          return const EmptyTodoList();
        }

        // Sort todos - pending first, then completed
        filteredTodos.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aIsDone = aData['isDone'] as bool? ?? false;
          final bIsDone = bData['isDone'] as bool? ?? false;

          if (aIsDone == bIsDone) {
            // If same completion status, sort by date (if available)
            final aDate = aData['date'] as String? ?? '';
            final bDate = bData['date'] as String? ?? '';
            if (aDate.isNotEmpty && bDate.isNotEmpty) {
              return bDate.compareTo(aDate); // Newer dates first
            }
            return 0;
          }

          // Pending tasks first, then completed tasks
          return aIsDone ? 1 : -1;
        });

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: ListView.builder(
              itemCount: filteredTodos.length,
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 24),
              physics: const BouncingScrollPhysics(),
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
            ),
          ),
        );
      },
    );
  }
}
