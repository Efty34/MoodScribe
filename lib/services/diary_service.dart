import 'package:cloud_firestore/cloud_firestore.dart';

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
          await _diaryCollection.orderBy('timestamp').get();

      if (snapshot.docs.isEmpty) {
        return {'current': 0, 'longest': 0, 'total': 0};
      }

      final dates = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] as int;
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }).toList();

      int currentStreak = 1;
      int longestStreak = 1;
      int tempStreak = 1;
      DateTime? lastDate;

      for (var date in dates) {
        if (lastDate != null) {
          final difference = date.difference(lastDate).inDays;
          if (difference == 1) {
            tempStreak++;
            longestStreak =
                tempStreak > longestStreak ? tempStreak : longestStreak;
          } else if (difference > 1) {
            tempStreak = 1;
          }
        }
        lastDate = date;
      }

      // Calculate current streak
      final today = DateTime.now();
      final lastEntryDate = dates.last;
      final difference = today.difference(lastEntryDate).inDays;

      if (difference <= 1) {
        currentStreak = tempStreak;
      } else {
        currentStreak = 0;
      }

      return {
        'current': currentStreak,
        'longest': longestStreak,
        'total': snapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to get streak information: $e');
    }
  }
}
