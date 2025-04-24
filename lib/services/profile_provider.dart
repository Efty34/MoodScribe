import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/services/diary_service.dart';
import 'package:diary/services/user_service.dart';
import 'package:flutter/material.dart';

class ProfileData {
  final Map<String, dynamic> stats;
  final DateTime lastUpdated;

  ProfileData({
    required this.stats,
    required this.lastUpdated,
  });

  bool get isStale {
    // Consider data stale after 5 minutes
    return DateTime.now().difference(lastUpdated).inMinutes > 5;
  }
}

class UserProfileProvider with ChangeNotifier {
  final DiaryService _diaryService = DiaryService();
  final UserService _userService = UserService();

  ProfileData? _profileData;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _diarySubscription;

  // Getters
  ProfileData? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _profileData != null;

  // Check if data is available and not stale
  bool get isFreshDataAvailable =>
      _profileData != null && !_profileData!.isStale;

  // Stream for user data
  Stream<DocumentSnapshot> getUserStream() {
    return _userService.getUserProfile();
  }

  // Setup real-time listener for diary updates
  void setupDiaryListener() {
    final userId = _diaryService.userId;
    if (userId == null) return;

    // Cancel any existing subscription
    _diarySubscription?.cancel();

    // Setup new subscription to listen for diary updates
    _diarySubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .snapshots()
        .listen((_) {
      // When diary collection changes, refresh stats
      fetchProfileData(forceRefresh: true, notifyOnStart: false);
    }, onError: (error) {
      debugPrint('Error listening to diary updates: $error');
    });
  }

  // Initial fetch
  Future<void> fetchProfileData(
      {bool forceRefresh = false, bool notifyOnStart = true}) async {
    // If we have fresh data and no force refresh is requested, return
    if (isFreshDataAvailable && !forceRefresh) {
      return;
    }

    if (notifyOnStart) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      // Get diary statistics
      final diaryStats = await _diaryService.getDiaryStatistics();

      // Get streak information
      final streakInfo = await _diaryService.getStreakInfo();

      // Compile stats
      final stats = {
        'total_entries': diaryStats['total_entries'] ?? 0,
        'current_streak': streakInfo['current'] ?? 0,
        'longest_streak': streakInfo['longest'] ?? 0,
        'mood_counts': diaryStats['mood_counts'] ?? {},
      };

      // Update profile data with new stats
      _profileData = ProfileData(
        stats: stats,
        lastUpdated: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();

      // Setup real-time listener if not already set up
      if (_diarySubscription == null) {
        setupDiaryListener();
      }
    } catch (e) {
      _error = 'Failed to load profile data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to manually refresh data
  Future<void> refreshData() async {
    await fetchProfileData(forceRefresh: true);
  }

  // Don't forget to dispose of the subscription
  @override
  void dispose() {
    _diarySubscription?.cancel();
    super.dispose();
  }

  // Firestore instance for direct access
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
}
