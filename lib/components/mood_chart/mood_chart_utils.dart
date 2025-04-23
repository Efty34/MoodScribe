import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme-aware color and style utilities for the mood chart components
class MoodChartUtils {
  // Color utilities
  static Color getPositiveColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF7ECFFF) : const Color(0xFF70D6FF);

  static Color getStressedColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xFFFF9E9E) : const Color(0xFFFF8080);

  static Color? getTextColor(bool isDarkMode) =>
      isDarkMode ? Colors.white : Colors.grey[800];

  static Color? getSubTextColor(bool isDarkMode) =>
      isDarkMode ? Colors.grey[400] : Colors.grey[600];

  static Color? getCardColor(bool isDarkMode) =>
      isDarkMode ? Colors.grey[850] : Colors.white;

  static Color getBorderColor(bool isDarkMode) =>
      isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;

  // Style utilities
  static TextStyle getTitleStyle(bool isDarkMode) {
    return GoogleFonts.nunito(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: getTextColor(isDarkMode),
      letterSpacing: 0.3,
    );
  }

  static TextStyle getSubtitleStyle(bool isDarkMode) {
    return GoogleFonts.nunito(
      fontSize: 14,
      color: getSubTextColor(isDarkMode),
      letterSpacing: 0.1,
    );
  }

  static TextStyle getChartLabelStyle() {
    return GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  static TextStyle getNumberStyle(bool isDarkMode) {
    return GoogleFonts.nunito(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
    );
  }

  // Calculate percentages
  static double calculatePercentage(int value, int total) {
    return total > 0 ? ((value / total) * 100).toDouble() : 0.0;
  }
}
