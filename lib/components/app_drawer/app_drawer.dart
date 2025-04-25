import 'package:diary/utils/app_routes.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'drawer_menu_item.dart';
import 'drawer_styles.dart';
import 'logout_manager.dart';

/// Custom drawer component for the app
class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // User's initial (placeholder - could be fetched from user profile)
    const userInitial = 'A';

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
      child: SafeArea(
        child: Column(
          children: [
            // App Header with User Avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // App Logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(DrawerStyles.borderRadius / 2),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // App Name
                  Expanded(
                    child: Text(
                      'Mind Journal',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  // User Avatar (or Initials)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor.withOpacity(0.2),
                    child: Text(
                      userInitial,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  // Logout button as icon in header
                ],
              ),
            ),

            // Menu Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  DrawerMenuItem(
                    title: 'MoodBuddy',
                    icon: AppMedia.moodbubby,
                    isLottie: true,
                    onTap: () => Navigator.of(context)
                      ..pop()
                      ..pushNamed(AppRoutes.moodBuddyPage),
                  ),
                  const SizedBox(height: 12),
                  DrawerMenuItem(
                    title: 'Journal',
                    icon: AppMedia.diary,
                    isLottie: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                  DrawerMenuItem(
                    title: 'Sessions',
                    icon: Icons.calendar_month_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                  DrawerMenuItem(
                    title: 'Games',
                    icon: Icons.games_rounded,
                    onTap: () => Navigator.pop(context),
                    badgeCount: '3',
                  ),
                  const SizedBox(height: 12),
                  DrawerMenuItem(
                    title: 'Stats',
                    icon: AppMedia.graph,
                    isLottie: true,
                    onTap: () => Navigator.of(context)
                      ..pop()
                      ..pushNamed(AppRoutes.statsPage),
                  ),
                  const SizedBox(height: 12),
                  DrawerMenuItem(
                    title: 'Settings',
                    icon: AppMedia.settings,
                    isLottie: true,
                    onTap: () => Navigator.of(context)
                      ..pop()
                      ..pushNamed(AppRoutes.settingsPage),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Version text at bottom
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  IconButton(
                    alignment: Alignment.bottomRight,
                    icon: const Icon(Icons.logout_rounded, size: 26),
                    color: Colors.red,
                    onPressed: () => LogoutManager.handleLogout(context),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
