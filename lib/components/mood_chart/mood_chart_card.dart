import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mood_chart_utils.dart';

/// The primary chart card component that displays the pie chart
class MoodChartCard extends StatefulWidget {
  final int stressValue;
  final int nonStressValue;
  final Animation<double> animation;

  const MoodChartCard({
    super.key,
    required this.stressValue,
    required this.nonStressValue,
    required this.animation,
  });

  @override
  State<MoodChartCard> createState() => _MoodChartCardState();
}

class _MoodChartCardState extends State<MoodChartCard> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final total = widget.stressValue + widget.nonStressValue;

    // Get available width to make chart responsive
    final screenWidth = MediaQuery.of(context).size.width;
    // Further reduce chart size to fix the remaining 10px overflow
    final chartSize = screenWidth > 400 ? 170.0 : screenWidth * 0.43;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.surface : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withAlpha(51)
                : Colors.black.withAlpha(12),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -2,
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
            sigmaX: 8,
            sigmaY: 8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  height: chartSize,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(
                                isDarkMode, chartSize, theme),
                            sectionsSpace: 2,
                            centerSpaceRadius: chartSize * 0.25,
                            startDegreeOffset: -90 * widget.animation.value,
                            borderData: FlBorderData(show: false),
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                              enabled: true,
                            ),
                          ),
                        ),
                      ),
                      // Center emoji or total number
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            total > 0
                                ? (widget.nonStressValue >= widget.stressValue
                                    ? Icons.sentiment_satisfied_rounded
                                    : Icons.sentiment_dissatisfied_rounded)
                                : Icons.sentiment_neutral_rounded,
                            size: 32,
                            color: theme.colorScheme.onSurface.withAlpha(178),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$total',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Entries',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      bool isDarkMode, double chartSize, ThemeData theme) {
    final total = widget.stressValue + widget.nonStressValue;
    final stressPercentage =
        MoodChartUtils.calculatePercentage(widget.stressValue, total);
    final nonStressPercentage =
        MoodChartUtils.calculatePercentage(widget.nonStressValue, total);

    // Using red color for stress and green color for non-stress
    final positiveColor =
        MoodChartUtils.getPositiveColor(isDarkMode); // Green for non-stress
    final stressedColor =
        MoodChartUtils.getStressedColor(isDarkMode); // Red for stress

    // Calculate radius based on chart size
    final baseRadius = chartSize * 0.32;
    final expandedRadius = chartSize * 0.35;

    return [
      PieChartSectionData(
        color: stressedColor.withAlpha(229),
        value: stressPercentage * widget.animation.value,
        title:
            touchedIndex == 0 ? '${stressPercentage.toStringAsFixed(1)}%' : '',
        radius: touchedIndex == 0 ? expandedRadius : baseRadius,
        titleStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha(76),
              blurRadius: 3,
            ),
          ],
        ),
        badgeWidget: touchedIndex == 0
            ? _buildBadge('Stress', stressPercentage.toStringAsFixed(1), theme)
            : null,
        badgePositionPercentageOffset: 0.5,
      ),
      PieChartSectionData(
        color: positiveColor.withAlpha(229),
        value: nonStressPercentage * widget.animation.value,
        title: touchedIndex == 1
            ? '${nonStressPercentage.toStringAsFixed(1)}%'
            : '',
        radius: touchedIndex == 1 ? expandedRadius : baseRadius,
        titleStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha(76),
              blurRadius: 3,
            ),
          ],
        ),
        badgeWidget: touchedIndex == 1
            ? _buildBadge(
                'No Stress', nonStressPercentage.toStringAsFixed(1), theme)
            : null,
        badgePositionPercentageOffset: 0.5,
      ),
    ];
  }

  Widget _buildBadge(String label, String percentage, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.surface : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDarkMode ? 76 : 51),
            blurRadius: 6,
            spreadRadius: 1,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withAlpha(204),
            ),
          ),
          Text(
            '$percentage%',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
