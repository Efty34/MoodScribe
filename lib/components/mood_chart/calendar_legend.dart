import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color greenColor = Colors.green;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(
          5,
          (index) => Container(
            width: 16,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isDark
                  ? greenColor.withAlpha((index + 1) * 51)
                  : greenColor.withAlpha(25 + index * 51),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'More',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
