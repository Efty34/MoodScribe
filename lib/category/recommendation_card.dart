import 'package:diary/services/favorites_service.dart';
import 'package:diary/utils/app_snackbar.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(51)
                : Colors.black.withAlpha(12),
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
                              color: theme.colorScheme.onSurface,
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
                          children: _buildGenreTags(isDark),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(),
                            size: 16,
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.category.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withAlpha(153),
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
                      child: widget.category == 'exercise'
                          ? Container(
                              height: 140,
                              width: 100,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.orange.withAlpha(51)
                                    : Colors.orange[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fitness_center_rounded,
                                    size: 40,
                                    color: isDark
                                        ? Colors.orange[300]
                                        : Colors.orange[700],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.orange.withAlpha(76)
                                          : Colors.orange[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      (widget.genres as Map?)?['type']
                                              ?.toString() ??
                                          'Exercise',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.orange[100]
                                            : Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ClipRRect(
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
                                      color: isDark
                                          ? theme.colorScheme.surface
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      size: 32,
                                      color: isDark
                                          ? theme.colorScheme.onSurface
                                              .withAlpha(76)
                                          : Colors.grey[400],
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
                              color: isDark
                                  ? Colors.black.withAlpha(127)
                                  : Colors.black.withAlpha(76),
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

  List<Widget> _buildGenreTags(bool isDark) {
    List<dynamic> genres = [];
    if (widget.category == 'movies') {
      genres = (widget.genres)?.map((g) => g['name']).toList() ?? [];
    } else if (widget.category == 'books') {
      genres = widget.genres ?? [];
    } else if (widget.category == 'exercise') {
      final Map<dynamic, dynamic>? exerciseData = widget.genres as Map?;
      genres = [
        exerciseData?['type']?.toString() ?? 'Exercise',
        exerciseData?['intensity']?.toString() ?? 'Medium'
      ];
    }

    return genres
        .take(2)
        .map((genre) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getGenreColor(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                genre.toString().toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _getGenreTextColor(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ))
        .toList();
  }

  Color _getGenreColor(bool isDark) {
    switch (widget.category) {
      case 'movies':
        return isDark ? Colors.indigo[900]! : Colors.indigo[50]!;
      case 'books':
        return isDark ? Colors.teal[900]! : Colors.teal[50]!;
      case 'music':
        return isDark ? Colors.purple[900]! : Colors.purple[50]!;
      case 'exercise':
        return isDark ? Colors.orange[900]! : Colors.orange[50]!;
      default:
        return isDark ? Colors.grey[900]! : Colors.grey[50]!;
    }
  }

  Color _getGenreTextColor(bool isDark) {
    switch (widget.category) {
      case 'movies':
        return isDark ? Colors.indigo[100]! : Colors.indigo[700]!;
      case 'books':
        return isDark ? Colors.teal[100]! : Colors.teal[700]!;
      case 'music':
        return isDark ? Colors.purple[100]! : Colors.purple[700]!;
      case 'exercise':
        return isDark ? Colors.orange[100]! : Colors.orange[700]!;
      default:
        return isDark ? Colors.grey[100]! : Colors.grey[700]!;
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
      case 'exercise':
        return Icons.fitness_center_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        if (widget.favoriteId != null) {
          await _favoritesService.removeFromFavorites(widget.favoriteId!);
          AppSnackBar.show(
            context: context,
            message: 'Removed from favorites',
            type: SnackBarType.success,
            customIcon: Icons.favorite_border_rounded,
          );
        }
      } else {
        await _favoritesService.addToFavorites(
          title: widget.title,
          subtitle: '', // Empty for now
          imageUrl: widget.imageUrl,
          category: widget.category,
          genres: widget.genres,
        );
        AppSnackBar.show(
          context: context,
          message: 'Added to favorites',
          type: SnackBarType.success,
          customIcon: Icons.favorite_rounded,
        );
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      AppSnackBar.show(
        context: context,
        message: 'Failed to update favorites',
        type: SnackBarType.error,
      );
    }
  }
}
