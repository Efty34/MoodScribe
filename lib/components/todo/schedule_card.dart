import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function() onPickDate;
  final Function() onPickTime;

  const ScheduleCard({
    super.key,
    required this.theme,
    required this.isDark,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
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
            'Schedule',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Date picker
          _buildPickerButton(
            context,
            theme,
            isDark,
            icon: Icons.event_rounded,
            label: selectedDate == null
                ? 'Set date'
                : DateFormat('EEE, MMM d, yyyy').format(selectedDate!),
            onTap: onPickDate,
          ),

          const SizedBox(height: 12),

          // Time picker
          _buildPickerButton(
            context,
            theme,
            isDark,
            icon: Icons.schedule_rounded,
            label: selectedTime == null
                ? 'Set time'
                : selectedTime!.format(context),
            onTap: onPickTime,
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerLow.withOpacity(0.3)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: label.startsWith('Set')
                    ? theme.colorScheme.onSurface.withOpacity(0.6)
                    : theme.colorScheme.onSurface,
                fontWeight:
                    label.startsWith('Set') ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
