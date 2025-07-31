import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'drawer_styles.dart';

/// A reusable menu item component for the app drawer
/// Supports both Lottie animations and icons with a modern design
class DrawerMenuItem extends StatelessWidget {
  final String title;
  final dynamic icon;
  final VoidCallback onTap;
  final bool isLottie;
  final String? badgeCount;
  final bool isDisabled;
  final String? subtitle;

  const DrawerMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isLottie = false,
    this.badgeCount,
    this.isDisabled = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Reduced icon size for cleaner appearance
    const double iconSize = 24.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(DrawerStyles.borderRadius),
        splashColor: isDisabled ? null : primaryColor.withOpacity(0.1),
        highlightColor: isDisabled ? null : primaryColor.withOpacity(0.05),
        hoverColor: isDisabled ? null : primaryColor.withOpacity(0.03),
        child: Ink(
          height: subtitle != null
              ? 68
              : 56, // Increased height when subtitle exists
          decoration: BoxDecoration(
            color: isDark ? Colors.transparent : Colors.transparent,
            borderRadius: BorderRadius.circular(DrawerStyles.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Icon or Animation with consistent sizing
                Container(
                  width: 32,
                  height: 32,
                  decoration: isLottie
                      ? null
                      : BoxDecoration(
                          color: isDisabled
                              ? theme.disabledColor.withOpacity(0.1)
                              : primaryColor.withOpacity(isDark ? 0.15 : 0.1),
                          shape: BoxShape.circle,
                        ),
                  child: isLottie
                      ? Lottie.asset(
                          icon,
                          width: 32,
                          height: 32,
                          repeat: true,
                          animate: true,
                        )
                      : Icon(
                          icon,
                          color:
                              isDisabled ? theme.disabledColor : primaryColor,
                          size: iconSize,
                        ),
                ),
                const SizedBox(width: 14),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDisabled
                              ? theme.disabledColor
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.hintColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
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
                      color: theme.colorScheme.error.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeCount!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: theme.colorScheme.onError,
                        fontWeight: FontWeight.w600,
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
