import 'package:diary/components/build_profile_section.dart';
import 'package:diary/components/mood_chart.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    // color: Colors.blue[700],
                  ),
                ),
                background: Container(
                  // decoration: BoxDecoration(
                  //   gradient: LinearGradient(
                  //     begin: Alignment.topCenter,
                  //     end: Alignment.bottomCenter,
                  //     colors: [
                  //       Colors.blue[800]!,
                  //       Colors.blue[400]!,
                  //     ],
                  //   ),
                  // ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background pattern
                      Opacity(
                        opacity: 1,
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 8, left: 8, right: 8, bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                22.0), // Adjust the radius as needed
                            child: Image.asset(
                              AppMedia.coverImg,
                              fit: BoxFit.cover,
                            ),
                          ),
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
                    MoodChart(),
                    MoodChart(),
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
      ),
    );
  }
}
