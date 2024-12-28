import 'package:diary/category/recommendation_card.dart';
import 'package:flutter/material.dart';

class RecommendationGrid extends StatelessWidget {
  final String type;

  const RecommendationGrid({required this.type});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return RecommendationCard(
          title: 'Title $index',
          subtitle: 'Subtitle description for $type item $index',
          imageUrl: 'https://tinyurl.com/28122412',
          onTap: () {
            // Handle item tap
          },
        );
      },
      itemCount: 10, // Replace with actual data length
    );
  }
}
