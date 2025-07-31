import 'package:diary/services/diary_service.dart';
import 'package:diary/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog widget for confirming diary entry deletion
class DeleteConfirmationDialog extends StatelessWidget {
  final String entryId;
  final VoidCallback onDeleted;

  const DeleteConfirmationDialog({
    super.key,
    required this.entryId,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diaryService = DiaryService();

    void showSuccessSnackBar(String message) {
      final SnackBarType type = message.toLowerCase().contains('error')
          ? SnackBarType.error
          : SnackBarType.warning;

      AppSnackBar.show(
        context: context,
        message: message,
        type: type,
      );
    }

    return Dialog(
      backgroundColor:
          isDark ? theme.colorScheme.surface : theme.scaffoldBackgroundColor,
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
                    ? theme.colorScheme.error.withAlpha(51)
                    : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Entry',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete this entry?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.hintColor,
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
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
                      await diaryService.deleteDiaryEntry(entryId);
                      if (!context.mounted) return;
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to previous screen
                      onDeleted();
                      showSuccessSnackBar('Entry deleted successfully!');
                    } catch (e) {
                      showSuccessSnackBar('Error deleting entry: $e');
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
  }
}
