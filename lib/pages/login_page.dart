import 'package:diary/auth/auth_service.dart';
import 'package:diary/components/animate_button.dart';
import 'package:diary/components/modern_text_field.dart';
import 'package:diary/pages/register_page.dart';
import 'package:diary/utils/app_routes.dart';
import 'package:diary/utils/app_snackbar.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final error = await AuthService().signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error != null) {
        // Show error with our new AppSnackBar
        if (mounted) {
          AppSnackBar.show(
            context: context,
            message: error,
            type: SnackBarType.error,
            duration: const Duration(seconds: 4),
            actionLabel: 'OK',
            onAction: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          );
        }
      } else {
        // Clear fields after successful login
        emailController.clear();
        passwordController.clear();

        // Navigate to BottomNavBar and remove all previous routes
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.bottomNavBar,
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppSnackBar.show(
          context: context,
          message: 'Connection error. Please check your internet.',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme brightness to adapt UI to light/dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        // Use theme-aware background color
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              height: screenSize.height - MediaQuery.of(context).padding.top,
              child: Stack(
                children: [
                  // Gradient background - subtle and adapts to theme
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDarkMode
                            ? [
                                colorScheme.surface,
                                colorScheme.surface,
                              ]
                            : [
                                colorScheme.surface,
                                colorScheme.surface,
                              ],
                      ),
                    ),
                  ),

                  // Login content
                  Column(
                    children: [
                      // Top image section with curved bottom
                      Hero(
                        tag: 'login_image',
                        child: Container(
                          height: screenSize.height * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage(AppMedia.loginbg),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0)),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Gradient overlay for better text visibility
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(40),
                                    bottomRight: Radius.circular(40),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.0),
                                      Colors.black.withOpacity(0.6),
                                    ],
                                  ),
                                ),
                              ),

                              // Welcome text overlay
                              Positioned(
                                bottom: 30,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Welcome Back',
                                        style: GoogleFonts.poppins(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Sign in to continue your journey',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Form section with themed card effect
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow
                                    .withOpacity(isDarkMode ? 0.3 : 0.2),
                                blurRadius: 15,
                                spreadRadius: 5,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Form title
                                Text(
                                  'Sign In',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please enter your credentials to continue',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color:
                                        colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Email field with icon
                                ModernTextField(
                                  controller: emailController,
                                  hintText: 'Email address',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Password field with icon
                                ModernTextField(
                                  controller: passwordController,
                                  hintText: 'Password',
                                  obscureText: true,
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),

                                // Login button
                                AnimatedButton(
                                  text: "Sign In",
                                  onTap: _isLoading ? null : () => _signIn(),
                                  isLoading: _isLoading,
                                ),

                                const Spacer(),

                                // Register link
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: GoogleFonts.poppins(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const RegisterPage(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Register",
                                            style: GoogleFonts.poppins(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Google Sign In button
                                const SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            setState(() => _isLoading = true);
                                            try {
                                              final result = await AuthService()
                                                  .signInWithGoogle();

                                              if (!mounted) return;
                                              setState(
                                                  () => _isLoading = false);

                                              if (result != null) {
                                                if (mounted) {
                                                  Navigator.of(context)
                                                      .pushNamedAndRemoveUntil(
                                                    AppRoutes.bottomNavBar,
                                                    (route) => false,
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              setState(
                                                  () => _isLoading = false);
                                              if (mounted) {
                                                AppSnackBar.show(
                                                  context: context,
                                                  message:
                                                      'Failed to sign in with Google.',
                                                  type: SnackBarType.error,
                                                );
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      // backgroundColor: colorScheme.secondary,
                                      // foregroundColor: colorScheme.primary,
                                      elevation: 1,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: colorScheme.outline
                                              .withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Google logo that adapts to theme
                                        Container(
                                          height: 24,
                                          width: 24,
                                          decoration: BoxDecoration(
                                            color: colorScheme.secondary,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              AppMedia.google,
                                              height: 12,
                                              width: 12,
                                            ),
                                          ),
                                        ),
                                        // const SizedBox(width: 12),
                                        // Text(
                                        //   'Sign in with Google',
                                        //   style: GoogleFonts.poppins(
                                        //     fontSize: 14,
                                        //     fontWeight: FontWeight.w500,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
