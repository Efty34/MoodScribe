import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DiaryService {
  final CollectionReference _diaryCollection =
      FirebaseFirestore.instance.collection('diary_entries');

  // Create diary entry
  Future<void> addEntry(String text) async {
    try {
      await _diaryCollection.add({
        'text': text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add diary entry: $e');
    }
  }

  // Read diary entries
  Stream<QuerySnapshot> getEntries() {
    return _diaryCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // Get single entry
  Future<DocumentSnapshot> getEntry(String id) {
    return _diaryCollection.doc(id).get();
  }

  // Update diary entry
  Future<void> updateEntry(String id, String text) async {
    try {
      await _diaryCollection.doc(id).update({
        'text': text,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update diary entry: $e');
    }
  }

  // Delete diary entry
  Future<void> deleteEntry(String id) async {
    try {
      await _diaryCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete diary entry: $e');
    }
  }

  // Get entries for heatmap
  Future<Map<DateTime, int>> getEntriesForHeatmap() async {
    try {
      final QuerySnapshot snapshot = await _diaryCollection.get();
      final Map<DateTime, int> heatmapData = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] as int;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final normalizedDate = DateTime(date.year, date.month, date.day);

        heatmapData[normalizedDate] = (heatmapData[normalizedDate] ?? 0) + 1;
      }

      return heatmapData;
    } catch (e) {
      throw Exception('Failed to get entries for heatmap: $e');
    }
  }

  // Get streak information
  Future<Map<String, int>> getStreakInfo() async {
    try {
      final QuerySnapshot snapshot = 
          await _diaryCollection.orderBy('timestamp', descending: true).get();

      if (snapshot.docs.isEmpty) {
        return {'current': 0, 'longest': 0, 'total': 0};
      }

      final List<DateTime> dates = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] as int;
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }).toList();

      // Sort dates in ascending order
      dates.sort();

      int currentStreak = 0;
      int longestStreak = 0;
      int tempStreak = 0;

      // Get today's date without time
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      // Check if there's an entry today
      final hasEntryToday = dates.any((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);

      DateTime? previousDate;
      for (var date in dates) {
        // Normalize date to remove time component
        final normalizedDate = DateTime(date.year, date.month, date.day);
        
        if (previousDate == null) {
          tempStreak = 1;
        } else {
          final difference = normalizedDate.difference(previousDate).inDays;
          if (difference == 1) {
            tempStreak++;
          } else if (difference > 1) {
            // Break in streak
            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }
            tempStreak = 1;
          }
        }
        previousDate = normalizedDate;
      }

      // Update longest streak if the current temp streak is longer
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }

      // Calculate current streak
      if (hasEntryToday) {
        currentStreak = tempStreak;
      } else {
        // Check if the last entry was yesterday
        final lastEntryDate = dates.last;
        final normalizedLastEntry = DateTime(
          lastEntryDate.year,
          lastEntryDate.month,
          lastEntryDate.day,
        );
        
        if (today.difference(normalizedLastEntry).inDays == 1) {
          currentStreak = tempStreak;
        } else {
          currentStreak = 0;
        }
      }

      return {
        'current': currentStreak,
        'longest': longestStreak,
        'total': snapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error calculating streaks: $e');
      return {'current': 0, 'longest': 0, 'total': 0};
    }
  }
}
