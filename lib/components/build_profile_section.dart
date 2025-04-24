import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/animation_widget.dart';
import 'package:diary/services/profile_provider.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BuildProfileSection extends StatefulWidget {
  const BuildProfileSection({super.key});

  @override
  State<BuildProfileSection> createState() => _BuildProfileSectionState();
}

class _BuildProfileSectionState extends State<BuildProfileSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    // Initial fetch using the provider and setup real-time listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      provider.fetchProfileData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Manual refresh function
  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    await provider.refreshData();

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use the provider to access cached profile data
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        // Listen to user data stream for real-time profile updates
        return StreamBuilder<DocumentSnapshot>(
          stream: profileProvider.getUserStream(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${userSnapshot.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              );
            }

            final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
            final username = userData?['username'] ?? 'User';
            final email = userData?['email'] ?? 'No email';

            // Check if stats are still loading for the first time
            if (profileProvider.isLoading && !profileProvider.hasData) {
              return Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
              );
            }

            // If we have an error, show error state
            if (profileProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profileProvider.error!,
                      style: GoogleFonts.poppins(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Get stats from the provider
            final stats = profileProvider.profileData?.stats ??
                {
                  'total_entries': 0,
                  'current_streak': 0,
                  'longest_streak': 0,
                  'mood_counts': {},
                };

            return RefreshIndicator(
              onRefresh: _refreshData,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          isDark ? theme.colorScheme.surface : theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.15)
                              : Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 3),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                      gradient: isDark
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.surface,
                                theme.colorScheme.surface.withOpacity(0.9),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.cardColor,
                                theme.cardColor.withOpacity(0.95),
                              ],
                            ),
                    ),
                    child: Column(
                      children: [
                        // User Info Row
                        Row(
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(isDark ? 0.8 : 0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(isDark ? 0.2 : 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundImage: const AssetImage(AppMedia.dp),
                                backgroundColor: isDark
                                    ? theme.colorScheme.surface.withOpacity(0.7)
                                    : theme.colorScheme.secondary
                                        .withOpacity(0.2),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      color: theme.hintColor,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Add refresh button
                            IconButton(
                              icon: _isRefreshing
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.refresh_rounded,
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.8),
                                    ),
                              onPressed: _isRefreshing ? null : _refreshData,
                              tooltip: 'Refresh data',
                            ),
                          ],
                        ),

                        // Stats Cards
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 18, bottom: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatCard(
                                    'Entries',
                                    stats['total_entries'].toString(),
                                    AppMedia.diary,
                                    isDark,
                                    theme,
                                  ),
                                  _buildStatCard(
                                    'Current',
                                    '${stats['current_streak']} days',
                                    AppMedia.fire,
                                    isDark,
                                    theme,
                                    isHighlighted: true,
                                  ),
                                  _buildStatCard(
                                    'Longest',
                                    '${stats['longest_streak']} days',
                                    AppMedia.trophy,
                                    isDark,
                                    theme,
                                  ),
                                ],
                              ),
                            ),

                            // Show loading indicator overlay during refresh
                            if (profileProvider.isLoading &&
                                profileProvider.hasData)
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, String animationPath,
      bool isDark, ThemeData theme,
      {bool isHighlighted = false}) {
    final Color bgColor = isDark
        ? (isHighlighted
            ? theme.colorScheme.primary.withOpacity(0.15)
            : theme.colorScheme.surface.withOpacity(0.7))
        : (isHighlighted
            ? theme.colorScheme.primary.withOpacity(0.05)
            : theme.cardColor);

    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary
                      .withOpacity(isDark ? 0.15 : 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: AnimationWidget(
              animationPath: animationPath,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
