import 'package:diary/services/favorites_service.dart';
import 'package:diary/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String category;
  final VoidCallback? onTap;
  final bool isFavorite;
  final String? favoriteId;
  final List? genres;

  const RecommendationCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.category,
    this.onTap,
    this.isFavorite = false,
    this.favoriteId,
    this.genres,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'title_${widget.title}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            widget.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.genres != null && widget.genres!.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _buildGenreTags(),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(),
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.category.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Stack(
                  children: [
                    Hero(
                      tag: 'image_${widget.title}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.imageUrl,
                          height: 140,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 140,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _toggleFavorite,
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _isFavorite ? Colors.red : Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGenreTags() {
    List<dynamic> genres = [];
    if (widget.category == 'movies') {
      genres = (widget.genres as List).map((g) => g['name']).toList();
    } else if (widget.category == 'books') {
      genres = widget.genres as List;
    }

    return genres
        .take(2)
        .map((genre) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getGenreColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                genre.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _getGenreTextColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ))
        .toList();
  }

  Color _getGenreColor() {
    switch (widget.category) {
      case 'movies':
        return Colors.indigo[50]!;
      case 'books':
        return Colors.teal[50]!;
      case 'music':
        return Colors.purple[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getGenreTextColor() {
    switch (widget.category) {
      case 'movies':
        return Colors.indigo[700]!;
      case 'books':
        return Colors.teal[700]!;
      case 'music':
        return Colors.purple[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case 'movies':
        return Icons.movie_outlined;
      case 'books':
        return Icons.book_outlined;
      case 'music':
        return Icons.music_note_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        if (widget.favoriteId != null) {
          await _favoritesService.removeFromFavorites(widget.favoriteId!);
          showCustomSnackbar(
            context,
            message: 'Removed from favorites',
            isAdded: false,
          );
        }
      } else {
        await _favoritesService.addToFavorites(
          title: widget.title,
          subtitle: '', // Empty for now
          imageUrl: widget.imageUrl,
          category: widget.category,
        );
        showCustomSnackbar(
          context,
          message: 'Added to favorites',
          isAdded: true,
        );
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      showCustomSnackbar(
        context,
        message: 'Failed to update favorites',
        isAdded: false,
      );
    }
  }
}
