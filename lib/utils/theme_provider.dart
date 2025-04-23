import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Key for storing theme preference
  static const String _themePreferenceKey = 'theme_preference';

  // Initial theme mode (default to light)
  ThemeMode _themeMode = ThemeMode.light;

  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;

  // Constructor loads saved preferences
  ThemeProvider() {
    _loadThemePreference();
  }

  // Is dark mode enabled
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Toggle between light and dark mode
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePreferenceKey);

    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light; // Default to light
    }

    notifyListeners();
  }

  // Save theme preference
  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();

    if (_themeMode == ThemeMode.dark) {
      await prefs.setString(_themePreferenceKey, 'dark');
    } else if (_themeMode == ThemeMode.light) {
      await prefs.setString(_themePreferenceKey, 'light');
    } else {
      await prefs.setString(_themePreferenceKey, 'light');
    }
  }
}
