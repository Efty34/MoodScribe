import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/services/favorites_service.dart';
import 'package:diary/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FavoriteItemCard extends StatelessWidget {
  final String favoriteId;
  final Map<String, dynamic> favoriteData;
  final VoidCallback? onTap;
  final VoidCallback? onRemoved;

  const FavoriteItemCard({
    super.key,
    required this.favoriteId,
    required this.favoriteData,
    this.onTap,
    this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Extract data from the favorite item
    final String title = favoriteData['title'] ?? 'Untitled';
    final String subtitle = favoriteData['subtitle'] ?? '';
    final String imageUrl = favoriteData['imageUrl'] ?? '';

    // Format timestamp if it exists
    String formattedDate = '';
    if (favoriteData['timestamp'] != null) {
      final timestamp = favoriteData['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      formattedDate = DateFormat('MMM dd, yyyy').format(date);
    }

    return Card(
      color: isDark ? theme.colorScheme.surface : Colors.white,
      elevation: 0.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with aspect ratio to show full image
            if (imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Content area with minimalist design
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Subtitle if any
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Date with minimal favorite icon beside it
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (formattedDate.isNotEmpty)
                        Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: theme.hintColor,
                          ),
                        ),
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          // Show confirmation dialog
                          final bool confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Remove Favorite',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to remove "$title" from your favorites?',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;

                          if (confirm) {
                            try {
                              // Use FavoritesService to remove the favorite
                              await FavoritesService()
                                  .removeFromFavorites(favoriteId);

                              // Call onRemoved callback if provided
                              if (onRemoved != null) {
                                onRemoved!();
                              }

                              // Show success snackbar
                              if (context.mounted) {
                                AppSnackBar.show(
                                  context: context,
                                  message: 'Removed from favorites',
                                  type: SnackBarType.success,
                                  customIcon: Icons.favorite_outline,
                                );
                              }
                            } catch (e) {
                              // Show error snackbar
                              if (context.mounted) {
                                AppSnackBar.show(
                                  context: context,
                                  message: 'Failed to remove: $e',
                                  type: SnackBarType.error,
                                );
                              }
                            }
                          }
                        },
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.red[400],
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
