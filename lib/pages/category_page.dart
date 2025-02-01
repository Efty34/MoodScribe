import 'package:diary/category/recommendation_grid.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
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
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.blue, width: 1),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey[400],
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.blue,
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
