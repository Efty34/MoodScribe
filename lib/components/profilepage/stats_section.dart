import 'package:diary/components/mood_chart.dart';
import 'package:diary/components/profilepage/chart_container.dart';
import 'package:diary/services/mood_chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StatsSection extends StatefulWidget {
  const StatsSection({super.key});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  bool _isRefreshing = false;

  Future<void> _refreshMoodData() async {
    setState(() {
      _isRefreshing = true;
    });

    final provider = Provider.of<MoodChartProvider>(context, listen: false);
    await provider.refreshData();

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Text(
                'Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),

              // Add refresh button
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
                        color: theme.colorScheme.primary.withAlpha(204),
                      ),
                onPressed: _isRefreshing ? null : _refreshMoodData,
                tooltip: 'Refresh stats',
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Charts Section - Now with only MoodChart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: ChartContainer(
            shadowColor: isDark ? Colors.blueGrey : Colors.blue,
            child: const MoodChart(),
          ),
        ),
      ],
    );
  }
}
