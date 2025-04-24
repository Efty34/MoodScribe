import 'package:flutter/material.dart';

class TodoDateTimePickers {
  static Future<DateTime?> pickDate(BuildContext context,
      {DateTime? initialDate}) async {
    final theme = Theme.of(context);
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              surface: theme.colorScheme.surface,
            ),
            dialogBackgroundColor: theme.colorScheme.surface,
          ),
          child: child!,
        );
      },
    );
  }

  static Future<TimeOfDay?> pickTime(BuildContext context,
      {TimeOfDay? initialTime}) async {
    final theme = Theme.of(context);
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              surface: theme.colorScheme.surface,
            ),
            dialogBackgroundColor: theme.colorScheme.surface,
          ),
          child: child!,
        );
      },
    );
  }
}
