import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationDetailPage extends StatelessWidget {
  final Map<String, dynamic> recommendation;

  const RecommendationDetailPage({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'image_${recommendation['title']}',
                    child: recommendation['category'] == 'exercise'
                        ? Container(
                            height: 300,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.orange[300]!,
                                  Colors.orange[700]!,
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center_rounded,
                                  size: 80,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    recommendation['type'] ?? 'Exercise',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Image.network(
                            recommendation['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -60),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'title_${recommendation['title']}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            recommendation['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (recommendation['overview'] != null ||
                          recommendation['description'] != null) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recommendation['overview'] ??
                                recommendation['description'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      _buildCategorySpecificDetails(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySpecificDetails() {
    switch (recommendation['category']) {
      case 'movies':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Movie Details',
              content: Column(
                children: [
                  _buildDetailRow('Director', recommendation['director']),
                  _buildDetailRow(
                      'Release Date', recommendation['releaseDate']),
                  _buildDetailRow(
                      'Rating', '${recommendation['voteAverage']}/10'),
                  _buildDetailRow(
                      'Runtime', '${recommendation['runtime']} minutes'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (recommendation['genres'] != null)
              _buildInfoCard(
                title: 'Genres',
                content: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (recommendation['genres'] as List)
                      .map((genre) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              genre['name'],
                              style: GoogleFonts.poppins(
                                color: Colors.indigo[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 20),
            if (recommendation['cast'] != null)
              _buildInfoCard(
                title: 'Cast',
                content: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (recommendation['cast'] as List)
                      .map((actor) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              actor,
                              style: GoogleFonts.poppins(
                                color: Colors.purple[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        );

      case 'books':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Book Details',
              content: Column(
                children: [
                  if (recommendation['authors'] != null)
                    _buildDetailRow('Author',
                        (recommendation['authors'] as List).join(', ')),
                  _buildDetailRow('Published', recommendation['publishedDate']),
                  _buildDetailRow('Pages',
                      recommendation['pageCount']?.toString() ?? 'Unknown'),
                  if (recommendation['averageRating'] != null)
                    _buildDetailRow(
                        'Rating', '${recommendation['averageRating']}/5 stars'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (recommendation['categories'] != null &&
                (recommendation['categories'] as List).isNotEmpty)
              _buildInfoCard(
                title: 'Genres',
                content: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (recommendation['categories'] as List)
                      .map((category) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                color: Colors.teal[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        );

      case 'music':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Track Details',
              content: Column(
                children: [
                  _buildDetailRow('Artist', recommendation['artist']),
                  _buildDetailRow('Album', recommendation['album']),
                  _buildDetailRow(
                      'Release Date', recommendation['releaseDate']),
                  _buildDetailRow(
                    'Duration',
                    _formatDuration(recommendation['duration']),
                  ),
                  if (recommendation['popularity'] != null)
                    _buildPopularityIndicator(recommendation['popularity']),
                ],
              ),
            ),
          ],
        );

      case 'exercise':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Exercise Details',
              content: Column(
                children: [
                  _buildDetailRow('Type', recommendation['type']),
                  _buildDetailRow(
                      'Duration', '${recommendation['duration']} minutes'),
                  _buildDetailRow(
                      'Intensity', recommendation['intensity'].toUpperCase()),
                  _buildDetailRow('Location', recommendation['location']),
                  _buildDetailRow('Calories/Hour',
                      '${recommendation['caloriesBurnedPerHour']} kcal'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              title: 'Benefits',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...(recommendation['benefits'] as List)
                      .map((benefit) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    size: 20, color: Colors.green[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              title: 'Instructions',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...(recommendation['instructions'] as List)
                      .asMap()
                      .entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
            if (recommendation['equipment'] != null &&
                (recommendation['equipment'] as List).isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildInfoCard(
                title: 'Equipment Needed',
                content: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (recommendation['equipment'] as List)
                      .map((item) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item,
                              style: GoogleFonts.poppins(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildPopularityIndicator(int popularity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Popularity',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: popularity / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              popularity > 70
                  ? Colors.green[400]!
                  : popularity > 40
                      ? Colors.orange[400]!
                      : Colors.red[400]!,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final minutes = (milliseconds / 60000).floor();
    final seconds = ((milliseconds % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
