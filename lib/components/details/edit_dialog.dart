import 'package:diary/services/diary_service.dart';
import 'package:diary/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Dialog widget for editing diary entry content
class EditDialog extends StatelessWidget {
  final String entryId;
  final String initialContent;
  final String mood;
  final DateTime date;
  final Function(String) onContentUpdated;

  const EditDialog({
    super.key,
    required this.entryId,
    required this.initialContent,
    required this.mood,
    required this.date,
    required this.onContentUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contentController = TextEditingController(text: initialContent);
    final diaryService = DiaryService();

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

    void showSuccessSnackBar(String message) {
      final SnackBarType type = message.toLowerCase().contains('error')
          ? SnackBarType.error
          : SnackBarType.success;

      AppSnackBar.show(
        context: context,
        message: message,
        type: type,
      );
    }

    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor:
          isDark ? theme.colorScheme.surface : theme.scaffoldBackgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: size.width,
        height: size.height * 0.7,
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
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
            const SizedBox(height: 24),
            // Content TextField
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.secondary.withAlpha(76),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.5,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts...',
                    hintStyle: GoogleFonts.poppins(
                      color: theme.hintColor,
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
                    foregroundColor: theme.hintColor,
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final updatedContent = contentController.text.trim();
                    if (updatedContent.isNotEmpty) {
                      try {
                        await diaryService.updateDiaryEntry(
                          entryId: entryId,
                          content: updatedContent,
                          mood: mood,
                          date: date,
                        );
                        onContentUpdated(updatedContent);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        showSuccessSnackBar('Entry updated successfully!');
                      } catch (e) {
                        showSuccessSnackBar('Error updating entry: $e');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
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
  }
}
