import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/animation_widget.dart';
import 'package:diary/components/diary_entry_card.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectionSection extends StatelessWidget {
  final List<QueryDocumentSnapshot> favorites;

  const CollectionSection({
    super.key,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    colors: [Colors.pink[300]!, Colors.pink[600]!],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Favorites',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Collection content
        favorites.isEmpty
            ? _buildEmptyState(theme)
            : _buildCollectionGrid(favorites, isDark),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: AnimationWidget(
                animationPath: AppMedia.notfound,
                repeat: true,
                animate: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: GoogleFonts.poppins(
                color: theme.hintColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 280,
              child: Text(
                'Add entries to your favorites to see them here',
                style: GoogleFonts.poppins(
                  color: theme.hintColor.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionGrid(
      List<QueryDocumentSnapshot> favorites, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final entryData = favorites[index].data() as Map<String, dynamic>;
          final entryId = favorites[index].id;

          return DiaryEntryCard(
            entryId: entryId,
            entryData: entryData,
            isFavorited: true,
          );
        },
      ),
    );
  }
}
