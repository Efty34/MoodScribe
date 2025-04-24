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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(todoId),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(Icons.edit_outlined, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Text(
              'Edit',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline, color: theme.colorScheme.secondary),
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHigh.withOpacity(0.8)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.outline.withOpacity(0.6)
                : theme.colorScheme.outline.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: data['isDone'] ?? false,
                onChanged: (value) async {
                  await todoService.toggleTodoStatus(
                    todoId: todoId,
                    isDone: value ?? false,
                  );
                },
                activeColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
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
                              ? theme.colorScheme.onSurface.withOpacity(0.5)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getCategoryIcon(data['category'] ?? 'default'),
                        color: theme.colorScheme.primary,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data['category']?.toString().toUpperCase() ?? 'DEFAULT',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                )
              ],
            ),
            subtitle: (data['date']?.isNotEmpty ?? false) ||
                    (data['time']?.isNotEmpty ?? false)
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        if (data['date']?.isNotEmpty ?? false)
                          _buildChip(
                            context: context,
                            icon: Icons.calendar_today,
                            label: data['date'],
                            isDark: isDark,
                          ),
                        if (data['time']?.isNotEmpty ?? false) ...[
                          const SizedBox(width: 8),
                          _buildChip(
                            context: context,
                            icon: Icons.access_time,
                            label: data['time'],
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primaryContainer.withOpacity(0.4)
            : theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: theme.colorScheme.primary.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
