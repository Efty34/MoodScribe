import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/build_profile_section.dart';
import 'package:diary/components/profilepage/category_collection_section.dart';
import 'package:diary/components/profilepage/stats_section.dart';
import 'package:diary/services/favorites_service.dart';
import 'package:diary/services/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/mood_chart_provider.dart';

class ProfilePage extends StatefulWidget {
  final String? userId; // Add userId parameter to fetch specific user's data

  const ProfilePage({
    super.key,
    this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FavoritesService _favoritesService = FavoritesService();
  List<QueryDocumentSnapshot>? _cachedFavorites;
  bool _isLoadingFavorites = true;
  String? _favoritesError;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initial fetch of favorites on widget mount
    _fetchFavorites();

    // Initialize profile data via provider if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      if (!provider.isFreshDataAvailable) {
        provider.fetchProfileData();
      }
    });
  }

  Future<void> _fetchFavorites({String? specificUserId}) async {
    if (!mounted) return;

    setState(() {
      _isLoadingFavorites = true;
      _favoritesError = null;
    });

    try {
      final snapshot = widget.userId != null
          ? await _favoritesService.getFavoritesForUser(widget.userId!)
          : await _favoritesService.getFavoritesOnce();

      if (!mounted) return;

      setState(() {
        _cachedFavorites = snapshot.docs;
        _isLoadingFavorites = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _favoritesError = e.toString();
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    // Refresh favorites
    await _fetchFavorites();

    // Refresh profile data
    if (mounted) {
      await Provider.of<UserProfileProvider>(context, listen: false)
          .refreshData();

      // Also refresh mood chart data
      await Provider.of<MoodChartProvider>(context, listen: false)
          .refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section with enhanced shadow and margin
                const BuildProfileSection(),

                const SizedBox(height: 24),

                // Statistics Section with charts
                const StatsSection(),

                const SizedBox(height: 32),

                // Favorites Collection Section
                _buildFavoritesSection(theme),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesSection(ThemeData theme) {
    // When using a specific user ID, we still need to use the one-time fetch method
    if (widget.userId != null) {
      if (_isLoadingFavorites && _cachedFavorites == null) {
        return _buildLoadingState(theme);
      }

      if (_favoritesError != null) {
        return _buildErrorStateWithRetry(
          _favoritesError!,
          theme,
          onRetry: _fetchFavorites,
        );
      }

      final favorites = _cachedFavorites ?? [];
      return CategoryCollectionSection(collections: favorites);
    }

    // For the current user, use a stream for real-time updates
    return CategoryCollectionSection(
      favoritesStream: _favoritesService.getFavorites(),
      collections:
          _cachedFavorites, // Provide cached data for initial render if available
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorStateWithRetry(String error, ThemeData theme,
      {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.onSurface.withAlpha(178),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
