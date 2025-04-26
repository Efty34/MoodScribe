import 'package:diary/category/recommendation_grid.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Discover',
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 28,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.grey[800],
                    //   ),
                    // ),
                    const SizedBox(height: 8),
                    Text(
                      'Find what suits your mood',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black12 : Colors.grey.shade200,
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withOpacity(0.5),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: theme.colorScheme.primary,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.music_note_rounded),
                      text: 'Music',
                    ),
                    Tab(
                      icon: Icon(Icons.movie_creation_rounded),
                      text: 'Movies',
                    ),
                    Tab(
                      icon: Icon(Icons.auto_stories_rounded),
                      text: 'Books',
                    ),
                    Tab(
                      icon: Icon(Icons.self_improvement_rounded),
                      text: 'Exercise',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Expanded(
                child: TabBarView(
                  children: [
                    RecommendationGrid(type: 'music'),
                    RecommendationGrid(type: 'movies'),
                    RecommendationGrid(type: 'books'),
                    RecommendationGrid(type: 'exercise'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
