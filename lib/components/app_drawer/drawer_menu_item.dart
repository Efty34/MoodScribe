import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'drawer_styles.dart';

/// A reusable menu item component for the app drawer
/// Supports both Lottie animations and icons
class DrawerMenuItem extends StatelessWidget {
  final String title;
  final dynamic icon;
  final VoidCallback onTap;
  final bool isLottie;
  final String? badgeCount;

  const DrawerMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isLottie = false,
    this.badgeCount,
  });

  TextStyle _getTextStyle(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color ?? theme.textTheme.bodyLarge?.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DrawerStyles.borderRadius),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: Ink(
          height: DrawerStyles.menuItemHeight,
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : theme.cardColor,
            borderRadius: BorderRadius.circular(DrawerStyles.borderRadius),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Icon or Animation
                Container(
                  width: 40,
                  height: 40,
                  decoration: isLottie
                      ? null
                      : BoxDecoration(
                          color: primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                  child: isLottie
                      ? Lottie.asset(
                          icon,
                          width: 40,
                          height: 40,
                          repeat: true,
                          animate: true,
                        )
                      : Icon(
                          icon,
                          color: primaryColor,
                          size: DrawerStyles.iconSize,
                        ),
                ),
                const SizedBox(width: 16),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: _getTextStyle(
                      context,
                      size: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                // Badge (if any)
                if (badgeCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeCount!,
                      style: _getTextStyle(
                        context,
                        size: 12,
                        color: theme.colorScheme.onError,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
