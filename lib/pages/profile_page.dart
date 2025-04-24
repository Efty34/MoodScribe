import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/components/build_profile_section.dart';
import 'package:diary/components/profilepage/collection_section.dart';
import 'package:diary/components/profilepage/stats_section.dart';
import 'package:diary/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section with enhanced shadow and margin
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.15)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const BuildProfileSection(),
              ),

              const SizedBox(height: 24),

              // Statistics Section with charts
              const StatsSection(),

              const SizedBox(height: 32),

              // Favorites Collection Section
              StreamBuilder<QuerySnapshot>(
                stream: FavoritesService().getFavorites(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString(), theme);
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState(theme);
                  }

                  final favorites = snapshot.data?.docs ?? [];
                  return CollectionSection(favorites: favorites);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

  Widget _buildErrorState(String error, ThemeData theme) {
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
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
