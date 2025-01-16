import 'package:diary/components/custom_app_bar.dart';
import 'package:diary/components/custom_app_drawer.dart';
import 'package:diary/components/diary_detail_page.dart';
import 'package:diary/components/diary_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<String> diaryBox = Hive.box<String>('diaryBox');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      drawer: const CustomAppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ValueListenableBuilder(
            valueListenable: diaryBox.listenable(),
            builder: (context, Box<String> box, _) {
              if (box.isEmpty) {
                return const Center(
                  child: Text(
                    'No diary entries yet. Add some thoughts!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              // Get all entries and sort them by timestamp
              final entries = List.generate(box.length, (index) {
                final key = box.keyAt(index);
                return {
                  'key': key,
                  'timestamp': int.tryParse(key.toString()) ?? 0,
                  'text': box.getAt(index) ?? '',
                };
              });

              // Sort entries by timestamp in descending order (newest first)
              entries.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

              return MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final originalIndex = box.keyAt(index);

                  return DiaryEntryCard(
                    entry: entry['text'] as String,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiaryDetailPage(
                            entryKey: entry['key'] as String,
                            initialEntry: entry['text'] as String,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      _showOptions(
                        context, 
                        box, 
                        box.keyAt(box.toMap().values.toList().indexOf(entry['text'])), 
                        entry['text'] as String,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, Box<String> box, dynamic key, String entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, box, key, entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, box, key);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    Box<String> box,
    String key,
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
                          box.put(key, updatedText);
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
      BuildContext context, Box<String> box, String key) {
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
                box.delete(key);
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
