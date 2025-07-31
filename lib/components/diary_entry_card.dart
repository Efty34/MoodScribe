import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DiaryEntryCard extends StatelessWidget {
  final String? entryId;
  final Map<String, dynamic>? entryData;
  final bool? isFavorited;
  final Widget? content;
  final String? mood;
  final DateTime? date;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DiaryEntryCard({
    super.key,
    this.content,
    this.mood,
    this.date,
    this.onTap,
    this.onLongPress,
    this.entryId,
    this.entryData,
    this.isFavorited,
  }) : assert(
          (content != null && mood != null && date != null) ||
              (entryData != null),
          'Either provide content, mood, and date OR provide entryData',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Extract values from entryData if provided, otherwise use direct parameters
    final String effectiveMood = mood ?? entryData?['mood'] ?? 'neutral';
    final DateTime effectiveDate = date ??
        (entryData?['date'] is Timestamp
            ? (entryData?['date'] as Timestamp).toDate()
            : DateTime.now());

    Color getMoodColor(String moodValue, bool background) {
      final isStress = moodValue.toLowerCase().contains('stress') &&
          !moodValue.toLowerCase().contains('no stress');

      if (background) {
        return isStress
            ? (isDark ? Colors.red.withOpacity(0.2) : Colors.red[50]!)
            : (isDark ? Colors.green.withOpacity(0.2) : Colors.green[50]!);
      } else {
        return isStress
            ? (isDark ? Colors.red[500]! : Colors.red[700]!)
            : (isDark ? Colors.green[500]! : Colors.green[700]!);
      }
    }

    // Build the content widget if it's not directly provided
    Widget effectiveContent = content ??
        Text(
          entryData?['content'] ?? 'No content',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onBackground,
            fontSize: 14,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        );

    return Card(
      color: isDark ? theme.colorScheme.surface : theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? theme.dividerColor : Colors.grey[200]!,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              effectiveContent,
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getMoodColor(effectiveMood, true),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      effectiveMood,
                      style: TextStyle(
                        color: getMoodColor(effectiveMood, false),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(effectiveDate),
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (isFavorited == true)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red[400],
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
