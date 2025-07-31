import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class CalendarCard extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final Function(DateTime) onDateTap;

  const CalendarCard({
    super.key,
    required this.datasets,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color greenColor = Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withAlpha(178)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(51)
                : Colors.black.withAlpha(12),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -3,
          ),
        ],
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: HeatMap(
              datasets: datasets,
              colorMode: ColorMode.color,
              defaultColor: isDark
                  ? theme.dividerColor
                  : theme.colorScheme.surfaceContainerHighest,
              textColor: theme.colorScheme.onSurface,
              showColorTip: false,
              showText: true,
              scrollable: true,
              size: 30,
              colorsets: isDark
                  ? {
                      1: greenColor.withAlpha(51),
                      2: greenColor.withAlpha(102),
                      3: greenColor.withAlpha(153),
                      4: greenColor.withAlpha(204),
                      5: greenColor,
                    }
                  : {
                      1: greenColor.withAlpha(25),
                      2: greenColor.withAlpha(76),
                      3: greenColor.withAlpha(127),
                      4: greenColor.withAlpha(178),
                      5: greenColor.withAlpha(229),
                    },
              onClick: onDateTap,
              margin: const EdgeInsets.symmetric(vertical: 3),
            ),
          ),
        ),
      ),
    );
  }
}
