import 'package:flutter/foundation.dart';

/// Provider for managing calendar access state
class CalendarAccessProvider extends ChangeNotifier {
  bool _hasCalendarAccess = true; // HARDCODED: Always unlocked for demo

  bool get hasCalendarAccess => _hasCalendarAccess;

  CalendarAccessProvider() {
    _initializeCalendarAccess();
  }

  void _initializeCalendarAccess() {
    // HARDCODED: For demo purposes, always show as unlocked
    _hasCalendarAccess = true;

    // Original stream listener (commented out for demo)
    // _userService.getCalendarAccessStream().listen((hasAccess) {
    //   if (_hasCalendarAccess != hasAccess) {
    //     _hasCalendarAccess = hasAccess;
    //     notifyListeners();
    //   }
    // });
  }

  /// Check current calendar access status
  Future<void> checkCalendarAccess() async {
    // HARDCODED: Always return true for demo
    _hasCalendarAccess = true;
    notifyListeners();

    // Original implementation (commented out for demo)
    // final hasAccess = await _userService.getCalendarAccess();
    // if (_hasCalendarAccess != hasAccess) {
    //   _hasCalendarAccess = hasAccess;
    //   notifyListeners();
    // }
  }
}
