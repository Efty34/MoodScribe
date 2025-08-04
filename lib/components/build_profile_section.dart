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
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Refresh Button Top-Right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
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
                                            .withAlpha(204),
                                      ),
                                onPressed: _isRefreshing ? null : _refreshData,
                                tooltip: 'Refresh data',
                              ),
                            ],
                          ),
                          // Avatar
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: const AssetImage(AppMedia.dp),
                            backgroundColor: isDark
                                ? theme.colorScheme.surface.withAlpha(178)
                                : theme.colorScheme.secondary.withAlpha(51),
                          ),
                          const SizedBox(height: 12),
                          // Username
                          Text(
                            username,
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Email
                          Text(
                            email,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        ],
                      ),
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
            ? theme.colorScheme.primary.withAlpha(38)
            : theme.colorScheme.surface.withAlpha(178))
        : (isHighlighted
            ? theme.colorScheme.primary.withAlpha(12)
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
                  color: theme.colorScheme.primary.withAlpha(isDark ? 38 : 20),
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
