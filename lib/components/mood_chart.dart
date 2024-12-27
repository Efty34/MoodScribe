import 'package:diary/firebase/firebase_options.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoodChart extends StatefulWidget {
  // final String stressAnalysis;
  const MoodChart({super.key});

  @override
  State<MoodChart> createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart> {
  int stressValue = 0;
  int nonStressValue = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDiaryEntries();
  }

  Future<void> _fetchDiaryEntries() async {
    try {
      // Get the stream and fetch the latest snapshot
      final snapshot = await FirebaseOptions.getDiaryEntries().first;

      // Map the documents to a list of entries
      final entries = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Count the occurrences of "Stressed" and "Not Stressed"
      final stressCount =
          entries.where((entry) => entry['prediction'] == 'Stressed').length;
      final nonStressCount = entries
          .where((entry) => entry['prediction'] == 'Not Stressed')
          .length;

      // Update the state with the fetched data
      setState(() {
        stressValue = stressCount;
        nonStressValue = nonStressCount;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching diary entries: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.blue[50],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stress Analysis",
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
    final total = stressValue + nonStressValue;
    final stressPercentage = total > 0 ? (stressValue / total) * 100 : 0;
    final nonStressPercentage = total > 0 ? (nonStressValue / total) * 100 : 0;

    return [
      PieChartSectionData(
        color: Colors.red,
        value: stressPercentage.toDouble(),
        title: '${stressPercentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: nonStressPercentage.toDouble(),
        title: '${nonStressPercentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
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
