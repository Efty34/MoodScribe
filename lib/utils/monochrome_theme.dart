import 'package:flutter/material.dart';

/// A soothing, wellness-focused color scheme with a bluish vibe for a stress monitoring app
class MonochromeTheme {
  // Private constructor to prevent instantiation
  MonochromeTheme._();

  // Light theme with improved contrast and tertiary colors
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF42A5F5), // Soft sky blue
      onPrimary: Color(0xFFFFFFFF), // Pure white
      secondary: Color(0xFF90CAF9), // Light blue
      onSecondary: Color(0xFF1A2E3B), // Darker blue-gray for contrast
      tertiary: Color(0xFF26A69A), // Soft teal for accents
      onTertiary: Color(0xFFFFFFFF), // White for text on tertiary
      surface: Color(0xFFF8FAFC), // Lighter cool gray
      onSurface: Color(0xFF1A1A1A), // Near black for high contrast
      error: Color(0xFFE57373), // Soft coral for errors
      onError: Color(0xFFFFFFFF), // Pure white
      primaryContainer: Color(0xFFE1F5FE), // Very light blue
      onPrimaryContainer: Color(0xFF0D3A5C), // Dark blue for contrast
      secondaryContainer: Color(0xFFBBDEFB), // Pale blue
      onSecondaryContainer: Color(0xFF1A2E3B), // Darker blue-gray
      tertiaryContainer: Color(0xFFB2DFDB), // Light teal
      onTertiaryContainer: Color(0xFF0F2F2C), // Dark teal for contrast
      outline: Color(0xFFA3BFFA), // Soft indigo for borders
    ),
    scaffoldBackgroundColor: const Color(0xFFE8F0FE), // Very light indigo
    cardColor: const Color(0xFFFFFFFF), // Pure white for cards
    dividerColor: const Color(0xFFD1D9E0), // Soft blue-gray divider
    hintColor: const Color(0xFF6B7280), // Darker gray for hints
    splashColor: const Color(0xFFBBDEFB), // Pale blue splash
    highlightColor: const Color(0xFFE1F5FE), // Very light blue highlight
    disabledColor: const Color(0xFFB0BEC5), // Muted blue-gray for disabled

    // Typography colors
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1A1A1A)), // Near black
      bodyMedium: TextStyle(color: Color(0xFF1A1A1A)), // Near black
      bodySmall: TextStyle(color: Color(0xFF4B5563)), // Dark gray
      labelLarge: TextStyle(color: Color(0xFF1A1A1A)), // Near black
      titleLarge: TextStyle(color: Color(0xFF1A1A1A)), // Near black
      titleMedium: TextStyle(color: Color(0xFF1A1A1A)), // Near black
      titleSmall: TextStyle(color: Color(0xFF4B5563)), // Dark gray
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
      filled: true,
      fillColor: const Color(0xFFE1F5FE), // Very light blue
      border: OutlineInputBorder(
        borderSide: const BorderSide(
            color: Color(0xFFA3BFFA), width: 1.5), // Soft indigo
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
            color: Color(0xFF42A5F5), width: 2), // Soft sky blue
      ),
    ),

    // Icons in tertiary color for better distinction
    iconTheme: const IconThemeData(
      color: Color(0xFF26A69A), // Soft teal
    ),
    primaryIconTheme: const IconThemeData(
      color: Color(0xFF42A5F5), // Soft sky blue
    ),
  );

  // Dark theme with tranquil blue tones and tertiary colors
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF64B5F6), // Muted blue
      onPrimary: Color(0xFF0A1C2B), // Darker for contrast
      secondary: Color(0xFF4FC3F7), // Brighter blue accent
      onSecondary: Color(0xFF0A1C2B), // Darker for contrast
      tertiary: Color(0xFF4DB6AC), // Muted teal
      onTertiary: Color(0xFF0A1C2B), // Darker for contrast
      surface: Color(0xFF1E272E), // Dark blue-gray
      onSurface: Color(0xFFF1F5F9), // Light gray for high contrast
      error: Color(0xFFEF9A9A), // Soft coral for errors
      onError: Color(0xFF0A1C2B), // Darker for contrast
      primaryContainer: Color(0xFF2E3B4E), // Darker blue-gray
      onPrimaryContainer: Color(0xFFE1F5FE), // Light blue for contrast
      secondaryContainer: Color(0xFF37474F), // Slightly lighter blue-gray
      onSecondaryContainer: Color(0xFFE1F5FE), // Light blue for contrast
      tertiaryContainer: Color(0xFF2F6B66), // Dark teal
      onTertiaryContainer: Color(0xFFB2DFDB), // Light teal for contrast
      outline: Color(0xFF64748B), // Muted slate for borders
    ),
    scaffoldBackgroundColor: const Color(0xFF171F26), // Darker blue-gray
    cardColor: const Color(0xFF2E3B4E), // Darker blue-gray for cards
    dividerColor: const Color(0xFF37474F), // Darker blue-gray divider
    hintColor: const Color(0xFF94A3B8), // Light slate for hints
    splashColor: const Color(0xFF37474F), // Dark blue-gray splash
    highlightColor: const Color(0xFF2E3B4E), // Darker blue-gray highlight
    disabledColor: const Color(0xFF64748B), // Muted slate for disabled

    // Typography colors for dark theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFF1F5F9)), // Light gray
      bodyMedium: TextStyle(color: Color(0xFFF1F5F9)), // Light gray
      bodySmall: TextStyle(color: Color(0xFF94A3B8)), // Light slate
      labelLarge: TextStyle(color: Color(0xFFF1F5F9)), // Light gray
      titleLarge: TextStyle(color: Color(0xFFF1F5F9)), // Light gray
      titleMedium: TextStyle(color: Color(0xFFF1F5F9)), // Light gray
      titleSmall: TextStyle(color: Color(0xFF94A3B8)), // Light slate
    ),

    // Component specific properties for dark theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF64B5F6), // Muted blue
        foregroundColor: const Color(0xFF0A1C2B), // Darker for contrast
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2E3B4E), // Darker blue-gray
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFF64B5F6), width: 2), // Muted blue
      ),
    ),

    // Icons in tertiary color for better distinction
    iconTheme: const IconThemeData(
      color: Color(0xFF4DB6AC), // Muted teal
    ),
    primaryIconTheme: const IconThemeData(
      color: Color(0xFF64B5F6), // Muted blue
    ),
  );

  // Use this soothing blue dark theme instead of the seeded one
  static final ThemeData monochromeDarkTheme = darkTheme;
}
