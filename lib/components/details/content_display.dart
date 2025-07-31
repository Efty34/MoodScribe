import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for displaying diary entry content
class ContentDisplay extends StatelessWidget {
  final String content;

  const ContentDisplay({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      content,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: theme.colorScheme.onSurface,
        height: 1.5,
      ),
    );
  }
}
