import 'package:diary/components/mood_chart/mood_summary_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EntryDetailsBottomSheet extends StatelessWidget {
  final DateTime date;
  final int entries;
  final Map<String, int> breakdown;

  const EntryDetailsBottomSheet({
    super.key,
    required this.date,
    required this.entries,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Date header and entry count
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: entries > 0
                            ? (isDark
                                ? theme.colorScheme.primary.withAlpha(51)
                                : theme.colorScheme.primary.withAlpha(25))
                            : theme.colorScheme.surfaceContainerHighest
                                .withAlpha(isDark ? 127 : 25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        entries > 0
                            ? Icons.edit_note_rounded
                            : Icons.notes_rounded,
                        color: entries > 0
                            ? theme.colorScheme.primary
                            : theme.hintColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        entries > 0
                            ? '$entries ${entries == 1 ? 'entry' : 'entries'} on this day'
                            : 'No entries on this day',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Entry breakdown by mood (Stress/Non-Stress)
          if (entries > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Entry Breakdown',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stress entries
                  MoodSummaryRow(
                    icon: Icons.mood_bad,
                    iconColor: const Color(0xFFE53935),
                    label: 'Stress',
                    count: breakdown['stress'] ?? 0,
                    total: entries,
                  ),

                  const SizedBox(height: 12),

                  // Non-stress entries
                  MoodSummaryRow(
                    icon: Icons.mood,
                    iconColor: const Color(0xFF43A047),
                    label: 'No Stress',
                    count: breakdown['no stress'] ?? 0,
                    total: entries,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
