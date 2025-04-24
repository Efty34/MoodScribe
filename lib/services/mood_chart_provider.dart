import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/services/diary_service.dart';
import 'package:flutter/material.dart';

class MoodChartData {
  final int stressValue;
  final int nonStressValue;
  final DateTime lastUpdated;

  MoodChartData({
    required this.stressValue,
    required this.nonStressValue,
    required this.lastUpdated,
  });

  bool get isStale {
    // Consider data stale after 5 minutes
    return DateTime.now().difference(lastUpdated).inMinutes > 5;
  }

  int get totalEntries => stressValue + nonStressValue;
}

class MoodChartProvider with ChangeNotifier {
  final DiaryService _diaryService = DiaryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MoodChartData? _chartData;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _diarySubscription;

  // Getters
  MoodChartData? get chartData => _chartData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _chartData != null;

  // Check if data is available and not stale
  bool get isFreshDataAvailable => _chartData != null && !_chartData!.isStale;

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
      // When diary collection changes, refresh mood data
      fetchMoodData(forceRefresh: true, notifyOnStart: false);
    }, onError: (error) {
      debugPrint('Error listening to diary updates for mood chart: $error');
    });
  }

  // Initial fetch
  Future<void> fetchMoodData(
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
      final moodCounts = diaryStats['mood_counts'] as Map<String, dynamic>;

      // Count stress vs no stress entries
      final stressCount = moodCounts['stress'] ?? 0;
      final nonStressCount = moodCounts['no stress'] ?? 0;

      // Update chart data
      _chartData = MoodChartData(
        stressValue: stressCount,
        nonStressValue: nonStressCount,
        lastUpdated: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();

      // Setup real-time listener if not already set up
      if (_diarySubscription == null) {
        setupDiaryListener();
      }
    } catch (e) {
      _error = 'Failed to load mood data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to manually refresh data
  Future<void> refreshData() async {
    await fetchMoodData(forceRefresh: true);
  }

  // Don't forget to dispose of the subscription
  @override
  void dispose() {
    _diarySubscription?.cancel();
    super.dispose();
  }
}
