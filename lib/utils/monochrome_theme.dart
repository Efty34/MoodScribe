import 'package:flutter/material.dart';

/// A strict monochrome black and white color scheme
class MonochromeTheme {
  // Private constructor to prevent instantiation
  MonochromeTheme._();

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      // Core palette - pure black and white with subtle gray variations
      primary: Color(0xFF000000), // Pure black
      onPrimary: Color(0xFFFFFFFF), // Pure white
      secondary: Color(0xFFF5F5F5), // Light gray
      onSecondary: Color(0xFF000000), // Off-black
      surface: Color(0xFFFFFFFF), // Pure white
      onSurface: Color(0xFF191919), // Off-black
      error: Color(0xFF000000), // Black for errors (was red)
      onError: Color(0xFFFFFFFF), // Pure white
      primaryContainer: Color(0xFFE0E0E0), // Light gray
      secondaryContainer: Color(0xFFF0F0F0), // Even lighter gray
      outline: Color(0xFFD0D0D0), // Border color
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    cardColor: const Color(0xFFFFFFFF),
    dividerColor: const Color(0xFFE0E0E0), // Light gray divider
    hintColor: const Color(0xFF757575), // Medium gray text
    splashColor: const Color(0xFFEEEEEE), // Light gray splash
    highlightColor: const Color(0xFFE0E0E0), // Light gray highlight
    disabledColor: const Color(0xFFC0C0C0), // Medium gray for disabled

    // Typography colors
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF191919)),
      bodyMedium: TextStyle(color: Color(0xFF191919)),
      bodySmall: TextStyle(color: Color(0xFF4A4A4A)),
      labelLarge: TextStyle(color: Color(0xFF191919)),
      titleLarge: TextStyle(color: Color(0xFF191919)),
      titleMedium: TextStyle(color: Color(0xFF191919)),
      titleSmall: TextStyle(color: Color(0xFF4A4A4A)),
    ),

    // Component specific properties
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
      ),
    ),

    // Icons should be black
    iconTheme: const IconThemeData(
      color: Color(0xFF000000),
    ),
    primaryIconTheme: const IconThemeData(
      color: Color(0xFF000000),
    ),
  );

  // Dark theme using strict black and white monochrome
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      // Strict monochrome for dark theme
      primary: Color(0xFFFFFFFF), // Pure white (replacing purple)
      onPrimary: Color(0xFF000000), // Pure black
      secondary: Color(0xFF303030), // Dark gray (replacing teal)
      onSecondary: Color(0xFFFFFFFF), // Pure white
      surface: Color(0xFF121212), // Nearly black
      onSurface: Color(0xFFFFFFFF), // Pure white
      error: Color(0xFFFFFFFF), // White for errors (was colored)
      onError: Color(0xFF000000), // Pure black
      primaryContainer: Color(0xFF2C2C2C), // Dark gray
      secondaryContainer: Color(0xFF252525), // Slightly lighter dark gray
      outline: Color(0xFF404040), // Border color
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: const Color(0xFF2C2C2C),
    hintColor: const Color(0xFFABABAB),
    splashColor: const Color(0xFF333333), // Dark gray splash
    highlightColor: const Color(0xFF333333), // Dark gray highlight
    disabledColor: const Color(0xFF5C5C5C), // Medium gray for disabled

    // Typography colors for dark theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
      bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
      bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
      labelLarge: TextStyle(color: Color(0xFFFFFFFF)),
      titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
      titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
      titleSmall: TextStyle(color: Color(0xFFB0B0B0)),
    ),

    // Component specific properties for dark theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFFFFF), // Pure white (was purple)
        foregroundColor: const Color(0xFF000000), // Pure black
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),


    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
            color: Color(0xFFFFFFFF), width: 1.5), // White (was purple)
      ),
    ),

    // Icons should be white
    iconTheme: const IconThemeData(
      color: Color(0xFFFFFFFF),
    ),
    primaryIconTheme: const IconThemeData(
      color: Color(0xFFFFFFFF),
    ),
  );

  // Use this completely monochrome dark theme instead of the seeded one
  static final ThemeData monochromeDarkTheme = darkTheme;
}
