import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakHeader extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const StreakHeader({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Writing Streak',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.primary.withAlpha(38)
                        : theme.colorScheme.primary.withAlpha(17),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$currentStreak days',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Best: $longestStreak days',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: theme.hintColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),

        // Refresh button
        // IconButton(
        //   icon: isRefreshing
        //       ? SizedBox(
        //           width: 20,
        //           height: 20,
        //           child: CircularProgressIndicator(
        //             strokeWidth: 2,
        //             color: theme.colorScheme.primary,
        //           ),
        //         )
        //       : Icon(
        //           Icons.refresh_rounded,
        //           color: theme.colorScheme.primary.withAlpha(204),
        //         ),
        //   onPressed: isRefreshing ? null : onRefresh,
        //   tooltip: 'Refresh calendar',
        // ),
      ],
    );
  }
}
