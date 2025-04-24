import 'package:diary/services/diary_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
  final DiaryService _diaryService = DiaryService();
  Map<String, Map<String, int>> _stressData = {};
  bool _isLoading = true;
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

    _fetchStressData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchStressData() async {
    try {
      final data = await _diaryService.getStressDataByDay(widget.days);
      setState(() {
        _stressData = data;
        _isLoading = false;
      });
      _animationController.forward();

      // Scroll to the end of the chart after rendering
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Error fetching stress data: $e');
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Mood Patterns',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Compare your stress and non-stress days across time',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 24.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  // Calculate width based on number of days (minimum 600)
                  final chartWidth = max(_stressData.length * 60.0, 600.0);

                  return SizedBox(
                    width: chartWidth,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _calculateMaxY(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final dayKey =
                                  _stressData.keys.elementAt(groupIndex);
                              String entryType =
                                  rodIndex == 0 ? 'Stress' : 'Non-Stress';
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
                                if (value.toInt() >= _stressData.length) {
                                  return const SizedBox.shrink();
                                }

                                final dayKey =
                                    _stressData.keys.elementAt(value.toInt());
                                final parts = dayKey.split('-');
                                if (parts.length == 2) {
                                  // Create a more readable date format
                                  final month = int.tryParse(parts[0]) ?? 1;
                                  final day = int.tryParse(parts[1]) ?? 1;
                                  final date =
                                      DateTime(DateTime.now().year, month, day);
                                  final dateStr =
                                      DateFormat('MM/dd').format(date);

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      dateStr,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface
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
                                if (value == 0) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
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
                              color: theme.dividerColor.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        barGroups: _stressData.entries.map((entry) {
                          final int index =
                              _stressData.keys.toList().indexOf(entry.key);
                          final stressCount = entry.value['stress'] ?? 0;
                          final nonStressCount = entry.value['non-stress'] ?? 0;

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

  double _calculateMaxY() {
    int maxValue = 0;
    for (var entry in _stressData.entries) {
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
