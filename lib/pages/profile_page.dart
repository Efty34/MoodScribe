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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (musicFavorites.isNotEmpty) ...[
          _buildCategoryHeader(
              'Music', Icons.music_note_outlined, Colors.purple),
          _buildFavoritesList(musicFavorites),
          const SizedBox(height: 24),
        ],
        if (movieFavorites.isNotEmpty) ...[
          _buildCategoryHeader('Movies', Icons.movie_outlined, Colors.indigo),
          _buildFavoritesList(movieFavorites),
          const SizedBox(height: 24),
        ],
        if (bookFavorites.isNotEmpty) ...[
          _buildCategoryHeader('Books', Icons.book_outlined, Colors.teal),
          _buildFavoritesList(bookFavorites),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(
      String title, IconData icon, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
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
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<QueryDocumentSnapshot> categoryFavorites) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categoryFavorites.length,
        itemBuilder: (context, index) {
          final favorite =
              categoryFavorites[index].data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 160,
              child: RecommendationCard(
                title: favorite['title'],
                imageUrl: favorite['imageUrl'],
                category: favorite['category'],
                isFavorite: true,
                favoriteId: categoryFavorites[index].id,
              ),
            ),
          );
        },
      ),
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
