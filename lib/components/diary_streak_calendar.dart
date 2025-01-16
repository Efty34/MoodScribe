import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class DiaryStreakCalendar extends StatefulWidget {
  const DiaryStreakCalendar({super.key});

  @override
  State<DiaryStreakCalendar> createState() => _DiaryStreakCalendarState();
}

class _DiaryStreakCalendarState extends State<DiaryStreakCalendar> {
  Map<DateTime, int> datasets = {};
  int currentStreak = 0;
  int longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _migrateExistingEntries();
    _printBoxContents();
    _loadDiaryEntries();
  }

  void _loadDiaryEntries() {
    final diaryBox = Hive.box<String>('diaryBox');
    final Map<DateTime, int> heatmapData = {};

    debugPrint('Total entries in box: ${diaryBox.length}');

    // Process diary entries
    for (var i = 0; i < diaryBox.length; i++) {
      try {
        final entry = diaryBox.getAt(i);
        if (entry == null) continue;

        final key = diaryBox.keyAt(i);
        debugPrint(
            'Processing entry $i: Key type: ${key.runtimeType}, Key: $key');

        DateTime? entryDate;

        if (key is String) {
          // Try parsing the key as a timestamp
          final timestamp = int.tryParse(key);
          if (timestamp != null) {
            entryDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          }
        }

        if (entryDate != null) {
          // Normalize the date to remove time component
          final date = DateTime(entryDate.year, entryDate.month, entryDate.day);
          debugPrint('Found entry for date: $date');

          // Increment the count for this date
          heatmapData[date] = (heatmapData[date] ?? 0) + 1;
        }
      } catch (e, stackTrace) {
        debugPrint('Error processing diary entry: $e');
        debugPrint('Stack trace: $stackTrace');
        continue;
      }
    }

    // Calculate streaks
    _calculateStreaks(heatmapData.keys.toList());

    setState(() {
      datasets = heatmapData;
    });

    // Debug print
    debugPrint('Loaded entries: ${heatmapData.length}');
    heatmapData.forEach((date, count) {
      debugPrint('Date: $date, Count: $count');
    });
  }

  void _calculateStreaks(List<DateTime> dates) {
    dates.sort();
    int tempStreak = 0;
    int maxStreak = 0;
    DateTime? lastDate;

    for (var date in dates) {
      if (lastDate == null) {
        tempStreak = 1;
      } else {
        final difference = date.difference(lastDate).inDays;
        if (difference == 1) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
      }
      maxStreak = tempStreak > maxStreak ? tempStreak : maxStreak;
      lastDate = date;
    }

    // Calculate current streak
    if (dates.isNotEmpty) {
      final today = DateTime.now();
      final lastEntryDate = dates.last;
      final difference = today.difference(lastEntryDate).inDays;

      if (difference <= 1) {
        currentStreak = tempStreak;
      } else {
        currentStreak = 0;
      }
    }

    setState(() {
      longestStreak = maxStreak;
    });
  }

  // Add this method to help with debugging
  void _printBoxContents() {
    final diaryBox = Hive.box<String>('diaryBox');
    debugPrint('\n=== Diary Box Contents ===');
    debugPrint('Total entries: ${diaryBox.length}');

    for (var i = 0; i < diaryBox.length; i++) {
      final key = diaryBox.keyAt(i);
      final value = diaryBox.getAt(i);
      debugPrint('Entry $i:');
      debugPrint('  Key type: ${key.runtimeType}');
      debugPrint('  Key: $key');
      debugPrint('  Value type: ${value.runtimeType}');
      debugPrint('  Value: $value');
      debugPrint('---');
    }
  }

  void _migrateExistingEntries() {
    final diaryBox = Hive.box<String>('diaryBox');

    // Temporary storage for entries
    final entries = <String>[];
    final keys = <dynamic>[];

    // Collect all entries and their keys
    for (var i = 0; i < diaryBox.length; i++) {
      final entry = diaryBox.getAt(i);
      if (entry != null) {
        entries.add(entry);
        keys.add(diaryBox.keyAt(i));
      }
    }

    // Delete all entries that don't have timestamp keys
    for (var key in keys) {
      if (key is String) {
        if (int.tryParse(key) == null) {
          diaryBox.delete(key);
        }
      }
    }

    // Re-add entries with timestamp keys
    for (var i = 0; i < entries.length; i++) {
      if (keys[i] is! String || int.tryParse(keys[i] as String) == null) {
        final now = DateTime.now().subtract(Duration(minutes: i));
        final key = now.millisecondsSinceEpoch.toString();
        diaryBox.put(key, entries[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Writing Streak',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     _buildStreakCard(
          //       'Current Streak',
          //       '$currentStreak days',
          //       Icons.local_fire_department_rounded,
          //       Colors.orange,
          //     ),
          //     _buildStreakCard(
          //       'Longest Streak',
          //       '$longestStreak days',
          //       Icons.emoji_events_rounded,
          //       Colors.amber,
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 24),
          HeatMap(
            datasets: datasets,
            colorMode: ColorMode.color,
            defaultColor: Colors.grey[200],
            textColor: Colors.grey[800]!,
            showColorTip: false,
            showText: true,
            scrollable: true,
            size: 30,
            colorsets: {
              1: Colors.green[200]!, // Light contribution
              2: Colors.green[300]!, // Medium contribution
              3: Colors.green[400]!, // High contribution
              4: Colors.green[500]!, // Very high contribution
              5: Colors.green[700]!, // Exceptional contribution
            },
            onClick: (value) {
              if (value != null) {
                // Normalize the clicked date to match our stored dates
                final normalizedDate = DateTime(
                  value.year,
                  value.month,
                  value.day,
                );
                final entries = datasets[normalizedDate] ?? 0;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      entries > 0
                          ? '$entries ${entries == 1 ? 'entry' : 'entries'} on ${DateFormat('MMM dd, yyyy').format(value)}'
                          : 'No entries on ${DateFormat('MMM dd, yyyy').format(value)}',
                      style: GoogleFonts.poppins(),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                return Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[(index + 2) * 100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                'More',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
