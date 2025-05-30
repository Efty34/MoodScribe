import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/custom_app_drawer.dart';
import 'package:diary/components/diary_detail_page.dart';
import 'package:diary/components/diary_entry_card.dart';
import 'package:diary/services/diary_service.dart';
import 'package:diary/utils/media.dart';
import 'package:diary/utils/search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const CustomAppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: StreamBuilder<QuerySnapshot>(
            stream: _diaryService.getDiaryEntries(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No diary entries yet. Add some thoughts!',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.hintColor,
                    ),
                  ),
                );
              }

              final entries = snapshot.data!.docs;
              final filteredEntries = widget.searchState.query.isEmpty
                  ? entries
                  : entries.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final content = (data['content'] as String).toLowerCase();
                      final query = widget.searchState.query.toLowerCase();
                      return content.contains(query);
                    }).toList();

              if (filteredEntries.isEmpty) {
                if (widget.searchState.query.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          AppMedia.notfound,
                          width: 200,
                          height: 200,
                          repeat: true,
                          animate: true,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No entries found for "${widget.searchState.query}"',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.hintColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Center(
                  child: Text(
                    'No diary entries yet. Add some thoughts!',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.hintColor,
                    ),
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
                  final content = data['content'] as String;
                  final mood = data['mood'] as String;
                  final date = (data['date'] as Timestamp).toDate();

                  final truncatedContent = content.length > 100
                      ? '${content.substring(0, 100)}...'
                      : content;

                  return DiaryEntryCard(
                    content: widget.searchState.query.isNotEmpty
                        ? _highlightText(
                            truncatedContent, widget.searchState.query)
                        : Text(
                            truncatedContent,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                    mood: mood,
                    date: date,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiaryDetailPage(
                            entryId: doc.id,
                            initialContent: content,
                            initialMood: mood,
                            date: date,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {},
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _highlightText(String text, String query) {
    final theme = Theme.of(context);

    if (query.isEmpty) {
      return Text(
        text,
        style: TextStyle(color: theme.colorScheme.onSurface),
      );
    }

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
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      );

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
    );
  }
}
