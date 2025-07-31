import 'package:diary/components/mood_chart/calendar_card.dart';
import 'package:diary/components/mood_chart/calendar_legend.dart';
import 'package:diary/components/mood_chart/entry_details_bottom_sheet.dart';
import 'package:diary/components/mood_chart/streak_header.dart';
import 'package:diary/services/streak_calendar_provider.dart';
import 'package:flutter/material.dart';
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
                StreakHeader(
                  currentStreak: currentStreak,
                  longestStreak: longestStreak,
                  isRefreshing: _isRefreshing,
                  onRefresh: _refreshCalendarData,
                ),
                const SizedBox(height: 24),

                // Show loading indicator during refresh
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CalendarCard(
                      datasets: datasets,
                      onDateTap: (value) => _showEntryDetailsBottomSheet(
                          context, value, datasets),
                    ),

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
                const CalendarLegend(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEntryDetailsBottomSheet(
      BuildContext context, DateTime date, Map<DateTime, int> datasets) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final entries = datasets[normalizedDate] ?? 0;

    // Fetch stress/non-stress breakdown
    _getEntryBreakdown(normalizedDate).then((breakdown) {
      // Bottom sheet might have been dismissed if the operation takes time
      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withAlpha(127),
        isScrollControlled: false,
        builder: (context) {
          return EntryDetailsBottomSheet(
            date: date,
            entries: entries,
            breakdown: breakdown,
          );
        },
      );
    });
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
        'no stress': 0,
      };

      for (var doc in entries.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final mood = (data['mood'] as String? ?? '').toLowerCase();

        // Handle both old and new mood formats
        if (mood.contains('stress') && !mood.contains('no stress')) {
          breakdown['stress'] = (breakdown['stress'] ?? 0) + 1;
        } else {
          breakdown['no stress'] = (breakdown['no stress'] ?? 0) + 1;
        }
      }

      return breakdown;
    } catch (e) {
      debugPrint('Error getting entry breakdown: $e');
      return {'stress': 0, 'non-stress': 0};
    }
  }
}
