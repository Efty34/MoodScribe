import 'package:flutter/material.dart';

/// A soothing, wellness-focused color scheme with a bluish vibe for a stress monitoring app
class MonochromeTheme {
  // Private constructor to prevent instantiation
  MonochromeTheme._();

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      // Core palette - soft blues and cool neutrals
      primary: Color(0xFF42A5F5), // Soft sky blue
      onPrimary: Color(0xFFFFFFFF), // Pure white
      secondary: Color(0xFF90CAF9), // Light blue
      onSecondary: Color(0xFF263238), // Dark blue-gray
      surface: Color(0xFFF5F7FA), // Light cool gray
      onSurface: Color(0xFF2E2E2E), // Dark charcoal
      error: Color(0xFFE57373), // Soft coral for errors
      onError: Color(0xFFFFFFFF), // Pure white
      primaryContainer: Color(0xFFE1F5FE), // Very light blue
      secondaryContainer: Color(0xFFBBDEFB), // Pale blue
      outline: Color(0xFFB0BEC5), // Muted blue-gray for borders
    ),
    scaffoldBackgroundColor: const Color(0xFFE3F2FD), // Very light blue
    cardColor: const Color(0xFFFFFFFF), // Pure white for cards
    dividerColor: const Color(0xFFD1D9E0), // Soft blue-gray divider
    hintColor: const Color(0xFF78909C), // Muted blue-gray for hints
    splashColor: const Color(0xFFBBDEFB), // Pale blue splash
    highlightColor: const Color(0xFFE1F5FE), // Very light blue highlight
    disabledColor: const Color(0xFFB0BEC5), // Muted blue-gray for disabled

    // Typography colors
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF2E2E2E)), // Dark charcoal
      bodyMedium: TextStyle(color: Color(0xFF2E2E2E)), // Dark charcoal
      bodySmall: TextStyle(color: Color(0xFF607D8B)), // Muted blue-gray
      labelLarge: TextStyle(color: Color(0xFF2E2E2E)), // Dark charcoal
      titleLarge: TextStyle(color: Color(0xFF2E2E2E)), // Dark charcoal
      titleMedium: TextStyle(color: Color(0xFF2E2E2E)), // Dark charcoal
      titleSmall: TextStyle(color: Color(0xFF607D8B)), // Muted blue-gray
    ),

    // Component specific properties
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF42A5F5), // Soft sky blue
        foregroundColor: const Color(0xFFFFFFFF), // Pure white
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      // filled: true,
      // fillColor: const Color.fromARGB(255, 220, 237, 252), // Pale blue
      border: OutlineInputBorder(
        borderSide:
            BorderSide(color: Color(0xFFBBDEFB), width: 1.5), // Muted blue-gray
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
            color: Color(0xFF42A5F5), width: 1.5), // Soft sky blue
      ),
    ),

    // Icons in soft blue
    iconTheme: const IconThemeData(
      color: Color(0xFF42A5F5), // Soft sky blue
    ),
    primaryIconTheme: const IconThemeData(
      color: Color(0xFF42A5F5), // Soft sky blue
    ),
  );

  // Dark theme with tranquil blue tones
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      // Soothing dark palette with blue tones
      primary: Color(0xFF64B5F6), // Muted blue
      onPrimary: Color(0xFF121212), // Near black
      secondary: Color(0xFF4FC3F7), // Brighter blue accent
      onSecondary: Color(0xFF121212), // Near black
      surface: Color(0xFF1E272E), // Dark blue-gray
      onSurface: Color(0xFFECEFF1), // Off-white
      error: Color(0xFFEF9A9A), // Soft coral for errors
      onError: Color(0xFF121212), // Near black
      primaryContainer: Color(0xFF263238), // Darker blue-gray
      secondaryContainer: Color(0xFF37474F), // Slightly lighter blue-gray
      outline: Color(0xFF546E7A), // Muted blue-gray for borders
    ),
    scaffoldBackgroundColor: const Color(0xFF1E272E), // Dark blue-gray
    cardColor: const Color(0xFF263238), // Darker blue-gray for cards
    dividerColor: const Color(0xFF37474F), // Darker blue-gray divider
    hintColor: const Color(0xFF90A4AE), // Light blue-gray for hints
    splashColor: const Color(0xFF37474F), // Dark blue-gray splash
    highlightColor: const Color(0xFF263238), // Darker blue-gray highlight
    disabledColor: const Color(0xFF546E7A), // Muted blue-gray for disabled

    // Typography colors for dark theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFECEFF1)), // Off-white
      bodyMedium: TextStyle(color: Color(0xFFECEFF1)), // Off-white
      bodySmall: TextStyle(color: Color(0xFF90A4AE)), // Light blue-gray
      labelLarge: TextStyle(color: Color(0xFFECEFF1)), // Off-white
      titleLarge: TextStyle(color: Color(0xFFECEFF1)), // Off-white
      titleMedium: TextStyle(color: Color(0xFFECEFF1)), // Off-white
      titleSmall: TextStyle(color: Color(0xFF90A4AE)), // Light blue-gray
    ),

    // Component specific properties for dark theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF64B5F6), // Muted blue
        foregroundColor: const Color(0xFF121212), // Near black
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF263238), // Darker blue-gray
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
            color: Color(0xFF64B5F6), width: 1.5), // Muted blue
      ),
    ),

    // Icons in muted blue
    iconTheme: const IconThemeData(
      color: Color(0xFF64B5F6), // Muted blue
    ),
    primaryIconTheme: const IconThemeData(
      color: Color(0xFF64B5F6), // Muted blue
    ),
  );

  // Use this soothing blue dark theme instead of the seeded one
  static final ThemeData monochromeDarkTheme = darkTheme;
}
