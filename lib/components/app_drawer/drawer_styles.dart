import 'package:flutter/material.dart';

/// Shared style constants for app drawer components
class DrawerStyles {
  // Private constructor to prevent instantiation
  DrawerStyles._();

  /// Border radius for menu items and other components
  static const double borderRadius = 16.0;

  /// Standard icon size
  static const double iconSize = 24.0;

  /// Size for animations
  static const double animationSize = 64.0;

  /// Standard spacing between elements
  static const double spacing = 16.0;

  /// Height for menu items
  static const double menuItemHeight = 72.0;

  /// Standard text style used across drawer components
  static TextStyle getTextStyle(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: size,
      fontWeight: weight,
      color: color ?? theme.textTheme.bodyLarge?.color,
    );
  }

  /// Shadow for elevated components based on current theme
  static List<BoxShadow> getSoftShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ];
  }

  /// Extra light shadow for menu items based on current theme
  static List<BoxShadow> getMenuItemShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? [] // No shadow in dark mode for subtle appearance
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ];
  }
}
