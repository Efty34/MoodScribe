import 'package:diary/services/diary_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DiaryDetailPage extends StatefulWidget {
  final String entryId;
  final String initialContent;
  final String initialMood;
  final DateTime date;

  const DiaryDetailPage({
    super.key,
    required this.entryId,
    required this.initialContent,
    required this.initialMood,
    required this.date,
  });

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  final DiaryService _diaryService = DiaryService();
  late String content;
  late String mood;

  @override
  void initState() {
    super.initState();
    content = widget.initialContent;
    mood = widget.initialMood;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getMoodColor(String mood, bool background) {
      if (background) {
        return mood == 'stress'
            ? (isDark ? Colors.red.withOpacity(0.2) : Colors.red[50]!)
            : (isDark ? Colors.green.withOpacity(0.2) : Colors.green[50]!);
      } else {
        return mood == 'stress'
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
                      DateFormat('MMM dd, yyyy').format(widget.date),
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
                    color: theme.colorScheme.onBackground,
                    height: 1.5,
                  ),
                ),
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
      if (background) {
        return mood == 'stress'
            ? (isDark ? Colors.red.withOpacity(0.2) : Colors.red[50]!)
            : (isDark ? Colors.green.withOpacity(0.2) : Colors.green[50]!);
      } else {
        return mood == 'stress'
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
                        color: dialogTheme.colorScheme.onBackground,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: dialogTheme.colorScheme.onBackground),
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
                      DateFormat('MMM dd, yyyy').format(widget.date),
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
                          : dialogTheme.colorScheme.secondary.withOpacity(0.3),
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
                        color: dialogTheme.colorScheme.onBackground,
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
                              date: widget.date,
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
                        ? dialogTheme.colorScheme.error.withOpacity(0.2)
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
                    color: dialogTheme.colorScheme.onBackground,
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
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
