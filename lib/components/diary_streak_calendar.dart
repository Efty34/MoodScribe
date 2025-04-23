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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
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
            _buildHeader(theme, isDark),
            const SizedBox(height: 24),
            _buildCalendarCard(theme, isDark),
            const SizedBox(height: 16),
            _buildColorLegend(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
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
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Your daily writing journey',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: theme.hintColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.primary.withOpacity(0.2)
                : theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(ThemeData theme, bool isDark) {
    // Define green color for both themes
    const Color greenColor = Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withOpacity(0.7)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -3,
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
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: HeatMap(
              datasets: datasets,
              colorMode: ColorMode.color,
              defaultColor: isDark
                  ? theme.dividerColor
                  : theme.colorScheme.surfaceContainerHighest,
              textColor: theme.colorScheme.onSurface,
              showColorTip: false,
              showText: true,
              scrollable: true,
              size: 30,
              colorsets: isDark
                  ? {
                      1: greenColor.withOpacity(0.2),
                      2: greenColor.withOpacity(0.4),
                      3: greenColor.withOpacity(0.6),
                      4: greenColor.withOpacity(0.8),
                      5: greenColor,
                    }
                  : {
                      1: greenColor.withOpacity(0.1),
                      2: greenColor.withOpacity(0.3),
                      3: greenColor.withOpacity(0.5),
                      4: greenColor.withOpacity(0.7),
                      5: greenColor.withOpacity(0.9),
                    },
              onClick: (value) => _showEntryDetailsBottomSheet(context, value),
              margin: const EdgeInsets.symmetric(vertical: 3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorLegend(ThemeData theme, bool isDark) {
    // Use the same green color as used in the calendar
    const Color greenColor = Colors.green;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: theme.hintColor,
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
              color: isDark
                  ? greenColor.withOpacity((index + 1) * 0.2)
                  : greenColor.withOpacity(0.1 + index * 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'More',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: theme.hintColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: false,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : theme.cardColor,
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
                    color: theme.dividerColor,
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
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: entries > 0
                                ? (isDark
                                    ? theme.colorScheme.primary.withOpacity(0.2)
                                    : theme.colorScheme.primary
                                        .withOpacity(0.1))
                                : theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(isDark ? 0.5 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            entries > 0
                                ? Icons.edit_note_rounded
                                : Icons.notes_rounded,
                            color: entries > 0
                                ? theme.colorScheme.primary
                                : theme.hintColor,
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
                              color: theme.colorScheme.onSurface,
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
