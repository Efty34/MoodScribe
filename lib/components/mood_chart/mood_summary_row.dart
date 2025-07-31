import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodSummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final int count;
  final int total;

  const MoodSummaryRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = total > 0 ? (count / total) * 100 : 0;

    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(isDark ? 51 : 27),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Label and count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$count ${count == 1 ? 'entry' : 'entries'} (${percentage.toStringAsFixed(0)}%)',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withAlpha(178),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total > 0 ? count / total : 0,
                  backgroundColor: iconColor.withAlpha(17),
                  color: iconColor.withAlpha(isDark ? 204 : 178),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
