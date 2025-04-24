import 'package:diary/category/recommendation_card.dart';
import 'package:diary/category/recommendation_detail_page.dart';
import 'package:diary/services/recommendation_service.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class RecommendationGrid extends StatefulWidget {
  final String type;

  const RecommendationGrid({super.key, required this.type});

  @override
  State<RecommendationGrid> createState() => _RecommendationGridState();
}

class _RecommendationGridState extends State<RecommendationGrid> {
  final RecommendationService _recommendationService = RecommendationService();
  late Future<List<Map<String, dynamic>>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _recommendationService.getRecommendations();
  }

  Future<void> _refreshRecommendations() async {
    setState(() {
      _recommendationsFuture =
          _recommendationService.getRecommendations(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _refreshRecommendations,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recommendationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    AppMedia.loading,
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Finding the best recommendations for you...',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading recommendations',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final recommendations = snapshot.data!
              .where((item) => item['category'] == widget.type)
              .toList();

          if (recommendations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    AppMedia.empty,
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recommendations found',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final item = recommendations[index];
              return RecommendationCard(
                title: item['title'],
                imageUrl: item['imageUrl'] ?? '',
                category: widget.type,
                genres: widget.type == 'movies'
                    ? item['genres']
                    : widget.type == 'books'
                        ? item['categories']
                        : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendationDetailPage(
                        recommendation: item,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
