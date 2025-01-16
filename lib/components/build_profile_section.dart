import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BuildProfileSection extends StatefulWidget {
  const BuildProfileSection({super.key});

  @override
  State<BuildProfileSection> createState() => _BuildProfileSectionState();
}

class _BuildProfileSectionState extends State<BuildProfileSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  Map<String, int> _calculateStats(Box<String> box) {
    if (box.isEmpty) return {'entries': 0, 'current': 0, 'longest': 0};

    // Get all entries and sort them by timestamp
    final entries = List.generate(box.length, (index) {
      final key = box.keyAt(index);
      return int.tryParse(key.toString()) ?? 0;
    });

    entries.sort();

    // Convert timestamps to dates
    final dates = entries.map((timestamp) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime(date.year, date.month, date.day);
    }).toList();

    int tempStreak = 1;
    int maxStreak = 1;
    int currentStreak = 1;
    DateTime? lastDate;

    for (var date in dates) {
      if (lastDate != null) {
        final difference = date.difference(lastDate).inDays;
        if (difference == 1) {
          tempStreak++;
          maxStreak = tempStreak > maxStreak ? tempStreak : maxStreak;
        } else if (difference > 1) {
          tempStreak = 1;
        }
      }
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

    return {
      'entries': box.length,
      'current': currentStreak,
      'longest': maxStreak,
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<String>('diaryBox').listenable(),
      builder: (context, Box<String> box, _) {
        final stats = _calculateStats(box);
        
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(12),
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
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: const AssetImage(AppMedia.dp),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Doe',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'john.doe@gmail.com',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Entries', stats['entries'].toString()),
                      _buildDivider(),
                      _buildStatItem('Current Streak', '${stats['current']} days'),
                      _buildDivider(),
                      _buildStatItem('Longest Streak', '${stats['longest']} days'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.blue[700],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
