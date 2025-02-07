import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/category/recommendation_card.dart';
import 'package:diary/components/build_profile_section.dart';
import 'package:diary/components/diary_streak_calendar.dart';
import 'package:diary/components/mood_chart.dart';
import 'package:diary/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _FavoritesSection extends StatelessWidget {
  final List<QueryDocumentSnapshot> favorites;

  const _FavoritesSection({required this.favorites});

  @override
  Widget build(BuildContext context) {
    final movieFavorites = favorites
        .where((f) => (f.data() as Map)['category'] == 'movies')
        .toList();
    final bookFavorites = favorites
        .where((f) => (f.data() as Map)['category'] == 'books')
        .toList();
    final musicFavorites = favorites
        .where((f) => (f.data() as Map)['category'] == 'music')
        .toList();

    return Column(
      children: [
        if (musicFavorites.isNotEmpty)
          _buildExpandableSection(
            title: 'Music',
            icon: Icons.music_note_outlined,
            color: Colors.purple,
            items: musicFavorites,
            itemCount: musicFavorites.length,
          ),
        if (movieFavorites.isNotEmpty)
          _buildExpandableSection(
            title: 'Movies',
            icon: Icons.movie_outlined,
            color: Colors.indigo,
            items: movieFavorites,
            itemCount: movieFavorites.length,
          ),
        if (bookFavorites.isNotEmpty)
          _buildExpandableSection(
            title: 'Books',
            icon: Icons.book_outlined,
            color: Colors.teal,
            items: bookFavorites,
            itemCount: bookFavorites.length,
          ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required MaterialColor color,
    required List<QueryDocumentSnapshot> items,
    required int itemCount,
  }) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final favorite = items[index].data() as Map<String, dynamic>;
            return RecommendationCard(
              title: favorite['title'],
              imageUrl: favorite['imageUrl'],
              category: favorite['category'],
              isFavorite: true,
              favoriteId: items[index].id,
              genres: favorite['genres'] ?? favorite['categories'],
            );
          },
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section with enhanced shadow and margin
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const BuildProfileSection(),
              ),

              const SizedBox(height: 24),

              // Statistics Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.blue[400]!, Colors.blue[700]!],
                        ),
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
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Charts Section with enhanced scrolling
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildChartContainer(
                      context,
                      const MoodChart(),
                      Colors.blue[700]!,
                    ),
                    const SizedBox(width: 16),
                    _buildChartContainer(
                      context,
                      const DiaryStreakCalendar(),
                      Colors.green[700]!,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Favorites Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.red[400]!, Colors.red[700]!],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'My Collection',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              StreamBuilder<QuerySnapshot>(
                stream: FavoritesService().getFavorites(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  final favorites = snapshot.data?.docs ?? [];

                  if (favorites.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _FavoritesSection(favorites: favorites);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer(
      BuildContext context, Widget child, Color shadowColor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Explore recommendations and add them to your collection!',
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
