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
      case 'work':
        return Icons.work_outline_rounded;
      case 'personal':
        return Icons.person_outline_rounded;
      case 'health':
        return Icons.health_and_safety_outlined;
      case 'finance':
        return Icons.account_balance_wallet_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'travel':
        return Icons.flight_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'fitness':
        return Icons.fitness_center_outlined;
      default:
        return Icons.category_outlined;
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
    final bool isDone = data['isDone'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
                .withOpacity(isDone ? 0.5 : 0.8)
            : isDone
                ? theme.colorScheme.surfaceContainerLow.withOpacity(0.7)
                : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outline.withOpacity(0.08)
              : theme.colorScheme.outline.withOpacity(0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.12)
                : Colors.black.withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showUpdateDialog(context, todoId, data),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _buildCheckbox(theme, todoService),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    searchQuery.isNotEmpty
                        ? _highlightText(
                            data['title'] ?? '', searchQuery, context)
                        : Text(
                            data['title'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                              color: isDone
                                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),

                    // Dates and Times
                    if ((data['date']?.isNotEmpty ?? false) ||
                        (data['time']?.isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                      ),

                    // Category and Notification
                    Row(
                      children: [
                        _buildCategoryBadge(theme, isDark),
                        if (data['enableNotification'] == true) ...[
                          const SizedBox(width: 8),
                          _buildNotificationBadge(theme),
                        ],
                        const Spacer(),
                        _buildActionIcon(
                          icon: Icons.edit_outlined,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                          onTap: () => showUpdateDialog(context, todoId, data),
                        ),
                        const SizedBox(width: 4),
                        _buildActionIcon(
                          icon: Icons.delete_outline,
                          color: theme.colorScheme.error.withOpacity(0.7),
                          onTap: () async {
                            final shouldDelete =
                                await showDeleteConfirmation(context, todoId);
                            if (shouldDelete) {
                              await todoService.deleteTodo(todoId);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(ThemeData theme, TodoService todoService) {
    final bool isDone = data['isDone'] ?? false;

    return SizedBox(
      width: 24,
      height: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () async {
            await todoService.toggleTodoStatus(
              todoId: todoId,
              isDone: !isDone,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isDone ? theme.colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDone
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: isDone
                ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(data['category'] ?? 'default'),
            color: theme.colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            data['category']?.toString().toUpperCase() ?? 'DEFAULT',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: theme.colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'ALERT',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primaryContainer.withOpacity(0.2)
            : theme.colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: theme.colorScheme.primary.withOpacity(0.8),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: theme.colorScheme.primary.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}
