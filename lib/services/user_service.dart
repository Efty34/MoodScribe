import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = AuthService().currentUser?.uid;

  // Create or update user profile
  Future<void> updateUserProfile({
    required String username,
    required String email,
  }) async {
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).set({
      'username': username,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user profile
  Stream<DocumentSnapshot> getUserProfile() {
    if (userId == null) {
      return Stream.empty();
    }

    return _firestore.collection('users').doc(userId).snapshots();
  }
}
