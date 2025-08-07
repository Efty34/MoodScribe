import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/auth_service.dart';
import 'package:diary/services/diary_service.dart';
import 'package:diary/services/favorites_service.dart';
import 'package:http/http.dart' as http;

class SuggestionService {
  static const String _baseUrl =
      'https://moodscribe-ai-agent.onrender.com/health-suggestions';

  final DiaryService _diaryService = DiaryService();
  final FavoritesService _favoritesService = FavoritesService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<SuggestionResponse> getSuggestions() async {
    try {
      final requestData = await _prepareRecommendationData();
      // Try POST method with required body
      http.Response response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers like authorization
        },
        body: json.encode(requestData),
      );

      // If POST fails with 405, try GET
      if (response.statusCode == 405) {
        print('POST failed with 405, trying GET...');
        response = await http.get(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }

      if (response.statusCode == 200) {
        print('API Response received successfully');
        final Map<String, dynamic> data = json.decode(response.body);
        return SuggestionResponse.fromJson(data);
      } else {
        print('API Error - Status: ${response.statusCode}');
        print('API Error - Body: ${response.body}');
        throw Exception(
            'Failed to load suggestions: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      rethrow;
    }
  }
}

class SuggestionResponse {
  final double userStressPercentage;
  final AnalysisSummary analysisSummary;
  final MentalHealthAnalysis mentalHealthAnalysis;
  final SuggestionsData suggestions;
  final List<String> emergencyResources;
  final String disclaimer;

  SuggestionResponse({
    required this.userStressPercentage,
    required this.analysisSummary,
    required this.mentalHealthAnalysis,
    required this.suggestions,
    required this.emergencyResources,
    required this.disclaimer,
  });

  factory SuggestionResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionResponse(
      userStressPercentage: json['user_stress_percentage']?.toDouble() ?? 0.0,
      analysisSummary: AnalysisSummary.fromJson(json['analysis_summary'] ?? {}),
      mentalHealthAnalysis:
          MentalHealthAnalysis.fromJson(json['mental_health_analysis'] ?? {}),
      suggestions: SuggestionsData.fromJson(json['suggestions'] ?? {}),
      emergencyResources: List<String>.from(json['emergency_resources'] ?? []),
      disclaimer: json['disclaimer'] ?? '',
    );
  }
}

class AnalysisSummary {
  final int totalEntriesAnalyzed;
  final int stressEntries;
  final int nonStressEntries;
  final List<String> mainStressSources;

  AnalysisSummary({
    required this.totalEntriesAnalyzed,
    required this.stressEntries,
    required this.nonStressEntries,
    required this.mainStressSources,
  });

  factory AnalysisSummary.fromJson(Map<String, dynamic> json) {
    return AnalysisSummary(
      totalEntriesAnalyzed: json['total_entries_analyzed'] ?? 0,
      stressEntries: json['stress_entries'] ?? 0,
      nonStressEntries: json['non_stress_entries'] ?? 0,
      mainStressSources: List<String>.from(json['main_stress_sources'] ?? []),
    );
  }
}

class MentalHealthAnalysis {
  final String stressLevelAssessment;
  final List<String> keyStressAreas;
  final String mentalStateSummary;
  final List<String> riskFactors;
  final List<String> positiveIndicators;

  MentalHealthAnalysis({
    required this.stressLevelAssessment,
    required this.keyStressAreas,
    required this.mentalStateSummary,
    required this.riskFactors,
    required this.positiveIndicators,
  });

  factory MentalHealthAnalysis.fromJson(Map<String, dynamic> json) {
    return MentalHealthAnalysis(
      stressLevelAssessment: json['stress_level_assessment'] ?? '',
      keyStressAreas: List<String>.from(json['key_stress_areas'] ?? []),
      mentalStateSummary: json['mental_state_summary'] ?? '',
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
      positiveIndicators: List<String>.from(json['positive_indicators'] ?? []),
    );
  }
}

class SuggestionsData {
  final List<SuggestionItem> immediateActions;
  final List<SuggestionItem> shortTermGoals;
  final List<SuggestionItem> longTermChanges;

  SuggestionsData({
    required this.immediateActions,
    required this.shortTermGoals,
    required this.longTermChanges,
  });

  factory SuggestionsData.fromJson(Map<String, dynamic> json) {
    return SuggestionsData(
      immediateActions: (json['immediate_actions'] as List? ?? [])
          .map((item) => SuggestionItem.fromJson(item))
          .toList(),
      shortTermGoals: (json['short_term_goals'] as List? ?? [])
          .map((item) => SuggestionItem.fromJson(item))
          .toList(),
      longTermChanges: (json['long_term_changes'] as List? ?? [])
          .map((item) => SuggestionItem.fromJson(item))
          .toList(),
    );
  }
}

class SuggestionItem {
  final String category;
  final String title;
  final String description;
  final String priority;
  final String timeframe;
  final String difficulty;
  final List<String> benefits;

  SuggestionItem({
    required this.category,
    required this.title,
    required this.description,
    required this.priority,
    required this.timeframe,
    required this.difficulty,
    required this.benefits,
  });

  factory SuggestionItem.fromJson(Map<String, dynamic> json) {
    return SuggestionItem(
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      timeframe: json['timeframe'] ?? '',
      difficulty: json['difficulty'] ?? '',
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }
}
