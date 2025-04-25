import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class AppSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    IconData? customIcon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define icon and its color based on type
    late final IconData icon;
    late final Color iconColor;

    switch (type) {
      case SnackBarType.success:
        icon = customIcon ?? Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case SnackBarType.error:
        icon = customIcon ?? Icons.error_outline;
        iconColor = Colors.red;
        break;
      case SnackBarType.warning:
        icon = customIcon ?? Icons.warning_amber_outlined;
        iconColor = Colors.amber;
        break;
      case SnackBarType.info:
      default:
        icon = customIcon ?? Icons.info_outline;
        iconColor = Colors.blue;
        break;
    }

    // Black & white colors that adapt to theme mode
    final backgroundColor = isDark
        ? Colors.white // Dark gray (almost black) for dark mode
        : const Color(0xFF2C2C2C); // White for light mode

    final textColor = isDark ? Colors.black : Colors.white;

    // Calculate elevation based on theme
    final elevation = isDark ? 6.0 : 3.0;

    // Create and show the SnackBar
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      elevation: elevation,
      duration: duration,
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: iconColor, // Action text color matches icon color
              onPressed: onAction,
            )
          : null,
    );

    // Remove current SnackBar if any and show the new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
