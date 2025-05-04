import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/animation_widget.dart';
import 'package:diary/components/profilepage/favorite_item_card.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCollectionSection extends StatelessWidget {
  final Stream<QuerySnapshot>? favoritesStream;
  final List<QueryDocumentSnapshot>? collections;

  const CategoryCollectionSection({
    super.key,
    this.collections,
    this.favoritesStream,
  }) : assert(collections != null || favoritesStream != null,
            'Either collections or favoritesStream must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If using stream, build with StreamBuilder
    if (favoritesStream != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: favoritesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              collections == null) {
            return _buildLoadingState(theme);
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString(), theme);
          }

          final docs = snapshot.data?.docs ?? collections ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState(theme);
          }

          return _buildContent(context, theme, docs);
        },
      );
    }

    // If using static collections
    return _buildContent(context, theme, collections ?? []);
  }

  Widget _buildContent(BuildContext context, ThemeData theme,
      List<QueryDocumentSnapshot> items) {
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
                    colors: [Colors.purple[300]!, Colors.purple[600]!],
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
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Collection content
        items.isEmpty
            ? _buildEmptyState(theme)
            : _buildCategorizedCollections(context, items),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
                'Add items to your favorites to see them here',
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

  Widget _buildCategorizedCollections(
      BuildContext context, List<QueryDocumentSnapshot> items) {
    // final theme = Theme.of(context);

    // Group items by their actual category from the data
    Map<String, List<QueryDocumentSnapshot>> categorizedItems = {};

    // Process each item and group by its actual category
    for (final item in items) {
      final data = item.data() as Map<String, dynamic>;
      final category = data['category'] as String? ?? 'Other';

      // Capitalize category name (convert "movies" to "Movies")
      final capitalizedCategory = _capitalizeCategory(category);

      if (!categorizedItems.containsKey(capitalizedCategory)) {
        categorizedItems[capitalizedCategory] = [];
      }

      categorizedItems[capitalizedCategory]!.add(item);
    }

    // Sort categories alphabetically for consistent display
    final categories = categorizedItems.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final category in categories)
          _buildCategorySection(context, category, categorizedItems[category]!)
      ],
    );
  }

  // Helper method to capitalize category name
  String _capitalizeCategory(String category) {
    if (category.isEmpty) return 'Other';
    return category[0].toUpperCase() + category.substring(1);
  }

  Widget _buildCategorySection(BuildContext context, String category,
      List<QueryDocumentSnapshot> items) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),

          // Horizontal scrolling items list
          SizedBox(
            height: 200, // Increased height for better display
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final itemData = item.data() as Map<String, dynamic>;

                return Container(
                  width: 180, // Increased width for better content display
                  margin: const EdgeInsets.only(right: 12),
                  child: FavoriteItemCard(
                    favoriteId: item.id,
                    favoriteData: itemData,
                    onTap: () {
                      // Handle favorite item tap if needed
                    },
                    onRemoved: () {
                      // This callback will be triggered after successful removal
                      // We can add any UI refresh logic here if needed
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Map specific categories to fixed colors for consistency
    final Map<String, Color> categoryColors = {
      'Books': Colors.blue,
      'Movies': Colors.red,
      'Songs': Colors.green,
      'Exercises': Colors.orange,
      'TV Shows': Colors.amber,
      'Games': Colors.indigo,
      'Podcasts': Colors.teal,
      'Recipes': Colors.pink,
    };

    // Return the mapped color or generate one based on the string hash
    if (categoryColors.containsKey(category)) {
      return categoryColors[category]!;
    } else {
      // Generate a consistent color based on the category name's hash code
      final int hash = category.hashCode;
      final hue = (hash % 360).abs().toDouble();
      return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
    }
  }
}
