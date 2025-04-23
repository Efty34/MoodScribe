import 'package:diary/auth/auth_service.dart';
import 'package:diary/utils/app_routes.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'dialog_button.dart';
import 'drawer_styles.dart';

/// Manages logout flow with a confirmation dialog
class LogoutManager {
  const LogoutManager._();

  /// Shows a confirmation dialog and handles the logout process
  static Future<void> handleLogout(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: DrawerStyles.getSoftShadow(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Lottie.asset(
                    AppMedia.logout,
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DialogButton(
                      label: 'Cancel',
                      onTap: () => Navigator.pop(context, false),
                      isOutlined: true,
                    ),
                    const SizedBox(width: 16),
                    DialogButton(
                      label: 'Logout',
                      onTap: () => Navigator.pop(context, true),
                      color: theme.colorScheme.error,
                      textColor: theme.colorScheme.onError,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldLogout == true) {
      await AuthService().signOut();

      if (context.mounted) {
        Navigator.of(context)
          ..pop()
          ..pushNamedAndRemoveUntil(
            AppRoutes.loginPage,
            (route) => false,
          );
      }
    }
  }
}
