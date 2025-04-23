import 'dart:ui';

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

class _DiaryStreakCalendarState extends State<DiaryStreakCalendar>
    with SingleTickerProviderStateMixin {
  final DiaryService _diaryService = DiaryService();
  Map<DateTime, int> datasets = {};
  int currentStreak = 0;
  int longestStreak = 0;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final heatmapData = await _diaryService.getEntriesForHeatmap();
      final streakInfo = await _diaryService.getStreakInfo();

      if (mounted) {
        setState(() {
          datasets = heatmapData;
          currentStreak = streakInfo['current'] ?? 0;
          longestStreak = streakInfo['longest'] ?? 0;
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDarkMode),
            const SizedBox(height: 24),
            _buildCalendarCard(isDarkMode),
            const SizedBox(height: 16),
            _buildColorLegend(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Writing Streak',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.grey[800],
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Your daily writing journey',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.green[900]!.withOpacity(0.3)
                : Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: isDarkMode ? Colors.green[400] : Colors.green[700],
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850]!.withOpacity(0.7) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -3,
          ),
        ],
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
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
              defaultColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              textColor: isDarkMode ? Colors.grey[300]! : Colors.grey[800]!,
              showColorTip: false,
              showText: true,
              scrollable: true,
              size: 30,
              colorsets: isDarkMode
                  ? {
                      1: const Color(0xFF184E24)
                          .withOpacity(0.8), // Darker green for dark mode
                      2: const Color(0xFF236C32).withOpacity(0.8),
                      3: const Color(0xFF2EA043).withOpacity(0.8),
                      4: const Color(0xFF39D353).withOpacity(0.8),
                      5: const Color(0xFF56F07B).withOpacity(0.8),
                    }
                  : {
                      1: const Color(0xFFADF5BD)
                          .withOpacity(0.8), // GitHub-like greens
                      2: const Color(0xFF7EE787).withOpacity(0.8),
                      3: const Color(0xFF4AC26B).withOpacity(0.8),
                      4: const Color(0xFF2EA043).withOpacity(0.8),
                      5: const Color(0xFF216E39).withOpacity(0.8),
                    },
              onClick: (value) => _showEntryDetailsBottomSheet(context, value),
              margin: const EdgeInsets.symmetric(vertical: 3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorLegend(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(
          5,
          (index) => Container(
            width: 16,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? [
                      const Color(0xFF184E24),
                      const Color(0xFF236C32),
                      const Color(0xFF2EA043),
                      const Color(0xFF39D353),
                      const Color(0xFF56F07B),
                    ][index]
                  : [
                      const Color(0xFFADF5BD),
                      const Color(0xFF7EE787),
                      const Color(0xFF4AC26B),
                      const Color(0xFF2EA043),
                      const Color(0xFF216E39),
                    ][index],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'More',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  void _showEntryDetailsBottomSheet(BuildContext context, DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final entries = datasets[normalizedDate] ?? 0;
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: false,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Date header and entry count
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: entries > 0
                                ? (isDarkMode
                                    ? Colors.green[900]!.withOpacity(0.3)
                                    : Colors.green[50])
                                : (isDarkMode
                                    ? Colors.grey[800]!.withOpacity(0.5)
                                    : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            entries > 0
                                ? Icons.edit_note_rounded
                                : Icons.notes_rounded,
                            color: entries > 0
                                ? (isDarkMode
                                    ? Colors.green[400]
                                    : Colors.green[700])
                                : (isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            entries > 0
                                ? '$entries ${entries == 1 ? 'entry' : 'entries'} on this day'
                                : 'No entries on this day',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
