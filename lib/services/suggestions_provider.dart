import 'dart:async';

import 'package:flutter/material.dart';

import 'suggestion_service.dart';

class SuggestionsData {
  final SuggestionResponse data;
  final DateTime lastUpdated;

  SuggestionsData({
    required this.data,
    required this.lastUpdated,
  });

  bool get isStale {
    // Consider data stale after 30 minutes
    return DateTime.now().difference(lastUpdated).inMinutes > 30;
  }
}

class SuggestionsProvider with ChangeNotifier {
  final SuggestionService _suggestionService = SuggestionService();

  SuggestionsData? _suggestionsData;
  bool _isLoading = false;
  String? _error;

  // Getters
  SuggestionsData? get suggestionsData => _suggestionsData;
  SuggestionResponse? get data => _suggestionsData?.data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _suggestionsData != null;

  // Check if data is available and not stale
  bool get isFreshDataAvailable =>
      _suggestionsData != null && !_suggestionsData!.isStale;

  Future<void> loadSuggestions({bool forceRefresh = false}) async {
    // Return early if we have fresh data and not forcing refresh
    if (!forceRefresh && isFreshDataAvailable) {
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final suggestionResponse = await _suggestionService.getSuggestions();
      _suggestionsData = SuggestionsData(
        data: suggestionResponse,
        lastUpdated: DateTime.now(),
      );
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load suggestions: $e');
      _setLoading(false);
    }
  }

  Future<void> refreshSuggestions() async {
    await loadSuggestions(forceRefresh: true);
  }

  void clearData() {
    _suggestionsData = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
