import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/animation_widget.dart';
import 'package:diary/services/diary_service.dart';
import 'package:diary/services/user_service.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildProfileSection extends StatefulWidget {
  const BuildProfileSection({super.key});

  @override
  State<BuildProfileSection> createState() => _BuildProfileSectionState();
}

class _BuildProfileSectionState extends State<BuildProfileSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final DiaryService _diaryService = DiaryService();
  final UserService _userService = UserService();

  bool isLoading = true;
  Map<String, dynamic> _stats = {
    'total_entries': 0,
    'current_streak': 0,
    'longest_streak': 0,
    'mood_counts': {},
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
    _loadStats();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      // Get diary statistics
      final diaryStats = await _diaryService.getDiaryStatistics();

      // Get streak information
      final streakInfo = await _diaryService.getStreakInfo();

      setState(() {
        _stats = {
          'total_entries': diaryStats['total_entries'] ?? 0,
          'current_streak': streakInfo['current'] ?? 0,
          'longest_streak': streakInfo['longest'] ?? 0,
          'mood_counts': diaryStats['mood_counts'] ?? {},
        };
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF2A2D3E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2E3A59);
    final subtleTextColor =
        isDarkMode ? Colors.white70 : const Color(0xFF8D97B5);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.15)
        : const Color(0xFF8E9FBF).withOpacity(0.08);
    final dividerColor = isDarkMode ? Colors.white24 : const Color(0xFFECEFF5);

    return StreamBuilder<DocumentSnapshot>(
      stream: _userService.getUserProfile(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final username = userData?['username'] ?? 'User';
        final email = userData?['email'] ?? 'No email';

        if (isLoading) {
          return Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: isDarkMode ? Colors.blue[300] : Colors.blue[400],
                strokeWidth: 3,
              ),
            ),
          );
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
              gradient: isDarkMode
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2A2D3E),
                        Color(0xFF343A50),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Color(0xFFF8FAFF),
                      ],
                    ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.blue[700]!
                              : Colors.blue[100]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage: const AssetImage(AppMedia.dp),
                        backgroundColor:
                            isDarkMode ? Colors.grey[700] : Colors.grey[200],
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
                              color: textColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            email,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: subtleTextColor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        'Entries',
                        _stats['total_entries'].toString(),
                        AppMedia.diary,
                        isDarkMode,
                      ),
                      _buildStatCard(
                        'Current',
                        '${_stats['current_streak']} days',
                        AppMedia.fire,
                        isDarkMode,
                        isHighlighted: true,
                      ),
                      _buildStatCard(
                        'Longest',
                        '${_stats['longest_streak']} days',
                        AppMedia.trophy,
                        isDarkMode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String label, String value, String animationPath, bool isDarkMode,
      {bool isHighlighted = false}) {
    final Color bgColor = isDarkMode
        ? (isHighlighted ? const Color(0xFF394263) : const Color(0xFF343A50))
        : (isHighlighted ? const Color(0xFFF0F5FF) : Colors.white);

    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.15)
                      : Colors.blue.withOpacity(0.08),
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
              color: isDarkMode ? Colors.white : const Color(0xFF2E3A59),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: isDarkMode ? Colors.white60 : const Color(0xFF8D97B5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
