import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/details/analysis_details.dart';
import 'package:diary/components/details/confidence_scores.dart';
import 'package:diary/components/details/content_display.dart';
import 'package:diary/components/details/delete_confirmation_dialog.dart';
import 'package:diary/components/details/detail_header.dart';
import 'package:diary/components/details/edit_dialog.dart';
import 'package:flutter/material.dart';

class DiaryDetailPage extends StatefulWidget {
  final String entryId;
  final Map<String, dynamic> entryData;

  const DiaryDetailPage({
    super.key,
    required this.entryId,
    required this.entryData,
  });

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  late String content;
  late String mood;
  late DateTime date;
  late String? category;
  late String? predictedAspect;
  late double? ensembledStressConfidence;
  late double? logregStressConfidence;
  late double? attentionModelStressConfidence;
  late double? attentionModelAspectConfidence;

  @override
  void initState() {
    super.initState();
    content = widget.entryData['content'] as String;
    mood = widget.entryData['mood'] as String? ?? 'unknown';
    date = (widget.entryData['date'] as Timestamp).toDate();
    category = widget.entryData['category'] as String?;
    predictedAspect = widget.entryData['predicted_aspect'] as String?;
    ensembledStressConfidence =
        (widget.entryData['ensembled_stress_confidence'] as num?)?.toDouble();
    logregStressConfidence =
        (widget.entryData['logreg_stress_confidence'] as num?)?.toDouble();
    attentionModelStressConfidence =
        (widget.entryData['attention_model_stress_confidence'] as num?)
            ?.toDouble();
    attentionModelAspectConfidence =
        (widget.entryData['attention_model_aspect_confidence'] as num?)
            ?.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Diary Entry',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
            ),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Mood
                DetailHeader(date: date, mood: mood),
                const SizedBox(height: 16),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 16),

                // Content
                ContentDisplay(content: content),

                const SizedBox(height: 24),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 16),

                // Analysis Details
                AnalysisDetails(
                  category: category,
                  predictedAspect: predictedAspect,
                ),

                // Confidence Scores
                ConfidenceScores(
                  ensembledStressConfidence: ensembledStressConfidence,
                  logregStressConfidence: logregStressConfidence,
                  attentionModelStressConfidence:
                      attentionModelStressConfidence,
                  attentionModelAspectConfidence:
                      attentionModelAspectConfidence,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => EditDialog(
        entryId: widget.entryId,
        initialContent: content,
        mood: mood,
        date: date,
        onContentUpdated: (updatedContent) {
          setState(() {
            content = updatedContent;
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        entryId: widget.entryId,
        onDeleted: () {
          // This callback is called after successful deletion
          // The dialog already handles navigation back
        },
      ),
    );
  }
}
