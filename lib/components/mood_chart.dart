import 'package:diary/firebase/firebase.dart';
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
      // 1) Get the stream of diary entries
      final snapshots = FirebaseOptions.getDiaryEntries();

      // 2) We only need the latest snapshot once
      //    (If you want real-time updates, consider StreamBuilder)
      final snapshot = await snapshots.first;

      // 3) Convert to a list of maps
      final entries = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // 4) Count "stress" vs "no stress"
      final stressCount =
          entries.where((e) => e['prediction'] == 'stress').length;
      final nonStressCount =
          entries.where((e) => e['prediction'] == 'no stress').length;

      // 5) Update state
      setState(() {
        stressValue = stressCount;
        nonStressValue = nonStressCount;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching diary entries: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mood Analysis",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: Transform.scale(
                        scale: _animation.value,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            startDegreeOffset: -90 * _animation.value,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(
                          const Color(0xFF4CAF50),
                          'Positive',
                          nonStressValue,
                        ),
                        const SizedBox(width: 24),
                        _buildLegendItem(
                          const Color(0xFFE57373),
                          'Stressed',
                          stressValue,
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
        color: const Color(0xFFE57373),
        value: stressPercentage * _animation.value,
        title: '${(stressPercentage * _animation.value).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFF4CAF50),
        value: nonStressPercentage * _animation.value,
        title:
            '${(nonStressPercentage * _animation.value).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegendItem(Color color, String label, int value) {
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
    );
  }
}
