import 'package:diary/components/build_profile_section.dart';
import 'package:diary/components/mood_chart.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BuildProfileSection(),
                SizedBox(height: 20),
                MoodChart(
                  stressAnalysis: "Stress Analysis per Day",
                ),
                SizedBox(height: 20),
                MoodChart(
                  stressAnalysis: "Stress Analysis per Week",
                ),
                SizedBox(height: 20),
                MoodChart(
                  stressAnalysis: "Stress Analysis per Month",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
