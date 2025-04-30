import 'package:diary/services/mood_chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mood_chart_card.dart';
import 'mood_chart_header.dart';
import 'mood_chart_legend.dart';

/// Main entry point for the mood chart functionality
class MoodChart extends StatefulWidget {
  const MoodChart({super.key});

  @override
  State<MoodChart> createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

    _controller.forward();

    // Initialize with page 0 (which will now be Last 7 Days)
    _currentPage = 0;

    // Initialize mood data via provider if not already loaded
    // and setup real-time listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MoodChartProvider>(context, listen: false);
      provider.fetchMoodData();
      provider.fetchLastWeekMoodData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodChartProvider>(
      builder: (context, moodProvider, _) {
        final theme = Theme.of(context);

        // Both data sources are loading and have no data
        if ((moodProvider.isLoading && !moodProvider.hasData) &&
            (moodProvider.isLoadingLastWeek && !moodProvider.hasLastWeekData)) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          );
        }

        // Show error state if both data sources have errors
        if (moodProvider.error != null && moodProvider.errorLastWeek != null) {
          return Center(
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
                  moodProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => moodProvider.refreshData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Use cached data from provider
        final chartData = moodProvider.chartData;
        final stressValue = chartData?.stressValue ?? 0;
        final nonStressValue = chartData?.nonStressValue ?? 0;

        final lastWeekChartData = moodProvider.lastWeekChartData;
        final lastWeekStressValue = lastWeekChartData?.stressValue ?? 0;
        final lastWeekNonStressValue = lastWeekChartData?.nonStressValue ?? 0;

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MoodChartHeader(),
                  const SizedBox(height: 10),

                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(0),
                      const SizedBox(width: 8),
                      _buildIndicator(1),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Horizontally scrollable charts - Fixed height to prevent overflow
                  SizedBox(
                    height: 260, // Reduced height to prevent overflow
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        // Last 7 days chart - Now showing first
                        _buildChartContainer(
                          title: 'Last 7 Days',
                          subtitle: 'Recent mood trends',
                          stressValue: lastWeekStressValue,
                          nonStressValue: lastWeekNonStressValue,
                          isLoading: moodProvider.isLoadingLastWeek &&
                              moodProvider.hasLastWeekData,
                          error: moodProvider.errorLastWeek,
                          onRetry: () => moodProvider.fetchLastWeekMoodData(
                              forceRefresh: true),
                        ),

                        // Overall mood chart - Now second
                        _buildChartContainer(
                          title: 'Overall Mood',
                          subtitle: 'All-time analysis',
                          stressValue: stressValue,
                          nonStressValue: nonStressValue,
                          isLoading:
                              moodProvider.isLoading && moodProvider.hasData,
                          error: moodProvider.error,
                          onRetry: () =>
                              moodProvider.fetchMoodData(forceRefresh: true),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Display legend for the current chart
                  _currentPage == 0
                      ? MoodChartLegend(
                          stressValue: lastWeekStressValue,
                          nonStressValue: lastWeekNonStressValue,
                        )
                      : MoodChartLegend(
                          stressValue: stressValue,
                          nonStressValue: nonStressValue,
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.withOpacity(0.5),
      ),
    );
  }

  Widget _buildChartContainer({
    required String title,
    required String subtitle,
    required int stressValue,
    required int nonStressValue,
    required bool isLoading,
    required String? error,
    required VoidCallback onRetry,
  }) {
    final theme = Theme.of(context);

    // Show error state
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Use minimum vertical space
          children: [
            Icon(
              Icons.error_outline,
              size: 36,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Use minimum vertical space
      children: [
        // Title for the chart
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum vertical space
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        // Chart - in a constrained container
        Flexible(
          child: Stack(
            alignment: Alignment.center,
            children: [
              MoodChartCard(
                stressValue: stressValue,
                nonStressValue: nonStressValue,
                animation: _animation,
              ),

              // Show a subtle loading indicator when refreshing
              if (isLoading)
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
        ),
      ],
    );
  }
}
