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

    // Initialize mood data via provider if not already loaded
    // and setup real-time listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MoodChartProvider>(context, listen: false);
      provider.fetchMoodData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodChartProvider>(
      builder: (context, moodProvider, _) {
        final theme = Theme.of(context);

        // Show loading state
        if (moodProvider.isLoading && !moodProvider.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          );
        }

        // Show error state
        if (moodProvider.error != null) {
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

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MoodChartHeader(),
                  const SizedBox(height: 20),

                  // Show loading indicator during refresh
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      MoodChartCard(
                        stressValue: stressValue,
                        nonStressValue: nonStressValue,
                        animation: _animation,
                      ),

                      // Show a subtle loading indicator when refreshing
                      if (moodProvider.isLoading && moodProvider.hasData)
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

                  const SizedBox(height: 20),
                  MoodChartLegend(
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
}
