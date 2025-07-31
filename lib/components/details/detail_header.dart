import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Header widget showing date and mood for diary entry details
class DetailHeader extends StatelessWidget {
  final DateTime date;
  final String mood;

  const DetailHeader({
    super.key,
    required this.date,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getMoodColor(String mood, bool background) {
      final isStress = mood.toLowerCase().contains('stress') &&
          !mood.toLowerCase().contains('no stress');

      if (background) {
        return isStress
            ? (isDark ? Colors.red.withAlpha(51) : Colors.red[50]!)
            : (isDark ? Colors.green.withAlpha(51) : Colors.green[50]!);
      } else {
        return isStress
            ? (isDark ? Colors.red[300]! : Colors.red[700]!)
            : (isDark ? Colors.green[300]! : Colors.green[700]!);
      }
    }

    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 16,
          color: theme.hintColor,
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat('MMM dd, yyyy').format(date),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: getMoodColor(mood, true),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            mood,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: getMoodColor(mood, false),
            ),
          ),
        ),
      ],
    );
  }
}
