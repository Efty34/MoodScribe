import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for displaying confidence scores and debug info
class ConfidenceScores extends StatelessWidget {
  final double? ensembledStressConfidence;
  final double? logregStressConfidence;
  final double? attentionModelStressConfidence;
  final double? attentionModelAspectConfidence;

  const ConfidenceScores({
    super.key,
    this.ensembledStressConfidence,
    this.logregStressConfidence,
    this.attentionModelStressConfidence,
    this.attentionModelAspectConfidence,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasConfidenceScores = ensembledStressConfidence != null ||
        logregStressConfidence != null ||
        attentionModelStressConfidence != null ||
        attentionModelAspectConfidence != null;

    if (hasConfidenceScores) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confidence Level',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (ensembledStressConfidence != null)
            _buildConfidenceRow(
              'Ensemble Model',
              ensembledStressConfidence!,
              theme,
              Icons.merge_type,
            ),
          if (logregStressConfidence != null)
            _buildConfidenceRow(
              'Logistic Regression',
              logregStressConfidence!,
              theme,
              Icons.analytics_outlined,
            ),
          if (attentionModelStressConfidence != null)
            _buildConfidenceRow(
              'Attention Model (Stress)',
              attentionModelStressConfidence!,
              theme,
              Icons.visibility_outlined,
            ),
          if (attentionModelAspectConfidence != null)
            _buildConfidenceRow(
              'Attention Model (Aspect)',
              attentionModelAspectConfidence!,
              theme,
              Icons.center_focus_strong,
            ),
          const SizedBox(height: 16),
        ],
      );
    } else {
      // Debug section - show when no confidence scores are available
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Info',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ensemble: ${ensembledStressConfidence?.toString() ?? "null"}\n'
            'Logreg: ${logregStressConfidence?.toString() ?? "null"}\n'
            'Attention Stress: ${attentionModelStressConfidence?.toString() ?? "null"}\n'
            'Attention Aspect: ${attentionModelAspectConfidence?.toString() ?? "null"}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }
  }

  Widget _buildConfidenceRow(
      String label, double confidence, ThemeData theme, IconData icon) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    final confidenceColor = confidence > 0.7
        ? Colors.green
        : confidence > 0.5
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.hintColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.hintColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: confidenceColor.withAlpha(76),
                    ),
                  ),
                  child: Text(
                    '$percentage%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: confidenceColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
