import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';
import 'package:diary/services/diary_service.dart';
import 'package:diary/services/favorites_service.dart';
import 'package:http/http.dart' as http;

class RecommendationService {
  static List<Map<String, dynamic>>? _cachedRecommendations;
  final DiaryService _diaryService = DiaryService();
  final FavoritesService _favoritesService = FavoritesService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String baseUrl =
      'https://ai-agent-three-kappa.vercel.app/get-recommendations';

  Future<Map<String, int>> _getPredictedAspectCounts() async {
    try {
      final String? userId = AuthService().currentUser?.uid;
      if (userId == null) return {};

      // Get all diary entries using Firestore directly
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diary')
          .get();

      final Map<String, int> aspectCounts = {};

      for (var entry in snapshot.docs) {
        final data = entry.data() as Map<String, dynamic>;
        final predictedAspect = data['predictedAspect'] as String?;

        if (predictedAspect != null && predictedAspect.isNotEmpty) {
          aspectCounts[predictedAspect] =
              (aspectCounts[predictedAspect] ?? 0) + 1;
        }
      }

      return aspectCounts;
    } catch (e) {
      // Return empty map if there's an error
      return {};
    }
  }

  Future<Map<String, dynamic>> _prepareRecommendationData() async {
    try {
      // Get comprehensive diary statistics
      final diaryStats = await _diaryService.getDiaryStatistics();
      // print('Raw diary stats: $diaryStats');

      final moodCounts = diaryStats['mood_counts'] as Map<String, dynamic>;
      final int totalEntries = diaryStats['total_entries'];

      // print('Mood counts: $moodCounts');
      // print('Total entries: $totalEntries');

      // Count stress and no stress entries handling both old and new format
      int stressCount = 0;
      int noStressCount = 0;

      moodCounts.forEach((mood, count) {
        final moodLower = mood.toLowerCase();
        if (moodLower.contains('stress')) {
          if (moodLower.contains('no stress')) {
            noStressCount += count as int;
          } else {
            stressCount += count as int;
          }
        }
      });

      // Get predicted aspects count
      final aspectCounts = await _getPredictedAspectCounts();

      // Get user's favorites
      final snapshot = await _favoritesService.getFavoritesOnce();
      final favorites = snapshot.docs;

      // Group favorites by category - ensure exact key names match API expectation
      final Map<String, List<String>> pastLikings = {
        'favoriteMovies': <String>[],
        'favoriteBooks': <String>[],
        'favoriteSongs': <String>[],
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
      final payload = {
        'totalEntries': totalEntries,
        'totalStressEntries': stressCount,
        'totalNoStressEntries': noStressCount,
        'predictedAspectCounts': aspectCounts,
        if (pastLikings.isNotEmpty) 'pastLikings': pastLikings,
      };

      // Debug: Print data structure
      // print(
      //     'Diary Stats: totalEntries=$totalEntries, stress=$stressCount, noStress=$noStressCount');
      // print('Aspect Counts: $aspectCounts');
      // print('Past Likings: $pastLikings');

      return payload;
    } catch (e) {
      // print('Error preparing recommendation data: $e');
      // Return minimal data structure if there's an error
      return {
        'totalEntries': 0,
        'totalStressEntries': 0,
        'totalNoStressEntries': 0,
        'predictedAspectCounts': <String, int>{},
      };
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendations(
      {bool refresh = false}) async {
    // Return cached data if available and refresh not requested
    if (!refresh && _cachedRecommendations != null) {
      return _cachedRecommendations!;
    }

    try {
      final requestData = await _prepareRecommendationData();

      // Debug: Print the request data to see what's being sent
      // print('Sending to API: ${json.encode(requestData)}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      // print('API Response Status: ${response.statusCode}');
      // print('API Response Body: ${response.body}');

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
        // print('API Error Response: ${response.body}');
        throw Exception(
            'Failed to get recommendations: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // print('Recommendation Service Error: $e');
      throw Exception('Error getting recommendations: $e');
    }
  }
}
