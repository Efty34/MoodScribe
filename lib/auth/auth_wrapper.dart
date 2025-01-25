import 'package:diary/auth/auth_service.dart';
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

class _AuthWrapperState extends State<AuthWrapper>
    with SingleTickerProviderStateMixin {
  bool _showWelcome = true;
  late AnimationController _animationController;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create fade out animation for welcome screen
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Create fade in animation for auth content
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    // Start transition after splash screen loads
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _animationController.forward().then((_) {
          setState(() {
            _showWelcome = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Auth content with fade in animation
        AnimatedBuilder(
          animation: _fadeInAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeInAnimation.value,
              child: Transform.scale(
                scale: 0.95 + (_fadeInAnimation.value * 0.05),
                child: StreamBuilder<User?>(
                  stream: AuthService().authStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData) {
                      return const BottomNavBar();
                    }

                    return const LoginPage();
                  },
                ),
              ),
            );
          },
        ),

        // Splash screen with fade out animation
        if (_showWelcome)
          AnimatedBuilder(
            animation: _fadeOutAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeOutAnimation.value,
                child: Transform.scale(
                  scale: 1.0 + ((1 - _fadeOutAnimation.value) * 0.05),
                  child: const WelcomePage(),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
