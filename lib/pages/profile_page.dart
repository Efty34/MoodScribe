import 'package:diary/components/build_profile_section.dart';
import 'package:diary/components/mood_chart.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue[400],
            flexibleSpace: FlexibleSpaceBar(
              // title: Text(
              //   'Profile',
              //   style: GoogleFonts.poppins(
              //       fontWeight: FontWeight.w600,
              //       fontSize: 20,
              //       color: Colors.blue[700]),
              // ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue[800]!,
                      Colors.blue[400]!,
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background pattern
                    Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        AppMedia.coverImg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Profile Content
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildProfileSection(),
                  SizedBox(height: 12),

                  // Stats Section
                  // Text(
                  //   'Statistics',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.grey[800],
                  //   ),
                  // ),
                  // const SizedBox(height: 16),
                  MoodChart(),

                  // const SizedBox(height: 24),

                  // Additional Sections (if needed)
                  // ...
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
