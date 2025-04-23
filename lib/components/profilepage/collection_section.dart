import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/profilepage/expandable_category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectionSection extends StatelessWidget {
  final List<QueryDocumentSnapshot> favorites;

  const CollectionSection({
    Key? key,
    required this.favorites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group favorites by category
    final movieFavorites = favorites
        .where((f) => (f.data() as Map)['category'] == 'movies')
        .toList();
    final bookFavorites = favorites
        .where((f) => (f.data() as Map)['category'] == 'books')
        .toList();
    final musicFavorites = favorites
        .where((f) => (f.data() as Map)['category'] == 'music')
        .toList();
    final exerciseFavorites = favorites
        .where((f) => (f.data() as Map)['category'] == 'exercise')
        .toList();

    return Column(
      children: [
        // Section header
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

        // Categories
        if (musicFavorites.isNotEmpty)
          ExpandableCategory(
            title: 'Music',
            icon: Icons.music_note_outlined,
            color: Colors.purple,
            items: musicFavorites,
            itemCount: musicFavorites.length,
          ),
        if (movieFavorites.isNotEmpty)
          ExpandableCategory(
            title: 'Movies',
            icon: Icons.movie_outlined,
            color: Colors.indigo,
            items: movieFavorites,
            itemCount: movieFavorites.length,
          ),
        if (bookFavorites.isNotEmpty)
          ExpandableCategory(
            title: 'Books',
            icon: Icons.book_outlined,
            color: Colors.teal,
            items: bookFavorites,
            itemCount: bookFavorites.length,
          ),
        if (exerciseFavorites.isNotEmpty)
          ExpandableCategory(
            title: 'Exercise',
            icon: Icons.fitness_center_outlined,
            color: Colors.orange,
            items: exerciseFavorites,
            itemCount: exerciseFavorites.length,
          ),

        if (favorites.isEmpty) _buildEmptyState(),
      ],
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
}
