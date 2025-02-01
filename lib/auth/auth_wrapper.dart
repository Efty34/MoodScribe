import 'package:diary/pages/login_page.dart';
import 'package:diary/pages/welcome_page.dart';
import 'package:diary/utils/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isSplashVisible = true; // To control splash screen visibility

  @override
  void initState() {
    super.initState();
    _startSplashScreen(); // Show splash screen initially
  }

  void _startSplashScreen() async {
    // Show the splash screen for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isSplashVisible = false; // Hide splash screen after the delay
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSplashVisible) {
      // Always show the splash screen first
      return const WelcomePage();
    }

    // After splash screen, check authentication state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while determining authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // User is logged in
        if (snapshot.hasData) {
          return const BottomNavBar();
        }

        // User is not logged in
        return const LoginPage();
      },
    );
  }
}
