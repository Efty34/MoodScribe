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
        backgroundColor: Colors.grey[100],
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 20),
                child: Text(
                  'Your Recommendations',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top: 5.0),
                child: const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(icon: Icon(Icons.music_note), text: 'Music'),
                    Tab(icon: Icon(Icons.movie), text: 'Movies'),
                    Tab(icon: Icon(Icons.book), text: 'Books'),
                    Tab(icon: Icon(Icons.fitness_center), text: 'Exercise'),
                  ],
                ),
              ),
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
