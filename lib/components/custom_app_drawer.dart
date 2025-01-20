import 'package:diary/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // App Logo Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade800,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder for app logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mind Journal',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  icon: Icons.mood_rounded,
                  title: 'Mood Buddy',
                  onTap: () => Navigator.of(context)
                    ..pop()
                    ..pushNamed(AppRoutes.moodBuddyPage),
                  showNew: true,
                ),
                _buildMenuItem(
                  icon: Icons.calendar_month_rounded,
                  title: 'Appointments',
                  onTap: () {
                    // Navigate to Appointments
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.games_rounded,
                  title: 'Games',
                  onTap: () {
                    // Navigate to Games
                    Navigator.pop(context);
                  },
                  showBadge: '3',
                ),
                _buildMenuItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    // Navigate to Settings
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 40),
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.loginPage);
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),

          // Bottom Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showNew = false,
    String? showBadge,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey[700],
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isDestructive ? Colors.red : Colors.grey[800],
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'NEW',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (showBadge != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                showBadge,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      dense: true,
    );
  }
}
