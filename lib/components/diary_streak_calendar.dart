import 'dart:ui';

import 'package:diary/services/streak_calendar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DiaryStreakCalendar extends StatefulWidget {
  const DiaryStreakCalendar({super.key});

  @override
  State<DiaryStreakCalendar> createState() => _DiaryStreakCalendarState();
}

class _DiaryStreakCalendarState extends State<DiaryStreakCalendar>
    with SingleTickerProviderStateMixin {
  bool _isRefreshing = false;
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

    _animationController.forward();

    // Initialize streak data via provider if not already loaded
    // and setup real-time listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<StreakCalendarProvider>(context, listen: false);
      provider.fetchCalendarData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Manual refresh function
  Future<void> _refreshCalendarData() async {
    setState(() {
      _isRefreshing = true;
    });

    final provider =
        Provider.of<StreakCalendarProvider>(context, listen: false);
    await provider.refreshData();

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StreakCalendarProvider>(
      builder: (context, calendarProvider, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        // Show loading state
        if (calendarProvider.isLoading && !calendarProvider.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          );
        }

        // Show error state
        if (calendarProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    calendarProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshCalendarData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Use cached data from provider
        final calendarData = calendarProvider.calendarData;
        final datasets = calendarData?.datasets ?? {};
        final currentStreak = calendarData?.currentStreak ?? 0;
        final longestStreak = calendarData?.longestStreak ?? 0;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme, isDark, currentStreak, longestStreak,
                    calendarProvider.isLoading),
                const SizedBox(height: 24),

                // Show loading indicator during refresh
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildCalendarCard(theme, isDark, datasets),

                    // Show a subtle loading indicator when refreshing
                    if (calendarProvider.isLoading && calendarProvider.hasData)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),
                _buildColorLegend(theme, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, int currentStreak,
      int longestStreak, bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.primary.withOpacity(0.15)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$currentStreak days',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Best: $longestStreak days',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: theme.hintColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),

        // Refresh button
        IconButton(
          icon: _isRefreshing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Icon(
                  Icons.refresh_rounded,
                  color: theme.colorScheme.primary.withOpacity(0.8),
                ),
          onPressed: _isRefreshing ? null : _refreshCalendarData,
          tooltip: 'Refresh calendar',
        ),
      ],
    );
  }

  Widget _buildCalendarCard(
      ThemeData theme, bool isDark, Map<DateTime, int> datasets) {
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
              onClick: (value) =>
                  _showEntryDetailsBottomSheet(context, value, datasets),
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

  void _showEntryDetailsBottomSheet(
      BuildContext context, DateTime date, Map<DateTime, int> datasets) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final entries = datasets[normalizedDate] ?? 0;
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fetch stress/non-stress breakdown
    _getEntryBreakdown(normalizedDate).then((breakdown) {
      // Bottom sheet might have been dismissed if the operation takes time
      if (!context.mounted) return;

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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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
                                      ? theme.colorScheme.primary
                                          .withOpacity(0.2)
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

                // Entry breakdown by mood (Stress/Non-Stress)
                if (entries > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          'Entry Breakdown',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Stress entries
                        _buildMoodSummaryRow(
                          context: context,
                          icon: Icons.mood_bad,
                          iconColor: Color(0xFFE53935),
                          label: 'Stress',
                          count: breakdown['stress'] ?? 0,
                          total: entries,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 12),

                        // Non-stress entries
                        _buildMoodSummaryRow(
                          context: context,
                          icon: Icons.mood,
                          iconColor: Color(0xFF43A047),
                          label: 'Non-Stress',
                          count: breakdown['non-stress'] ?? 0,
                          total: entries,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }

  // Helper to build each mood summary row
  Widget _buildMoodSummaryRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required int count,
    required int total,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (count / total) * 100 : 0;

    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Label and count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$count ${count == 1 ? 'entry' : 'entries'} (${percentage.toStringAsFixed(0)}%)',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total > 0 ? count / total : 0,
                  backgroundColor: iconColor.withOpacity(0.1),
                  color: iconColor.withOpacity(isDark ? 0.8 : 0.7),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fetch stress/non-stress entry breakdown for a specific date
  Future<Map<String, int>> _getEntryBreakdown(DateTime date) async {
    // Reuse existing DiaryService functionality
    final diaryService =
        Provider.of<StreakCalendarProvider>(context, listen: false)
            .getDiaryService();

    try {
      // Prepare date range for the whole day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay =
          DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      // Get entries for this date
      final entries = await diaryService.getDiaryEntriesByDateRangeOnce(
          startOfDay, endOfDay);

      // Count by mood
      final Map<String, int> breakdown = {
        'stress': 0,
        'non-stress': 0,
      };

      for (var doc in entries.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final mood = data['mood'] as String? ?? '';

        if (mood == 'stress') {
          breakdown['stress'] = (breakdown['stress'] ?? 0) + 1;
        } else {
          breakdown['non-stress'] = (breakdown['non-stress'] ?? 0) + 1;
        }
      }

      return breakdown;
    } catch (e) {
      debugPrint('Error getting entry breakdown: $e');
      return {'stress': 0, 'non-stress': 0};
    }
  }
}
