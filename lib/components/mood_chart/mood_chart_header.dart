import 'package:flutter/material.dart';

import 'mood_chart_utils.dart';

/// Header section for the mood chart
class MoodChartHeader extends StatelessWidget {
  const MoodChartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Analysis',
              style: MoodChartUtils.getTitleStyle(isDarkMode),
            ),
            Text(
              'Your emotional journey',
              style: MoodChartUtils.getSubtitleStyle(isDarkMode),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.blue[900]!.withOpacity(0.3)
                : Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.pie_chart_rounded,
            color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
            size: 22,
          ),
        ),
      ],
    );
  }
}
