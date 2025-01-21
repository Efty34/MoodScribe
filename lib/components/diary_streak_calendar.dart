import 'package:diary/services/diary_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DiaryStreakCalendar extends StatefulWidget {
  const DiaryStreakCalendar({super.key});

  @override
  State<DiaryStreakCalendar> createState() => _DiaryStreakCalendarState();
}

class _DiaryStreakCalendarState extends State<DiaryStreakCalendar> {
  final DiaryService _diaryService = DiaryService();
  Map<DateTime, int> datasets = {};
  int currentStreak = 0;
  int longestStreak = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get heatmap data
      final heatmapData = await _diaryService.getEntriesForHeatmap();

      // Get streak information
      final streakInfo = await _diaryService.getStreakInfo();

      setState(() {
        datasets = heatmapData;
        currentStreak = streakInfo['current'] ?? 0;
        longestStreak = streakInfo['longest'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Writing Streak',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     _buildStreakCard(
          //       'Current Streak',
          //       '$currentStreak days',
          //       Icons.local_fire_department_rounded,
          //       Colors.orange,
          //     ),
          //     _buildStreakCard(
          //       'Longest Streak',
          //       '$longestStreak days',
          //       Icons.emoji_events_rounded,
          //       Colors.amber,
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 24),
          HeatMap(
            datasets: datasets,
            colorMode: ColorMode.color,
            defaultColor: Colors.grey[200],
            textColor: Colors.grey[800]!,
            showColorTip: false,
            showText: true,
            scrollable: true,
            size: 30,
            colorsets: {
              1: Colors.green[200]!, // Light contribution
              2: Colors.green[300]!, // Medium contribution
              3: Colors.green[400]!, // High contribution
              4: Colors.green[500]!, // Very high contribution
              5: Colors.green[700]!, // Exceptional contribution
            },
            onClick: (value) {
              final normalizedDate = DateTime(
                value.year,
                value.month,
                value.day,
              );
              final entries = datasets[normalizedDate] ?? 0;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    entries > 0
                        ? '$entries ${entries == 1 ? 'entry' : 'entries'} on ${DateFormat('MMM dd, yyyy').format(value)}'
                        : 'No entries on ${DateFormat('MMM dd, yyyy').format(value)}',
                    style: GoogleFonts.poppins(),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                return Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[(index + 2) * 100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                'More',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
