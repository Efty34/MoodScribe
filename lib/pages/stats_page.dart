import 'package:diary/components/diary_streak_calendar.dart';
import 'package:diary/services/streak_calendar_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Manual refresh function for the entire page
  Future<void> _refreshAllStats() async {
    setState(() {
      _isRefreshing = true;
    });

    // Refresh streak calendar data
    final calendarProvider =
        Provider.of<StreakCalendarProvider>(context, listen: false);
    await calendarProvider.refreshData();

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        // actions: [
        //   // Add refresh button to app bar
        //   IconButton(
        //     icon: _isRefreshing
        //         ? SizedBox(
        //             width: 20,
        //             height: 20,
        //             child: CircularProgressIndicator(
        //               strokeWidth: 2,
        //               color: theme.colorScheme.primary,
        //             ),
        //           )
        //         : Icon(
        //             Icons.refresh_rounded,
        //             color: theme.colorScheme.primary.withAlpha(204),
        //           ),
        //     onPressed: _isRefreshing ? null : _refreshAllStats,
        //     tooltip: 'Refresh all stats',
        //   ),
        // ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAllStats,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Text(
                    'Your Writing Activity',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                // Description Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Track your journaling habits and maintain your writing streak. Click on any day to see mood details.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withAlpha(178),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Streak Calendar
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const DiaryStreakCalendar(),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
