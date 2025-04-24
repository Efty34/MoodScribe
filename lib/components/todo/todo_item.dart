import 'package:diary/services/todo_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoItem extends StatelessWidget {
  final String todoId;
  final Map<String, dynamic> data;
  final Function(BuildContext, String, Map<String, dynamic>) showUpdateDialog;
  final Function(BuildContext, String) showDeleteConfirmation;
  final String searchQuery;

  const TodoItem({
    super.key,
    required this.todoId,
    required this.data,
    required this.showUpdateDialog,
    required this.showDeleteConfirmation,
    this.searchQuery = '',
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'exam':
        return Icons.school;
      case 'submission':
        return Icons.assignment;
      case 'shopping':
        return Icons.shopping_bag;
      case 'groceries':
        return Icons.shopping_cart;
      case 'fitness':
        return Icons.fitness_center;
      case 'self-care':
        return Icons.spa_outlined;
      case 'food':
        return Icons.restaurant;
      case 'social':
        return Icons.people_outline;
      case 'medicine':
        return Icons.medical_services;
      default:
        return Icons.add_to_photos_sharp;
    }
  }

  Widget _highlightText(String text, String query, BuildContext context) {
    final theme = Theme.of(context);

    if (query.isEmpty) {
      return Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      );
    }

    List<TextSpan> spans = [];
    final String lowercaseText = text.toLowerCase();
    final String lowercaseQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final int index = lowercaseText.indexOf(lowercaseQuery, start);
      if (index == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
          backgroundColor: theme.colorScheme.primaryContainer,
        ),
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TodoService todoService = TodoService();

    return Dismissible(
      key: Key(todoId),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Icon(Icons.edit_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Edit',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outline, color: Colors.white),
          ],
        ),
      ),
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await todoService.deleteTodo(todoId);
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await showUpdateDialog(context, todoId, data);
          return false;
        } else {
          final shouldDelete = await showDeleteConfirmation(context, todoId);
          return shouldDelete;
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: data['isDone'] ?? false,
                onChanged: (value) async {
                  await todoService.toggleTodoStatus(
                    todoId: todoId,
                    isDone: value ?? false,
                  );
                },
                activeColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchQuery.isNotEmpty
                  ? _highlightText(data['title'] ?? '', searchQuery, context)
                  : Text(
                      data['title'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: data['isDone'] == true
                            ? TextDecoration.lineThrough
                            : null,
                        color: data['isDone'] == true
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _getCategoryIcon(data['category'] ?? 'default'),
                      color: Theme.of(context).colorScheme.primary,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['category']?.toString().toUpperCase() ?? 'DEFAULT',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            ],
          ),
          subtitle: data['date']?.isNotEmpty ??
                  false || data['time']?.isNotEmpty ??
                  false
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      if (data['date']?.isNotEmpty ?? false)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data['date'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (data['time']?.isNotEmpty ?? false) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data['time'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
