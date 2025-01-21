import 'package:diary/components/build_profile_section.dart';
import 'package:diary/components/diary_streak_calendar.dart';
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
                title: Row(
                  children: [
                    Text(
                      'Profile',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        // color: Colors.blue[700],
                      ),
                    ),
                  ],
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
                              top: 8, left: 8, right: 8, bottom: 2),
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
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const BuildProfileSection(),
                  const SizedBox(height: 10),

                  Text(
                    'Statistics',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Add horizontal scrolling for DiaryStreak and MoodChart
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // DiaryStreak with constrained width
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: const MoodChart(),
                        ),
                        const SizedBox(width: 16),
                        // MoodChart with constrained width

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: const DiaryStreakCalendar(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
