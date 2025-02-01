import 'package:diary/services/diary_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood Analysis',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Your emotional journey',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.pie_chart_rounded,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 31),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 34),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: AspectRatio(
                  aspectRatio: 1.3,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      startDegreeOffset: -90 * _animation.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 31),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(
                    Colors.green[400]!,
                    'Positive',
                    nonStressValue,
                    Icons.sentiment_satisfied_rounded,
                  ),
                  const SizedBox(width: 24),
                  _buildLegendItem(
                    Colors.red[400]!,
                    'Stressed',
                    stressValue,
                    Icons.sentiment_dissatisfied_rounded,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = stressValue + nonStressValue;
    final stressPercentage = total > 0 ? (stressValue / total) * 100 : 0;
    final nonStressPercentage = total > 0 ? (nonStressValue / total) * 100 : 0;

    return [
      PieChartSectionData(
        color: Colors.red[500]!.withOpacity(0.8),
        value: stressPercentage * _animation.value,
        title: '${(stressPercentage * _animation.value).toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green[500]!.withOpacity(0.8),
        value: nonStressPercentage * _animation.value,
        title:
            '${(nonStressPercentage * _animation.value).toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegendItem(Color color, String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$value entries',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
