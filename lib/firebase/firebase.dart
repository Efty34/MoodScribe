import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseOptions {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save a diary entry (text and prediction) to Firestore
  static Future<void> saveDiaryEntry(String text, String prediction) async {
    try {
      // Use the SAME collection name for both saving & fetching
      await _firestore.collection('diaryEntries').add({
        'text': text,
        'prediction': prediction,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save diary entry: $e');
    }
  }

  /// Fetch all diary entries as a stream
  static Stream<QuerySnapshot> getDiaryEntries() {
    return _firestore
        .collection('diaryEntries')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
