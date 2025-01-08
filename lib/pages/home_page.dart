import 'package:diary/components/custom_app_bar.dart';
import 'package:diary/components/custom_app_drawer.dart';
import 'package:diary/components/diary_detail_page.dart';
import 'package:diary/components/diary_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Open the Hive box
    final Box<String> diaryBox = Hive.box<String>('diaryBox');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      drawer: const CustomAppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ValueListenableBuilder(
          valueListenable: diaryBox.listenable(),
          builder: (context, Box<String> box, _) {
            // Check if the box is empty
            if (box.isEmpty) {
              return const Center(
                child: Text(
                  'No diary entries yet. Add some thoughts!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            // Build the MasonryGridView with diary entries
            return MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: box.length,
              itemBuilder: (context, index) {
                final String entry = box.getAt(index) ?? '';
                return DiaryEntryCard(
                  entry: entry,
                  onTap: () {
                    // Pass both index and entry to the detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiaryDetailPage(
                          index: index,
                          initialEntry: entry,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    // Show options to edit or delete
                    _showOptions(context, box, index, entry);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showOptions(
      BuildContext context, Box<String> box, int index, String entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, box, index, entry);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, box, index);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    Box<String> box,
    int index,
    String entry,
  ) {
    final controller = TextEditingController(text: entry);

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Note',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  maxLines: null,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    hintText: 'Update your note',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        final updatedText = controller.text.trim();
                        if (updatedText.isNotEmpty) {
                          box.putAt(index, updatedText);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Note updated'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text('Save'),
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

  void _showDeleteConfirmation(
      BuildContext context, Box<String> box, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                box.deleteAt(index);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note deleted successfully!')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
