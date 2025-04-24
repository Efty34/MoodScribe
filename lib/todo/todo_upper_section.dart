import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/pages/add_todo_page.dart';
import 'package:diary/services/todo_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoUpperSection extends StatefulWidget {
  final TabController tabController;
  const TodoUpperSection({
    super.key,
    required this.tabController,
  });
  @override
  State<TodoUpperSection> createState() => _TodoUpperSectionState();
}

class _TodoUpperSectionState extends State<TodoUpperSection>
    with SingleTickerProviderStateMixin {
  final TodoService _todoService = TodoService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: _todoService.getTodos(),
      builder: (context, snapshot) {
        int totalTasks = 0;
        int completedTasks = 0;
        int pendingTasks = 0;
        if (snapshot.hasData) {
          totalTasks = snapshot.data!.docs.length;
          completedTasks = snapshot.data!.docs
              .where((doc) => (doc.data() as Map)['isDone'] == true)
              .length;
          pendingTasks = totalTasks - completedTasks;
        }
        final completionPercentage =
            totalTasks == 0 ? 0.0 : (completedTasks / totalTasks);

        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black12 : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Section 1: Header with title and add button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Tasks',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          '$completedTasks of $totalTasks tasks completed',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    _buildAddButton(theme, isDark),
                  ],
                ),
                // Section 2: Progress bar
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          // Background track
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.colorScheme.onSurface.withOpacity(0.1)
                                  : theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          // Progress indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            height: 8,
                            width: MediaQuery.of(context).size.width *
                                (completionPercentage * 0.88),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${(completionPercentage * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Section 3: Tab bar
                _buildCompactTabBar(
                    theme, isDark, pendingTasks, completedTasks),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddButton(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        _showAddTodoPage(context);
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary
                        .withOpacity(isDark ? 0.2 : 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                size: 24,
                color: theme.colorScheme.secondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactTabBar(
      ThemeData theme, bool isDark, int pendingCount, int completedCount) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.4)
            : theme.colorScheme.surfaceContainerLowest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: widget.tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        labelPadding: EdgeInsets.zero,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.0,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 12.0),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return theme.colorScheme.primary.withOpacity(0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return theme.colorScheme.primary.withOpacity(0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return theme.colorScheme.primary.withOpacity(0.12);
            }
            if (states.contains(WidgetState.selected)) {
              return theme.colorScheme.primary;
            }
            if (states.contains(WidgetState.disabled)) {
              return theme.colorScheme.onSurface.withOpacity(0.12);
            }
            return Colors.transparent; // Default state
          },
        ),
        tabs: [
          _buildTabWithCounter(
              0, Icons.pending_actions_rounded, pendingCount, theme),
          _buildTabWithCounter(
              1, Icons.task_alt_rounded, completedCount, theme),
        ],
      ),
    );
  }

  Widget _buildTabWithCounter(
      int index, IconData icon, int count, ThemeData theme) {
    final isSelected = widget.tabController.index == index;
    return Tab(
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.7,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                  shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: count > 9 ? BorderRadius.circular(7) : null,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: count > 99
                      ? Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : Text(
                          count > 9 ? '9+' : count.toString(),
                          style: TextStyle(
                            fontSize: 8,
                            height: 1,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddTodoPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTodoPage()),
    );
  }
}
