import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = AuthService().currentUser?.uid;

  // Add new diary entry
  Future<void> addDiaryEntry({
    required String content,
    required String mood,
    required DateTime date,
  }) async {
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).collection('diary').add({
      'content': content,
      'mood': mood,
      'date': date,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Get all diary entries for current user
  Stream<QuerySnapshot> getDiaryEntries() {
    if (userId == null) return Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get single diary entry
  Future<DocumentSnapshot?> getDiaryEntry(String entryId) async {
    if (userId == null) return null;

    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .doc(entryId)
        .get();
  }

  // Update diary entry
  Future<void> updateDiaryEntry({
    required String entryId,
    required String content,
    required String mood,
    required DateTime date,
  }) async {
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .doc(entryId)
        .update({
      'content': content,
      'mood': mood,
      'date': date,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Delete diary entry
  Future<void> deleteDiaryEntry(String entryId) async {
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .doc(entryId)
        .delete();
  }

  // Get diary entries by date range
  Stream<QuerySnapshot> getDiaryEntriesByDateRange(
      DateTime startDate, DateTime endDate) {
    if (userId == null) return Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get diary entries by date range as a Future (one-time fetch)
  Future<QuerySnapshot> getDiaryEntriesByDateRangeOnce(
      DateTime startDate, DateTime endDate) async {
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date', descending: true)
        .get();
  }

  // Get diary entries by mood
  Stream<QuerySnapshot> getDiaryEntriesByMood(String mood) {
    if (userId == null) return Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .where('mood', isEqualTo: mood)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get diary statistics
  Future<Map<String, dynamic>> getDiaryStatistics() async {
    if (userId == null) return {};

    final QuerySnapshot entries = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .get();

    final Map<String, int> moodCounts = {};
    int totalEntries = entries.docs.length;

    for (var doc in entries.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final mood = data['mood'] as String;
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }

    return {
      'total_entries': totalEntries,
      'mood_counts': moodCounts,
    };
  }

  // Get entries for heatmap
  Future<Map<DateTime, int>> getEntriesForHeatmap() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diary')
          .get();
      final Map<DateTime, int> heatmapData = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['date'] as Timestamp;
        final date = timestamp.toDate();
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
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diary')
          .orderBy('date', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return {'current': 0, 'longest': 0, 'total': 0};
      }

      final List<DateTime> dates = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['date'] as Timestamp;
        return timestamp.toDate();
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

  // Get stress and non-stress entries grouped by day
  Future<Map<String, Map<String, int>>> getStressDataByDay(int days) async {
    try {
      // Calculate the date range (today minus specified days)
      final DateTime now = DateTime.now();
      final DateTime startDate =
          DateTime(now.year, now.month, now.day - (days - 1))
              .subtract(const Duration(milliseconds: 1));

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diary')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .orderBy('date', descending: false)
          .get();

      // Group entries by day and count stress vs non-stress
      final Map<String, Map<String, int>> result = {};

      // Initialize all days in range with zero counts
      for (int i = 0; i < days; i++) {
        final DateTime date =
            DateTime(now.year, now.month, now.day - (days - 1) + i);
        final String dateKey = '${date.month}-${date.day}';
        result[dateKey] = {'stress': 0, 'non-stress': 0};
      }

      // Count entries by day and mood
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['date'] as Timestamp;
        final date = timestamp.toDate();
        final String dateKey = '${date.month}-${date.day}';
        final String mood = data['mood'] as String;

        // Skip if the date is not in our range
        if (!result.containsKey(dateKey)) continue;

        // Map 'stress' directly, anything else goes to 'non-stress'
        final String moodKey = mood == 'stress' ? 'stress' : 'non-stress';
        result[dateKey]![moodKey] = (result[dateKey]![moodKey] ?? 0) + 1;
      }

      return result;
    } catch (e) {
      debugPrint('Error getting stress data by day: $e');
      return {};
    }
  }
}
