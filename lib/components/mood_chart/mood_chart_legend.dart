import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The legend component explaining what the chart colors represent
class MoodChartLegend extends StatelessWidget {
  final int stressValue;
  final int nonStressValue;

  const MoodChartLegend({
    super.key,
    required this.stressValue,
    required this.nonStressValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Using only monochrome colors (black, white, and grayscale)
    final positiveColor = isDarkMode
        ? const Color(0xFF4CAF50)
        : const Color(0xFF8BC34A); // Green colors for non-stress
    final stressedColor = isDarkMode
        ? const Color(0xFFE53935)
        : const Color(0xFFFF5252); // Red colors for stress

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surface.withOpacity(0.7)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          _buildLegendItem(
            context: context,
            color: stressedColor,
            label: 'Stress',
            value: stressValue,
          ),
          const SizedBox(height: 12),
          _buildLegendItem(
            context: context,
            color: positiveColor,
            label: 'No Stress',
            value: nonStressValue,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required BuildContext context,
    required Color color,
    required String label,
    required int value,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$value',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
