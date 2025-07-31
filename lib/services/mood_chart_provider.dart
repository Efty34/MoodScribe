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

  // Overall chart data
  MoodChartData? _chartData;
  bool _isLoading = false;
  String? _error;

  // Last 7 days chart data
  MoodChartData? _lastWeekChartData;
  bool _isLoadingLastWeek = false;
  String? _errorLastWeek;

  StreamSubscription<QuerySnapshot>? _diarySubscription;

  // Getters for overall data
  MoodChartData? get chartData => _chartData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _chartData != null;

  // Getters for last week data
  MoodChartData? get lastWeekChartData => _lastWeekChartData;
  bool get isLoadingLastWeek => _isLoadingLastWeek;
  String? get errorLastWeek => _errorLastWeek;
  bool get hasLastWeekData => _lastWeekChartData != null;

  // Check if data is available and not stale
  bool get isFreshDataAvailable => _chartData != null && !_chartData!.isStale;
  bool get isFreshLastWeekDataAvailable =>
      _lastWeekChartData != null && !_lastWeekChartData!.isStale;

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
      fetchLastWeekMoodData(forceRefresh: true, notifyOnStart: false);
    }, onError: (error) {
      debugPrint('Error listening to diary updates for mood chart: $error');
    });
  }

  // Initial fetch for overall data
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
      int stressCount = 0;
      int nonStressCount = 0;

      // Handle both old and new mood formats
      moodCounts.forEach((mood, count) {
        final moodLower = mood.toLowerCase();
        if (moodLower.contains('stress') && !moodLower.contains('no stress')) {
          stressCount += count as int;
        } else {
          nonStressCount += count as int;
        }
      });

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

  // Fetch last 7 days mood data
  Future<void> fetchLastWeekMoodData(
      {bool forceRefresh = false, bool notifyOnStart = true}) async {
    // If we have fresh data and no force refresh is requested, return
    if (isFreshLastWeekDataAvailable && !forceRefresh) {
      return;
    }

    if (notifyOnStart) {
      _isLoadingLastWeek = true;
      _errorLastWeek = null;
      notifyListeners();
    }

    try {
      // Get data for the last 7 days
      final stressData = await _diaryService.getStressDataByDay(7);

      // Count stress vs non-stress entries from the last 7 days
      int stressCount = 0;
      int nonStressCount = 0;

      stressData.forEach((key, counts) {
        stressCount += counts['stress'] ?? 0;
        nonStressCount += counts['non-stress'] ?? 0;
      });

      // Update last week chart data
      _lastWeekChartData = MoodChartData(
        stressValue: stressCount,
        nonStressValue: nonStressCount,
        lastUpdated: DateTime.now(),
      );

      _isLoadingLastWeek = false;
      notifyListeners();
    } catch (e) {
      _errorLastWeek = 'Failed to load last week mood data: $e';
      _isLoadingLastWeek = false;
      notifyListeners();
    }
  }

  // Method to manually refresh data
  Future<void> refreshData() async {
    await fetchMoodData(forceRefresh: true);
    await fetchLastWeekMoodData(forceRefresh: true);
  }

  // Don't forget to dispose of the subscription
  @override
  void dispose() {
    _diarySubscription?.cancel();
    super.dispose();
  }
}
