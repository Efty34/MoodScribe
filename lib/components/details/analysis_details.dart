import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for displaying analysis details (category and predicted aspect)
class AnalysisDetails extends StatelessWidget {
  final String? category;
  final String? predictedAspect;

  const AnalysisDetails({
    super.key,
    this.category,
    this.predictedAspect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (category == null && predictedAspect == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Category
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

        // Predicted Aspect
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
    );
  }
}
