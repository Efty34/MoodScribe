import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoodChart extends StatelessWidget {
  final String stressAnalysis;
  const MoodChart({super.key, required this.stressAnalysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stressAnalysis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  sectionsSpace: 2, // Space between sections
                  centerSpaceRadius: 40, // Empty center space
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.red, 'Stress'),
                _buildLegendItem(Colors.green, 'Non-Stress'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    // Replace these values with actual data
    final stressValue = 30; // Stress percentage
    final nonStressValue = 70; // Non-stress percentage

    return [
      PieChartSectionData(
        color: Colors.red,
        value: stressValue.toDouble(),
        title: '$stressValue%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: nonStressValue.toDouble(),
        title: '$nonStressValue%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
