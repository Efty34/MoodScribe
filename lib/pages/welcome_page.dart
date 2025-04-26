import 'package:animations/animations.dart';
import 'package:diary/pages/login_page.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _taglineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    _taglineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeInOut),
      ),
    );

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeInOut),
      ),
    );

    _controller.forward().then((_) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Create blue accent colors based on the theme
    final blueAccent = isDarkMode
        ? Color.lerp(theme.colorScheme.primary, Colors.blue, 0.3)!
        : Color.lerp(theme.colorScheme.primary, Colors.blue.shade700, 0.2)!;

    final blueAccentLight = isDarkMode
        ? Color.lerp(theme.colorScheme.primary, Colors.blue.shade300, 0.4)!
        : Color.lerp(theme.colorScheme.primary, Colors.blue.shade400, 0.15)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Color.lerp(theme.colorScheme.surface, blueAccent, 0.05)!,
                    theme.colorScheme.surface,
                  ]
                : [
                    Color.lerp(
                        theme.colorScheme.surface, blueAccentLight, 0.08)!,
                    theme.colorScheme.surface,
                  ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            // Animated Journal Icon with Pen
                            Container(
                              height: 110,
                              width: 110,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  theme.colorScheme.surface,
                                  blueAccent,
                                  isDarkMode ? 0.12 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: blueAccent
                                        .withOpacity(isDarkMode ? 0.2 : 0.1),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.book_outlined,
                                  //   size: 50,
                                  //   color: Color.lerp(
                                  //     theme.colorScheme.onSurface,
                                  //     blueAccent,
                                  //     isDarkMode ? 0.4 : 0.3,
                                  //   ),
                                  // ),
                                  Image.asset(
                                    AppMedia.logo,
                                    width: 80,
                                    height: 80,
                                  ),
                                  Positioned(
                                    top: _shimmerAnimation.value * 10 + 2,
                                    right: _shimmerAnimation.value * 5 + 5,
                                    child: Icon(
                                      Icons.edit,
                                      size: 22,
                                      color: Color.lerp(
                                        theme.colorScheme.onSurface,
                                        blueAccent,
                                        isDarkMode ? 0.5 : 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // App Title with Shimmer Effect
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.onSurface,
                                  Color.lerp(theme.colorScheme.onSurface,
                                      blueAccent, 0.7)!,
                                  theme.colorScheme.onSurface,
                                ],
                                stops: [
                                  0.0,
                                  _shimmerAnimation.value,
                                  1.0,
                                ],
                                transform: const GradientRotation(
                                    0.785), // 45 degrees in radians
                              ).createShader(bounds),
                              child: Text(
                                "MoodScribe",
                                style: GoogleFonts.montserrat(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Tagline with fade in animation
                            AnimatedOpacity(
                              opacity: _taglineAnimation.value,
                              duration: Duration.zero,
                              child: Text(
                                "Track, Reflect, Thrive",
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.8),
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Loading Dots Animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLoadingDots(
                        theme: theme,
                        blueAccent: blueAccent,
                        animation: _loadingAnimation.value,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingDots({
    required ThemeData theme,
    required Color blueAccent,
    required double animation,
    required bool isDarkMode,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        // Stagger the animations for each dot
        final delay = index * 0.2;
        final individualAnimation = animation > delay
            ? (animation - delay) < 0.8
                ? (animation - delay) / 0.8
                : 1.0
            : 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 8 + (individualAnimation * 2),
          width: 8 + (individualAnimation * 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
              theme.colorScheme.primary,
              blueAccent,
              isDarkMode ? 0.5 : 0.3,
            )!
                .withOpacity(0.2 + (individualAnimation * 0.8)),
          ),
        );
      }),
    );
  }
}
