import 'package:diary/services/diary_service.dart';
import 'package:flutter/material.dart';

import 'mood_chart_card.dart';
import 'mood_chart_header.dart';
import 'mood_chart_legend.dart';

/// Main entry point for the mood chart functionality
class MoodChart extends StatefulWidget {
  const MoodChart({super.key});

  @override
  State<MoodChart> createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart>
    with SingleTickerProviderStateMixin {
  final DiaryService _diaryService = DiaryService();
  int stressValue = 0;
  int nonStressValue = 0;
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _fetchDiaryEntries();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchDiaryEntries() async {
    try {
      // Get diary statistics
      final diaryStats = await _diaryService.getDiaryStatistics();
      final moodCounts = diaryStats['mood_counts'] as Map<String, dynamic>;

      // Count stress vs no stress entries
      final stressCount = moodCounts['stress'] ?? 0;
      final nonStressCount = moodCounts['no stress'] ?? 0;

      // Update state
      setState(() {
        stressValue = stressCount;
        nonStressValue = nonStressCount;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching diary entries: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDarkMode ? Colors.blue[300]! : Colors.blue,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MoodChartHeader(),
              const SizedBox(height: 20),
              MoodChartCard(
                stressValue: stressValue,
                nonStressValue: nonStressValue,
                animation: _animation,
              ),
              const SizedBox(height: 20),
              MoodChartLegend(
                stressValue: stressValue,
                nonStressValue: nonStressValue,
              ),
            ],
          ),
        );
      },
    );
  }
}
