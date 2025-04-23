import 'package:diary/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Extension to add capitalize functionality to String
extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}

class HorizontalItemCard extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final String itemId;
  final MaterialColor color;

  const HorizontalItemCard({
    Key? key,
    required this.itemData,
    required this.itemId,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image container with proper aspect ratio and rounded corners
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: _buildImage(),
            ),
          ),

          // Card content container
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryBadge(),
                _buildTitle(),
                _buildGenres(),
                const SizedBox(height: 8),
                _buildRemoveButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          itemData['imageUrl'] ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: color[50],
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: color[200],
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: color[50],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: color[300],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        itemData['category']?.toString().capitalize() ?? '',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color[700],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      itemData['title'] ?? 'Untitled',
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildGenres() {
    // Handle genres
    if (itemData['genres'] != null) {
      return _buildGenresList(itemData['genres']);
    }
    // Handle categories
    else if (itemData['categories'] != null) {
      return _buildGenresList(itemData['categories']);
    }
    return const SizedBox.shrink();
  }

  Widget _buildGenresList(dynamic genresData) {
    if (genresData is! List || genresData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: SizedBox(
        height: 26,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: genresData.length,
          separatorBuilder: (context, index) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final genre = genresData[index];
            final genreName =
                genre is Map ? genre['name'] ?? '' : genre.toString();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                genreName,
                style: GoogleFonts.poppins(
                  color: color[700],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: () {
        FavoritesService().removeFromFavorites(itemId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.red[100]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.red[400],
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              'Remove',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.red[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
