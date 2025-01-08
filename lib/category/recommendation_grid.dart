import 'package:diary/category/recommendation_card.dart';
import 'package:flutter/material.dart';

class RecommendationGrid extends StatelessWidget {
  final String type;

  const RecommendationGrid({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return RecommendationCard(
          title: 'Title $index',
          subtitle: 'Subtitle description for $type item $index',
          imageUrl: 'https://picsum.photos/200/300?random=$index',
          onTap: () {
            // Handle item tap
          },
        );
      },
      itemCount: 10,
    );
  }
}
