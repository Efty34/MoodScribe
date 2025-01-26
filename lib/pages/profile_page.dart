import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/category/recommendation_card.dart';
import 'package:diary/components/build_profile_section.dart';
import 'package:diary/components/diary_streak_calendar.dart';
import 'package:diary/components/mood_chart.dart';
import 'package:diary/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: BuildProfileSection(),
              ),

              const SizedBox(height: 24),

              // Statistics Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Statistics',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Charts Section
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const MoodChart(),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const DiaryStreakCalendar(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Favorites Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Favorites',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Favorites List
              SizedBox(
                height: 220,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FavoritesService().getFavorites(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final favorites = snapshot.data?.docs ?? [];

                    if (favorites.isEmpty) {
                      return Center(
                        child: Text(
                          'No favorites yet',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final favorite =
                            favorites[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: SizedBox(
                            width: 160,
                            child: RecommendationCard(
                              title: favorite['title'],
                              subtitle: favorite['subtitle'],
                              imageUrl: favorite['imageUrl'],
                              category: favorite['category'],
                              isFavorite: true,
                              favoriteId: favorites[index].id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
