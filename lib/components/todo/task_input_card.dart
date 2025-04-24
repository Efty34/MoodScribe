import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ThemeData theme;

  const TaskInputCard({
    super.key,
    required this.controller,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Description',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 3,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              hintStyle: GoogleFonts.poppins(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 16,
              ),
              filled: true,
              fillColor: isDark
                  ? theme.colorScheme.surfaceContainerLow.withOpacity(0.3)
                  : theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your task';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
