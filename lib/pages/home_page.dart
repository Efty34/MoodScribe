import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/custom_app_drawer.dart';
import 'package:diary/components/diary_detail_page.dart';
import 'package:diary/components/diary_entry_card.dart';
import 'package:diary/services/diary_service.dart';
import 'package:diary/utils/search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  final SearchState searchState;

  const HomePage({
    super.key,
    required this.searchState,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DiaryService _diaryService = DiaryService();

  @override
  void initState() {
    super.initState();
    widget.searchState.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.searchState.removeListener(_onSearchChanged);
    super.dispose();
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty) return Text(text);

    List<TextSpan> spans = [];
    final String lowercaseText = text.toLowerCase();
    final String lowercaseQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final int index = lowercaseText.indexOf(lowercaseQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            backgroundColor: Colors.blue[100],
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
    }

    return RichText(
        text: TextSpan(
            children: spans, style: const TextStyle(color: Colors.black)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: CustomAppBar(
      //   searchController: _searchController,
      //   onSearchChanged: (query) => setState(() => _searchQuery = query),
      //   isSearching: _isSearching,
      //   onSearchToggle: _toggleSearch,
      // ),
      drawer: const CustomAppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: StreamBuilder<QuerySnapshot>(
            stream: _diaryService.getEntries(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No diary entries yet. Add some thoughts!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final entries = snapshot.data!.docs;
              final filteredEntries = widget.searchState.query.isEmpty
                  ? entries
                  : entries.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final text = (data['text'] as String).toLowerCase();
                      return text
                          .contains(widget.searchState.query.toLowerCase());
                    }).toList();

              if (filteredEntries.isEmpty) {
                return Center(
                  child: Text(
                    'No entries found for "${widget.searchState.query}"',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  final doc = filteredEntries[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final text = data['text'] as String;

                  return DiaryEntryCard(
                    entry: text,
                    highlightedEntry: widget.searchState.query.isNotEmpty
                        ? _highlightText(text, widget.searchState.query)
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiaryDetailPage(
                            entryId: doc.id,
                            initialEntry: text,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      _showOptions(context, doc.id, text);
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

  void _showOptions(BuildContext context, String docId, String entry) {
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
                  _showEditDialog(context, docId, entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, docId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String docId, String entry) {
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
                      onPressed: () async {
                        final updatedText = controller.text.trim();
                        if (updatedText.isNotEmpty) {
                          try {
                            await _diaryService.updateEntry(docId, updatedText);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Note updated'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating note: $e'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
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

  void _showDeleteConfirmation(BuildContext context, String docId) {
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
              onPressed: () async {
                try {
                  await _diaryService.deleteEntry(docId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note deleted successfully!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting note: $e'),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
