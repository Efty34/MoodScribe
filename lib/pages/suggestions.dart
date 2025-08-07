import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/suggestion_service.dart';
import '../services/suggestions_provider.dart';

class Suggestions extends StatefulWidget {
  const Suggestions({super.key});

  @override
  State<Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuggestionsProvider>().loadSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mental Health Suggestions'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 2,
        shadowColor: colorScheme.outline.withOpacity(0.3),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.tertiary),
            onPressed: () =>
                context.read<SuggestionsProvider>().refreshSuggestions(),
            tooltip: 'Refresh Suggestions',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: colorScheme.tertiary,
        backgroundColor: colorScheme.surface,
        onRefresh: () =>
            context.read<SuggestionsProvider>().refreshSuggestions(),
        child: Consumer<SuggestionsProvider>(
          builder: (context, suggestionsProvider, child) {
            if (suggestionsProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: colorScheme.tertiary,
                  backgroundColor:
                      colorScheme.tertiaryContainer.withOpacity(0.3),
                ),
              );
            }

            if (suggestionsProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      suggestionsProvider.error!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => suggestionsProvider.refreshSuggestions(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.tertiary,
                        foregroundColor: colorScheme.onTertiary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!suggestionsProvider.hasData) {
              return Center(
                child: Text(
                  'No suggestions available',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            final suggestionData = suggestionsProvider.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStressLevelCard(suggestionData),
                  const SizedBox(height: 16),
                  _buildAnalysisSummary(suggestionData),
                  const SizedBox(height: 16),
                  _buildMentalHealthAnalysis(suggestionData),
                  const SizedBox(height: 16),
                  _buildSuggestionsSection(suggestionData),
                  const SizedBox(height: 16),
                  _buildEmergencyResources(suggestionData),
                  const SizedBox(height: 16),
                  _buildDisclaimer(suggestionData),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStressLevelCard(SuggestionResponse suggestionData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stress Level',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: colorScheme.tertiaryContainer.withOpacity(0.3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: suggestionData.userStressPercentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: _getStressColor(
                            suggestionData.userStressPercentage),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: colorScheme.outline.withOpacity(0.3)),
                ),
                child: Text(
                  '${suggestionData.userStressPercentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStressColor(double percentage) {
    final colorScheme = Theme.of(context).colorScheme;
    if (percentage < 30) return colorScheme.primary;
    if (percentage < 60) return colorScheme.secondary;
    return colorScheme.error;
  }

  Widget _buildAnalysisSummary(SuggestionResponse suggestionData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = suggestionData.analysisSummary;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildStatChip('Total Entries',
                      summary.totalEntriesAnalyzed.toString())),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildStatChip(
                      'Stress Entries', summary.stressEntries.toString())),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildStatChip(
                      'Non-Stress', summary.nonStressEntries.toString())),
            ],
          ),
          if (summary.mainStressSources.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Main Stress Sources:',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: summary.mainStressSources
                  .map((source) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: colorScheme.outline.withOpacity(0.3)),
                        ),
                        child: Text(
                          source,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onTertiaryContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentalHealthAnalysis(SuggestionResponse suggestionData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final analysis = suggestionData.mentalHealthAnalysis;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mental Health Analysis',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAnalysisItem('Assessment', analysis.stressLevelAssessment),
          const SizedBox(height: 12),
          _buildAnalysisItem('Summary', analysis.mentalStateSummary),
          if (analysis.riskFactors.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildListSection('Risk Factors', analysis.riskFactors,
                colorScheme.errorContainer, colorScheme.onErrorContainer),
          ],
          if (analysis.positiveIndicators.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildListSection(
                'Positive Indicators',
                analysis.positiveIndicators,
                colorScheme.tertiaryContainer,
                colorScheme.onTertiaryContainer),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String content) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(
      String title, List<String> items, Color chipColor, Color textColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((item) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: Text(
                      item,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(SuggestionResponse suggestionData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final suggestions = suggestionData.suggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSuggestionCategory('Immediate Actions',
            suggestions.immediateActions, colorScheme.error),
        const SizedBox(height: 12),
        _buildSuggestionCategory('Short Term Goals', suggestions.shortTermGoals,
            colorScheme.secondary),
        const SizedBox(height: 12),
        _buildSuggestionCategory('Long Term Changes',
            suggestions.longTermChanges, colorScheme.primary),
      ],
    );
  }

  Widget _buildSuggestionCategory(
      String title, List<SuggestionItem> items, Color accentColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items
              .map((item) => _buildSuggestionItem(item, accentColor))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(SuggestionItem item, Color accentColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(item.priority),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: colorScheme.outline.withOpacity(0.3)),
                ),
                child: Text(
                  item.priority,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getPriorityTextColor(item.priority),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Category: ${item.category}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                item.timeframe,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.trending_up,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                item.difficulty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Benefits:',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: item.benefits
                .map((benefit) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: colorScheme.outline.withOpacity(0.3)),
                      ),
                      child: Text(
                        benefit,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme.errorContainer;
      case 'medium':
        return colorScheme.secondaryContainer;
      case 'low':
        return colorScheme.tertiaryContainer;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color _getPriorityTextColor(String priority) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme.onErrorContainer;
      case 'medium':
        return colorScheme.onSecondaryContainer;
      case 'low':
        return colorScheme.onTertiaryContainer;
      default:
        return colorScheme.onSurface;
    }
  }

  Widget _buildEmergencyResources(SuggestionResponse suggestionData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emergency,
                color: colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Emergency Resources',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestionData.emergencyResources
              .map((resource) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            resource,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(SuggestionResponse suggestionData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.tertiary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Disclaimer',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            suggestionData.disclaimer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
