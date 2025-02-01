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
}
