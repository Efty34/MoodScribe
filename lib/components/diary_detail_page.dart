import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/services/diary_service.dart';
import 'package:diary/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
  final DiaryService _diaryService = DiaryService();
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

    Color getMoodColor(String mood, bool background) {
      final isStress = mood.toLowerCase().contains('stress') &&
          !mood.toLowerCase().contains('no stress');

      if (background) {
        return isStress
            ? (isDark ? Colors.red.withAlpha(51) : Colors.red[50]!)
            : (isDark ? Colors.green.withAlpha(51) : Colors.green[50]!);
      } else {
        return isStress
            ? (isDark ? Colors.red[300]! : Colors.red[700]!)
            : (isDark ? Colors.green[300]! : Colors.green[700]!);
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Diary Entry',
          style: GoogleFonts.poppins(
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
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(date),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getMoodColor(mood, true),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mood,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: getMoodColor(mood, false),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 16),

                // Content
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 16),

                // Additional Analysis Information
                if (category != null || predictedAspect != null) ...[
                  Text(
                    'Analysis Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category & Predicted Aspect
                  if (category != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Category: ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.hintColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            category!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (predictedAspect != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          size: 16,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Predicted Aspect: ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.hintColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            predictedAspect!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                // Confidence Scores
                if (ensembledStressConfidence != null ||
                    logregStressConfidence != null ||
                    attentionModelStressConfidence != null ||
                    attentionModelAspectConfidence != null) ...[
                  Text(
                    'Model Confidence Scores',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (ensembledStressConfidence != null)
                    _buildConfidenceRow(
                      'Ensemble Model',
                      ensembledStressConfidence!,
                      theme,
                      Icons.merge_type,
                    ),
                  if (logregStressConfidence != null)
                    _buildConfidenceRow(
                      'Logistic Regression',
                      logregStressConfidence!,
                      theme,
                      Icons.analytics_outlined,
                    ),
                  if (attentionModelStressConfidence != null)
                    _buildConfidenceRow(
                      'Attention Model (Stress)',
                      attentionModelStressConfidence!,
                      theme,
                      Icons.visibility_outlined,
                    ),
                  if (attentionModelAspectConfidence != null)
                    _buildConfidenceRow(
                      'Attention Model (Aspect)',
                      attentionModelAspectConfidence!,
                      theme,
                      Icons.center_focus_strong,
                    ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Debug section - show when no confidence scores are available
                  Text(
                    'Debug Info',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ensemble: ${ensembledStressConfidence?.toString() ?? "null"}\n'
                    'Logreg: ${logregStressConfidence?.toString() ?? "null"}\n'
                    'Attention Stress: ${attentionModelStressConfidence?.toString() ?? "null"}\n'
                    'Attention Aspect: ${attentionModelAspectConfidence?.toString() ?? "null"}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contentController = TextEditingController(text: content);

    Color getMoodColor(String mood, bool background) {
      final isStress = mood.toLowerCase().contains('stress') &&
          !mood.toLowerCase().contains('no stress');

      if (background) {
        return isStress
            ? (isDark ? Colors.red.withAlpha(51) : Colors.red[50]!)
            : (isDark ? Colors.green.withAlpha(51) : Colors.green[50]!);
      } else {
        return isStress
            ? (isDark ? Colors.red[300]! : Colors.red[700]!)
            : (isDark ? Colors.green[300]! : Colors.green[700]!);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final dialogTheme = Theme.of(context);
        final isDialogDark = dialogTheme.brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isDialogDark
              ? dialogTheme.colorScheme.surface
              : dialogTheme.scaffoldBackgroundColor,
          // Make dialog bigger
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: size.width,
            height: size.height * 0.7, // 70% of screen height
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Entry',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: dialogTheme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: dialogTheme.colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Date and Mood display
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: dialogTheme.hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(date),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: dialogTheme.hintColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getMoodColor(mood, true),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mood,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: getMoodColor(mood, false),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Content TextField
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDialogDark
                          ? dialogTheme.colorScheme.secondary
                          : dialogTheme.colorScheme.secondary.withAlpha(76),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dialogTheme.dividerColor),
                    ),
                    child: TextField(
                      controller: contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.5,
                        color: dialogTheme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write your thoughts...',
                        hintStyle: GoogleFonts.poppins(
                          color: dialogTheme.hintColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        foregroundColor: dialogTheme.hintColor,
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final updatedContent = contentController.text.trim();
                        if (updatedContent.isNotEmpty) {
                          try {
                            await _diaryService.updateDiaryEntry(
                              entryId: widget.entryId,
                              content: updatedContent,
                              mood: mood,
                              date: date,
                            );
                            setState(() {
                              content = updatedContent;
                            });
                            if (!mounted) return;
                            Navigator.pop(context);
                            _showSuccessSnackBar('Entry updated successfully!');
                          } catch (e) {
                            _showSuccessSnackBar('Error updating entry: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dialogTheme.colorScheme.primary,
                        foregroundColor: dialogTheme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        final dialogTheme = Theme.of(context);

        return Dialog(
          backgroundColor: isDark
              ? dialogTheme.colorScheme.surface
              : dialogTheme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? dialogTheme.colorScheme.error.withAlpha(51)
                        : Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: dialogTheme.colorScheme.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete Entry',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: dialogTheme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete this entry?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: dialogTheme.hintColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: dialogTheme.hintColor,
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dialogTheme.colorScheme.error,
                        foregroundColor: dialogTheme.colorScheme.onError,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await _diaryService.deleteDiaryEntry(widget.entryId);
                          if (!mounted) return;
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to previous screen
                          _showSuccessSnackBar('Entry deleted successfully!');
                        } catch (e) {
                          _showSuccessSnackBar('Error deleting entry: $e');
                        }
                      },
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    // Determine the appropriate SnackBar type based on the message content
    final SnackBarType type = message.toLowerCase().contains('error')
        ? SnackBarType.error
        : (message.toLowerCase().contains('deleted')
            ? SnackBarType.warning
            : SnackBarType.success);

    AppSnackBar.show(
      context: context,
      message: message,
      type: type,
    );
  }

  Widget _buildConfidenceRow(
      String label, double confidence, ThemeData theme, IconData icon) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    final confidenceColor = confidence > 0.7
        ? Colors.green
        : confidence > 0.5
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.hintColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.hintColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: confidenceColor.withAlpha(76),
                    ),
                  ),
                  child: Text(
                    '$percentage%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: confidenceColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
