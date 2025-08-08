import 'dart:convert';
import 'dart:math';

import 'package:diary/models/stress_prediction_response.dart';
import 'package:diary/services/calendar_access_provider.dart';
import 'package:diary/services/diary_service.dart';
import 'package:diary/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DiaryEntry extends StatefulWidget {
  const DiaryEntry({super.key});

  @override
  _DiaryEntryState createState() => _DiaryEntryState();
}

class _DiaryEntryState extends State<DiaryEntry> {
  final TextEditingController _contentController = TextEditingController();
  final DiaryService _diaryService = DiaryService();
  bool _isLoading = false;

  // Generate random category for API
  String _generateRandomCategory() {
    final categories = [
      'Relationships & Family',
      'Financial Stress',
      'Health & Well-being',
      'Severe Trauma',
    ];
    final random = Random();
    return categories[random.nextInt(categories.length)];
  }

  void _saveEntry() async {
    final content = _contentController.text.trim();

    if (content.isNotEmpty) {
      try {
        // Set loading state to true
        setState(() {
          _isLoading = true;
        });

        // Generate random category for API
        final randomCategory = _generateRandomCategory();

        // Get prediction from Flask backend
        final predictionResponse =
            await _monitorStress(content, randomCategory);

        // Save to Firestore using DiaryService
        await _diaryService.addDiaryEntry(
          content: content,
          category: randomCategory,
          mood: predictionResponse.ensembledStressPrediction,
          date: DateTime.now(),
          predictedAspect: predictionResponse.predictedAspect,
          ensembledStressConfidence:
              predictionResponse.ensembledStressConfidence,
          logregStressConfidence: predictionResponse.logregStressConfidence,
          attentionModelStressConfidence:
              predictionResponse.attentionModelStressConfidence,
          attentionModelAspectConfidence:
              predictionResponse.attentionModelAspectConfidence,
        );

        // Clear the TextField & show a SnackBar
        _contentController.clear();

        // Trigger calendar access check via provider
        if (mounted) {
          Provider.of<CalendarAccessProvider>(context, listen: false)
              .checkCalendarAccess();
        }

        if (!mounted) return;
        AppSnackBar.show(
          context: context,
          message: 'Your diary entry has been saved!',
          type: SnackBarType.success,
        );
      } catch (e) {
        if (!mounted) return;
        AppSnackBar.show(
          context: context,
          message: 'Error: Failed to save entry',
          type: SnackBarType.error,
        );
      } finally {
        // Set loading state back to false
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      AppSnackBar.show(
        context: context,
        message: 'Please write something before saving.',
        type: SnackBarType.warning,
      );
    }
  }

  Future<StressPredictionResponse> _monitorStress(
      String text, String? category) async {
    try {
      final url =
          Uri.parse('https://stress-aspect-detection-api.onrender.com/predict');

      final requestBody = {
        'text': text,
        'initial_aspect': category,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return StressPredictionResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in _monitorStress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Every moment tells a story. What\'s yours today?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 24),

              // Content TextField
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Chronicles of a Wandering Mind...',
                    hintStyle: GoogleFonts.poppins(
                      color: theme.hintColor,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Center(
                child: SizedBox(
                  height: 50,
                  width: 250,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 3,
                      shadowColor: Colors.black.withAlpha(isDark ? 127 : 76),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      animationDuration: const Duration(milliseconds: 200),
                    ),
                    onPressed: _isLoading ? null : _saveEntry,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.add, size: 20),
                    label: Text(
                      _isLoading ? "Saving..." : "Save Entry",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
