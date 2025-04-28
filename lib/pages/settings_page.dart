import 'package:diary/components/settings/exact_alarm_permission_tile.dart';
import 'package:diary/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notifications section
              Text(
                'Notifications',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Notification Test Tile
              // NotificationTestTile(
              //   theme: theme,
              //   isDark: isDark,
              // ),

              // Exact Alarm Permission Tile (Android 12+ only)
              ExactAlarmPermissionTile(
                theme: theme,
                isDark: isDark,
              ),

              const SizedBox(height: 24),

              // Appearance section
              Text(
                'Appearance',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Theme switcher
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Label
                      Row(
                        children: [
                          Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: theme.colorScheme.onSecondary,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Dark Mode',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: theme.colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Switch
                      Switch(
                        value: isDark,
                        onChanged: (_) {
                          themeProvider.toggleTheme();
                        },
                        activeColor: theme.colorScheme.primary,
                        activeTrackColor: isDark
                            ? theme.colorScheme.onSurface.withOpacity(0.3)
                            : theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Version info
              Align(
                alignment: Alignment.center,
                child: Text(
                  'MoodScribe v1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
