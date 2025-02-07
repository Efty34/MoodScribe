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

  const RecommendationCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.category,
    this.onTap,
    this.isFavorite = false,
    this.favoriteId,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'image_${widget.title}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        widget.imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            color: Colors.grey[100],
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
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleFavorite,
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite ? Colors.red : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Hero(
                  tag: 'title_${widget.title}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
