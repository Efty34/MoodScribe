import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mood_chart_utils.dart';

/// Legend section that displays percentages and counts for the mood categories
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final total = stressValue + nonStressValue;
    final positivePercentage =
        MoodChartUtils.calculatePercentage(nonStressValue, total);
    final stressedPercentage =
        MoodChartUtils.calculatePercentage(stressValue, total);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildLegendItem(
                MoodChartUtils.getPositiveColor(isDarkMode),
                'Positive',
                nonStressValue,
                positivePercentage,
                MoodChartUtils.getSubTextColor(isDarkMode),
                isDarkMode,
                constraints.maxWidth < 300,
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
            ),
            Expanded(
              child: _buildLegendItem(
                MoodChartUtils.getStressedColor(isDarkMode),
                'Stressed',
                stressValue,
                stressedPercentage,
                MoodChartUtils.getSubTextColor(isDarkMode),
                isDarkMode,
                constraints.maxWidth < 300,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    int value,
    double percentage,
    Color? textColor,
    bool isDarkMode,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    color: textColor,
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$value',
                      style: GoogleFonts.nunito(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        fontSize: isSmallScreen ? 12 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' • ${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.nunito(
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                        fontSize: isSmallScreen ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
