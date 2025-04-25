import 'package:diary/services/stress_chart_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StressBarChart extends StatefulWidget {
  final int days;

  const StressBarChart({
    super.key,
    this.days = 90, // Default to show a month of data
  });

  @override
  State<StressBarChart> createState() => _StressBarChartState();
}

class _StressBarChartState extends State<StressBarChart>
    with SingleTickerProviderStateMixin {
  bool _isRefreshing = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Initialize stress chart data via provider if not already loaded
    // and setup real-time listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StressChartProvider>(context, listen: false);
      if (!provider.isFreshDataAvailable(widget.days)) {
        provider.fetchStressData(widget.days);
      }

      // Scroll to the end of the chart after rendering
      _scrollToEnd();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Manual refresh function
  Future<void> _refreshChartData() async {
    setState(() {
      _isRefreshing = true;
    });

    final provider = Provider.of<StressChartProvider>(context, listen: false);
    await provider.refreshData(widget.days);

    setState(() {
      _isRefreshing = false;
    });

    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StressChartProvider>(
      builder: (context, chartProvider, _) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;

        // Show loading state
        if (chartProvider.isLoading(widget.days) &&
            !chartProvider.hasData(widget.days)) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          );
        }

        // Show error state
        if (chartProvider.getError(widget.days) != null) {
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
                    chartProvider.getError(widget.days)!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshChartData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Use cached data from provider
        final chartData = chartProvider.getChartData(widget.days);
        final stressData = chartData?.stressData ?? {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood Patterns',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Compare stress vs non-stress',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                    onPressed: _isRefreshing ? null : _refreshChartData,
                    tooltip: 'Refresh chart',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 24.0),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, _) {
                          // Calculate width based on number of days (minimum 600)
                          final chartWidth =
                              max(stressData.length * 60.0, 600.0);

                          return SizedBox(
                            width: chartWidth,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _calculateMaxY(stressData),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipPadding: const EdgeInsets.all(8),
                                    tooltipMargin: 8,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      final dayKey =
                                          stressData.keys.elementAt(groupIndex);
                                      String entryType = rodIndex == 0
                                          ? 'Stress'
                                          : 'Non-Stress';
                                      int count = rod.toY.toInt();
                                      return BarTooltipItem(
                                        '$entryType: $count entries',
                                        GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >=
                                            stressData.length) {
                                          return const SizedBox.shrink();
                                        }

                                        final dayKey = stressData.keys
                                            .elementAt(value.toInt());
                                        final parts = dayKey.split('-');
                                        if (parts.length == 2) {
                                          // Create a more readable date format
                                          final month =
                                              int.tryParse(parts[0]) ?? 1;
                                          final day =
                                              int.tryParse(parts[1]) ?? 1;
                                          final date = DateTime(
                                              DateTime.now().year, month, day);
                                          final dateStr =
                                              DateFormat('MM/dd').format(date);

                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              dateStr,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          );
                                        }

                                        return Text(
                                          dayKey,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                        );
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            value.toInt().toString(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  horizontalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color:
                                          theme.dividerColor.withOpacity(0.2),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                barGroups: stressData.entries.map((entry) {
                                  final int index = stressData.keys
                                      .toList()
                                      .indexOf(entry.key);
                                  final stressCount =
                                      entry.value['stress'] ?? 0;
                                  final nonStressCount =
                                      entry.value['non-stress'] ?? 0;

                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: stressCount * _animation.value,
                                        color: Colors.red.withOpacity(0.7),
                                        width: 12,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                      ),
                                      BarChartRodData(
                                        toY: nonStressCount * _animation.value,
                                        color: Colors.green.withOpacity(0.7),
                                        width: 12,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Show a subtle loading indicator when refreshing
                  if (chartProvider.isLoading(widget.days) &&
                      chartProvider.hasData(widget.days))
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.red.withOpacity(0.7), 'Stress'),
                  const SizedBox(width: 24),
                  _buildLegendItem(Colors.green.withOpacity(0.7), 'Non-Stress'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Help text for scrolling
            Center(
              child: Text(
                'Swipe left/right to view more data',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  double _calculateMaxY(Map<String, Map<String, int>> stressData) {
    int maxValue = 0;
    for (var entry in stressData.entries) {
      final stressCount = entry.value['stress'] ?? 0;
      final nonStressCount = entry.value['non-stress'] ?? 0;
      final maxForDay =
          stressCount > nonStressCount ? stressCount : nonStressCount;
      if (maxForDay > maxValue) {
        maxValue = maxForDay;
      }
    }
    // Add a little padding to the top
    return (maxValue + 1).toDouble();
  }

  double max(double a, double b) {
    return a > b ? a : b;
  }
}
