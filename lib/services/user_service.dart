import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';
import 'package:flutter/material.dart';

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

  // Check and unlock calendar access if 5-day streak is achieved
  Future<void> checkAndUnlockCalendarAccess(int currentStreak) async {
    if (userId == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data();

      // Check if calendar access is already unlocked
      final bool calendarAccess = data?['calendarAccess'] ?? false;

      // If not already unlocked and streak >= 5, unlock it
      if (!calendarAccess && currentStreak >= 5) {
        await _firestore.collection('users').doc(userId).set({
          'calendarAccess': true,
          'calendarUnlockedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('Calendar access unlocked for user: $userId');
      }
    } catch (e) {
      debugPrint('Error checking calendar access: $e');
    }
  }

  // Get calendar access status
  Future<bool> getCalendarAccess() async {
    if (userId == null) return false;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data();
      return data?['calendarAccess'] ?? false;
    } catch (e) {
      debugPrint('Error getting calendar access: $e');
      return false;
    }
  }

  // Stream calendar access status for real-time updates
  Stream<bool> getCalendarAccessStream() {
    if (userId == null) {
      return Stream.value(false);
    }

    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data();
      return data?['calendarAccess'] ?? false;
    });
  }
}
