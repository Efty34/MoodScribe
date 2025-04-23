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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = MoodChartUtils.getCardColor(isDarkMode);
    final borderColor = MoodChartUtils.getBorderColor(isDarkMode);
    final total = widget.stressValue + widget.nonStressValue;

    // Get available width to make chart responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final chartSize = screenWidth > 400 ? 260.0 : screenWidth * 0.65;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
        ],
        border: Border.all(
          color: borderColor,
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
                            sections:
                                _buildPieChartSections(isDarkMode, chartSize),
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
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$total',
                            style: MoodChartUtils.getNumberStyle(isDarkMode),
                          ),
                          Text(
                            'Entries',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
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
      bool isDarkMode, double chartSize) {
    final total = widget.stressValue + widget.nonStressValue;
    final stressPercentage =
        MoodChartUtils.calculatePercentage(widget.stressValue, total);
    final nonStressPercentage =
        MoodChartUtils.calculatePercentage(widget.nonStressValue, total);

    // Get colors from utilities
    final positiveColor = MoodChartUtils.getPositiveColor(isDarkMode);
    final stressedColor = MoodChartUtils.getStressedColor(isDarkMode);

    // Calculate radius based on chart size
    final baseRadius = chartSize * 0.32;
    final expandedRadius = chartSize * 0.35;

    return [
      PieChartSectionData(
        color: stressedColor.withOpacity(0.9),
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
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
            ),
          ],
        ),
        badgeWidget: touchedIndex == 0
            ? _buildBadge(stressPercentage.toStringAsFixed(1))
            : null,
        badgePositionPercentageOffset: 0.5,
      ),
      PieChartSectionData(
        color: positiveColor.withOpacity(0.9),
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
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
            ),
          ],
        ),
        badgeWidget: touchedIndex == 1
            ? _buildBadge(nonStressPercentage.toStringAsFixed(1))
            : null,
        badgePositionPercentageOffset: 0.5,
      ),
    ];
  }

  Widget _buildBadge(String percentage) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 1,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        '$percentage%',
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}
