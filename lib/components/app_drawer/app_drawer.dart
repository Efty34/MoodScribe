import 'package:diary/services/calendar_access_provider.dart';
import 'package:diary/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'drawer_menu_item.dart';
import 'drawer_styles.dart';
import 'logout_manager.dart';

/// Custom drawer component for the app with modern minimal design
class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;

    // Reduce drawer width to 75% of screen width
    final drawerWidth = screenWidth * 0.75;

    return Theme(
      data: Theme.of(context).copyWith(
        // Remove default drawer edge padding
        drawerTheme: DrawerThemeData(
          width: drawerWidth,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(DrawerStyles.borderRadius),
              bottomRight: Radius.circular(DrawerStyles.borderRadius),
            ),
          ),
        ),
      ),
      child: Drawer(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
        child: SafeArea(
          child: Column(
            children: [
              // Modern stacked header with logo and user info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  // Add subtle blur effect in the header
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDark
                          ? const Color(0xFF2A2A2A).withOpacity(0.95)
                          : Colors.white.withOpacity(0.95),
                      isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App logo centered
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              DrawerStyles.borderRadius / 2),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              DrawerStyles.borderRadius / 2),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // App name centered with slightly larger font
                    Center(
                      child: Text(
                        'MoodScribe',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge?.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items in a list with logical groups and dividers
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  children: [
                    // Main features group
                    _buildSectionHeader(context, 'Main'),
                    const SizedBox(height: 8),
                    DrawerMenuItem(
                      title: 'Journaling',
                      icon: Icons.book_outlined,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 10),
                    DrawerMenuItem(
                      title: 'Sessions',
                      icon: Icons.calendar_month_rounded,
                      onTap: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Activities group
                    _buildSectionHeader(context, 'Activities'),
                    const SizedBox(height: 8),
                    Consumer<CalendarAccessProvider>(
                      builder: (context, calendarProvider, child) {
                        final hasCalendarAccess =
                            calendarProvider.hasCalendarAccess;

                        return DrawerMenuItem(
                          title: 'Mood Streak Calendar',
                          icon: hasCalendarAccess
                              ? Icons.calendar_view_month
                              : Icons.lock_outlined,
                          isDisabled: !hasCalendarAccess,
                          subtitle: hasCalendarAccess
                              ? '✨ Unlocked with 5-day streak!'
                              : 'Unlock with 5-day streak',
                          onTap: hasCalendarAccess
                              ? () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, AppRoutes.statsPage);
                                }
                              : () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Keep journaling! Unlock this feature with a 5-day streak.',
                                        style: GoogleFonts.nunito(),
                                      ),
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // // App settings group
                    // _buildSectionHeader(context, 'App'),
                    // const SizedBox(height: 8),
                    // DrawerMenuItem(
                    //   title: 'Notification',
                    //   icon: Icons.notifications_outlined,
                    //   onTap: () {
                    //     _scheduleNotification();
                    //     Navigator.pop(context);
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(
                    //         content: Text(
                    //             'Notification scheduled for 20 seconds from now!'),
                    //         duration: Duration(seconds: 2),
                    //       ),
                    //     );
                    //   },
                    // ),
                    // const SizedBox(height: 10),
                    DrawerMenuItem(
                      title: 'Settings',
                      icon: Icons.settings_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.settingsPage);
                      },
                    ),
                  ],
                ),
              ),

              // Logout button - full width
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: () => LogoutManager.handleLogout(context),
                  icon: Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error.withOpacity(0.9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DrawerStyles.borderRadius),
                    ),
                    elevation: isDark ? 0 : 1,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),

              // Version info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'Version 1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary.withOpacity(0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
