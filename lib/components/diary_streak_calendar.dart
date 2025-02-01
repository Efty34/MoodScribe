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
      final heatmapData = await _diaryService.getEntriesForHeatmap();
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
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

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
                    'Writing Streak',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Your daily writing journey',
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
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.green[700],
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: HeatMap(
              datasets: datasets,
              colorMode: ColorMode.color,
              defaultColor: Colors.grey[200],
              textColor: Colors.grey[800]!,
              showColorTip: false,
              showText: true,
              scrollable: true,
              size: 30,
              colorsets: {
                1: Colors.green[200]!.withOpacity(0.7),
                2: Colors.green[300]!.withOpacity(0.7),
                3: Colors.green[400]!.withOpacity(0.7),
                4: Colors.green[500]!.withOpacity(0.7),
                5: Colors.green[700]!.withOpacity(0.7),
              },
              onClick: (value) => _showEntryDetails(context, value),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[100]!, Colors.green[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(
                5,
                (index) => Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[(index + 2) * 100]!.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'More',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildStreakInfo(String label, int value, IconData icon, Color color) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [
  //             BoxShadow(
  //               color: color.withOpacity(0.2),
  //               blurRadius: 8,
  //               offset: const Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: Icon(icon, color: color, size: 24),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         '$value days',
  //         style: GoogleFonts.poppins(
  //           fontSize: 16,
  //           fontWeight: FontWeight.w600,
  //           color: Colors.grey[800],
  //         ),
  //       ),
  //       Text(
  //         label,
  //         style: GoogleFonts.poppins(
  //           fontSize: 12,
  //           color: Colors.grey[600],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _showEntryDetails(BuildContext context, DateTime value) {
    final normalizedDate = DateTime(value.year, value.month, value.day);
    final entries = datasets[normalizedDate] ?? 0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              entries > 0 ? Icons.edit_note_rounded : Icons.notes_rounded,
              color: entries > 0 ? Colors.green[300] : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Text(
              entries > 0
                  ? '$entries ${entries == 1 ? 'entry' : 'entries'} on ${DateFormat('MMM dd, yyyy').format(value)}'
                  : 'No entries on ${DateFormat('MMM dd, yyyy').format(value)}',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 2,
      ),
    );
  }
}
