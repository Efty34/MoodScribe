import 'package:cloud_firestore/cloud_firestore.dart';
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
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final DiaryService _diaryService = DiaryService();
  final UserService _userService = UserService();

  bool isLoading = true;
  int totalEntries = 0;
  int currentStreak = 0;
  int longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userService.getUserProfile(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final username = userData?['username'] ?? 'User';
        final email = userData?['email'] ?? 'No email';

        return StreamBuilder<QuerySnapshot>(
          stream: _diaryService.getEntries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              _loadStats();
            }

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: const AssetImage(AppMedia.dp),
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                email,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Entries', totalEntries.toString()),
                          _buildDivider(),
                          _buildStatItem(
                              'Current Streak', '$currentStreak days'),
                          _buildDivider(),
                          _buildStatItem(
                              'Longest Streak', '$longestStreak days'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.blue[700],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Future<void> _loadStats() async {
    try {
      final streakInfo = await _diaryService.getStreakInfo();

      setState(() {
        totalEntries = streakInfo['total'] ?? 0;
        currentStreak = streakInfo['current'] ?? 0;
        longestStreak = streakInfo['longest'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
}
