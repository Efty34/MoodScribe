import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/services/diary_service.dart';
import 'package:flutter/material.dart';

class StreakCalendarData {
  final Map<DateTime, int> datasets;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastUpdated;

  StreakCalendarData({
    required this.datasets,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastUpdated,
  });

  bool get isStale {
    // Consider data stale after 5 minutes
    return DateTime.now().difference(lastUpdated).inMinutes > 5;
  }
}

class StreakCalendarProvider with ChangeNotifier {
  final DiaryService _diaryService = DiaryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreakCalendarData? _calendarData;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _diarySubscription;

  // Getters
  StreakCalendarData? get calendarData => _calendarData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _calendarData != null;

  // Check if data is available and not stale
  bool get isFreshDataAvailable =>
      _calendarData != null && !_calendarData!.isStale;

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
      // When diary collection changes, refresh calendar data
      fetchCalendarData(forceRefresh: true, notifyOnStart: false);
    }, onError: (error) {
      debugPrint(
          'Error listening to diary updates for streak calendar: $error');
    });
  }

  // Initial fetch
  Future<void> fetchCalendarData(
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
      // Get heatmap data
      final heatmapData = await _diaryService.getEntriesForHeatmap();

      // Get streak information
      final streakInfo = await _diaryService.getStreakInfo();

      // Update calendar data
      _calendarData = StreakCalendarData(
        datasets: heatmapData,
        currentStreak: streakInfo['current'] ?? 0,
        longestStreak: streakInfo['longest'] ?? 0,
        lastUpdated: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();

      // Setup real-time listener if not already set up
      if (_diarySubscription == null) {
        setupDiaryListener();
      }
    } catch (e) {
      _error = 'Failed to load streak calendar data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to manually refresh data
  Future<void> refreshData() async {
    await fetchCalendarData(forceRefresh: true);
  }

  // Don't forget to dispose of the subscription
  @override
  void dispose() {
    _diarySubscription?.cancel();
    super.dispose();
  }
}
