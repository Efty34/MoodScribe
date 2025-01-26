import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = AuthService().currentUser?.uid;

  // Add item to favorites
  Future<void> addToFavorites({
    required String title,
    required String subtitle,
    required String imageUrl,
    required String category,
  }) async {
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .add({
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Remove item from favorites
  Future<void> removeFromFavorites(String favoriteId) async {
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(favoriteId)
        .delete();
  }

  // Get user's favorites
  Stream<QuerySnapshot> getFavorites() {
    if (userId == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
