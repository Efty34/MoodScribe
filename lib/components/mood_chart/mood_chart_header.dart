import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header section for the mood chart
class MoodChartHeader extends StatelessWidget {
  const MoodChartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Analysis',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Your emotional journey',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: theme.hintColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode
                ? theme.colorScheme.primary.withAlpha(51)
                : theme.colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.pie_chart_rounded,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
      ],
    );
  }
}
