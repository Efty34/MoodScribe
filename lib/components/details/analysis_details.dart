import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for displaying analysis details (category and predicted aspect)
class AnalysisDetails extends StatelessWidget {
  final String? category;
  final String? predictedAspect;
  final String? mood;

  const AnalysisDetails({
    super.key,
    this.category,
    this.predictedAspect,
    this.mood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print('Mood: $mood');

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
        if (predictedAspect != null) ...[
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: mood == 'Stress'
                      ? 'This entry highlights significant stress in '
                      : 'This entry reflects notable ease in ',
                ),
                TextSpan(
                  text: predictedAspect!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: mood == 'Stress' ? Colors.red : Colors.green,
                  ),
                ),
                TextSpan(
                  text: mood == 'Stress'
                      ? '. It may be weighing heavily on you, indicating an area to be mindful of for your well-being.'
                      : '. It appears you’re managing this aspect well, reflecting resilience and balance.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
