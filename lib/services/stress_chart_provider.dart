import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/services/diary_service.dart';
import 'package:flutter/material.dart';

class StressChartData {
  final Map<String, Map<String, int>> stressData;
  final DateTime lastUpdated;

  StressChartData({
    required this.stressData,
    required this.lastUpdated,
  });

  bool get isStale {
    // Consider data stale after 5 minutes
    return DateTime.now().difference(lastUpdated).inMinutes > 5;
  }
}

class StressChartProvider with ChangeNotifier {
  final DiaryService _diaryService = DiaryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache data by time period for different views
  final Map<int, StressChartData?> _stressDataCache = {};
  final Map<int, bool> _loadingState = {};
  final Map<int, String?> _errorState = {};
  StreamSubscription<QuerySnapshot>? _diarySubscription;

  // Getters
  StressChartData? getChartData(int days) => _stressDataCache[days];
  bool isLoading(int days) => _loadingState[days] ?? false;
  String? getError(int days) => _errorState[days];
  bool hasData(int days) => _stressDataCache[days] != null;

  // Check if data is available and not stale
  bool isFreshDataAvailable(int days) {
    return _stressDataCache[days] != null && !(_stressDataCache[days]!.isStale);
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
      // When diary collection changes, refresh all cached periods
      _stressDataCache.keys.forEach((days) {
        fetchStressData(days, forceRefresh: true, notifyOnStart: false);
      });
    }, onError: (error) {
      debugPrint('Error listening to diary updates for stress chart: $error');
    });
  }

  // Fetch data for a specific time period
  Future<void> fetchStressData(int days,
      {bool forceRefresh = false, bool notifyOnStart = true}) async {
    // If we have fresh data and no force refresh is requested, return
    if (isFreshDataAvailable(days) && !forceRefresh) {
      return;
    }

    if (notifyOnStart) {
      _loadingState[days] = true;
      _errorState[days] = null;
      notifyListeners();
    }

    try {
      final data = await _diaryService.getStressDataByDay(days);

      // Update stress chart data
      _stressDataCache[days] = StressChartData(
        stressData: data,
        lastUpdated: DateTime.now(),
      );

      _loadingState[days] = false;
      notifyListeners();

      // Setup real-time listener if not already set up
      if (_diarySubscription == null) {
        setupDiaryListener();
      }
    } catch (e) {
      _errorState[days] = 'Failed to load stress chart data: $e';
      _loadingState[days] = false;
      notifyListeners();
    }
  }

  // Method to manually refresh data for a specific time period
  Future<void> refreshData(int days) async {
    await fetchStressData(days, forceRefresh: true);
  }

  // Clear a specific time period from cache
  void clearCache(int days) {
    _stressDataCache.remove(days);
    notifyListeners();
  }

  // Clear all cached data
  void clearAllCache() {
    _stressDataCache.clear();
    notifyListeners();
  }

  // Don't forget to dispose of the subscription
  @override
  void dispose() {
    _diarySubscription?.cancel();
    super.dispose();
  }
}
