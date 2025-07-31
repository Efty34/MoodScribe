import 'dart:convert';

import 'package:diary/services/diary_service.dart';
import 'package:diary/services/favorites_service.dart';
import 'package:http/http.dart' as http;

class RecommendationService {
  static List<Map<String, dynamic>>? _cachedRecommendations;
  final DiaryService _diaryService = DiaryService();
  final FavoritesService _favoritesService = FavoritesService();
  final String baseUrl =
      'https://mood-scribe-recommendation-ai-agent.vercel.app/api/recommendations/combined';

  Future<Map<String, dynamic>> _prepareRecommendationData() async {
    // Get stress percentage from diary entries
    final diaryStats = await _diaryService.getDiaryStatistics();
    final moodCounts = diaryStats['mood_counts'] as Map<String, dynamic>;

    final int totalEntries = diaryStats['total_entries'];

    // Count stress entries handling both old and new format
    int stressCount = 0;
    moodCounts.forEach((mood, count) {
      final moodLower = mood.toLowerCase();
      if (moodLower.contains('stress') && !moodLower.contains('no stress')) {
        stressCount += count as int;
      }
    });

    final double stressPercentage =
        totalEntries > 0 ? (stressCount / totalEntries) * 100 : 0;

    // Get user's favorites
    final snapshot = await _favoritesService.getFavoritesOnce();
    final favorites = snapshot.docs;

    // Group favorites by category
    final Map<String, List<String>> pastLikings = {
      'favoriteMovies': [],
      'favoriteBooks': [],
      'favoriteSongs': [],
    };

    for (var favorite in favorites) {
      final data = favorite.data() as Map<String, dynamic>;
      final title = data['title'] as String;

      switch (data['category']) {
        case 'movies':
          pastLikings['favoriteMovies']!.add(title);
          break;
        case 'books':
          pastLikings['favoriteBooks']!.add(title);
          break;
        case 'music':
          pastLikings['favoriteSongs']!.add(title);
          break;
      }
    }

    // Remove empty categories
    pastLikings.removeWhere((key, value) => value.isEmpty);

    // Prepare the final request payload
    return {
      'stressEntryPercentage': stressPercentage.round(),
      if (pastLikings.isNotEmpty) 'pastLikings': pastLikings,
    };
  }

  Future<List<Map<String, dynamic>>> getRecommendations(
      {bool refresh = false}) async {
    // Return cached data if available and refresh not requested
    if (!refresh && _cachedRecommendations != null) {
      return _cachedRecommendations!;
    }

    try {
      final requestData = await _prepareRecommendationData();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<Map<String, dynamic>> formattedData = [];

        // Format movies with all details
        for (var movie in responseData['movies'] ?? []) {
          formattedData.add({
            'title': movie['title'],
            'imageUrl': movie['posterPath'],
            'category': 'movies',
            'overview': movie['overview'],
            'releaseDate': movie['releaseDate'],
            'voteAverage': movie['voteAverage'],
            'director': movie['director'],
            'cast': movie['cast'],
            'genres': movie['genres'],
            'runtime': movie['runtime'],
          });
        }

        // Format books with all details
        for (var book in responseData['books'] ?? []) {
          formattedData.add({
            'title': book['title'],
            'imageUrl': book['imageLinks']?['thumbnail'] ?? '',
            'category': 'books',
            'authors': book['authors'],
            'description': book['description'],
            'pageCount': book['pageCount'],
            'categories': book['categories'],
            'publishedDate': book['publishedDate'],
            'averageRating': book['averageRating'],
            'previewLink': book['previewLink'],
          });
        }

        // Format songs with all details
        for (var song in responseData['songs'] ?? []) {
          formattedData.add({
            'title': song['title'],
            'imageUrl': song['albumArt'],
            'category': 'music',
            'artist': song['artist'],
            'album': song['album'],
            'releaseDate': song['releaseDate'],
            'duration': song['duration'],
            'spotifyUrl': song['spotifyUrl'],
            'popularity': song['popularity'],
          });
        }

        // Format exercises with all details
        for (var exercise in responseData['exercises'] ?? []) {
          formattedData.add({
            'title': exercise['name'],
            'category': 'exercise',
            'type': exercise['type'],
            'duration': exercise['duration'],
            'intensity': exercise['intensity'],
            'description': exercise['description'],
            'benefits': exercise['benefits'],
            'equipment': exercise['equipment'],
            'instructions': exercise['instructions'],
            'caloriesBurnedPerHour': exercise['caloriesBurnedPerHour'],
            'suitable': exercise['suitable'],
            'location': exercise['location'],
          });
        }

        // Cache the formatted data
        _cachedRecommendations = formattedData;
        return formattedData;
      } else {
        throw Exception(
            'Failed to get recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recommendations: $e');
    }
  }
}
