import 'package:diary/auth/auth_service.dart';
import 'package:diary/components/modern_text_field.dart';
import 'package:diary/components/my_button.dart';
import 'package:diary/pages/register_page.dart';
import 'package:diary/utils/app_routes.dart';
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
        // Show error with custom styling
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Connection error. Please check your internet.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppMedia.bg), // Path to background image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 80),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(150),
                  bottomRight: Radius.circular(150),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.face, size: 100, color: Colors.white),
                        const SizedBox(height: 40),
                        ModernTextField(
                          controller: emailController,
                          hintText: 'Enter Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.white.withOpacity(0.7),
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
                        const SizedBox(height: 16),
                        ModernTextField(
                          controller: passwordController,
                          hintText: 'Enter Password',
                          obscureText: true,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        MyButton(
                          text: _isLoading ? "Signing In..." : "Sign In",
                          onTap: _isLoading ? null : () => _signIn(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Not a member? ",
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                // Get the current scaffold background
                                final container = Container(
                                  decoration: BoxDecoration(
                                    // Your existing background decoration
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(150),
                                      bottomRight: Radius.circular(150),
                                    ),
                                  ),
                                );

                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 600),
                                    reverseTransitionDuration:
                                        const Duration(milliseconds: 600),
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return Stack(
                                        children: [
                                          // Keep the background constant
                                          container,
                                          // Animate only the content
                                          AnimatedBuilder(
                                            animation: animation,
                                            builder: (context, child) {
                                              return FadeTransition(
                                                opacity: Tween<double>(
                                                  begin: 0.0,
                                                  end: 1.0,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOut,
                                                  ),
                                                ),
                                                child: SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: const Offset(0, 0.1),
                                                    end: Offset.zero,
                                                  ).animate(
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve:
                                                          Curves.easeOutCubic,
                                                    ),
                                                  ),
                                                  child: const RegisterPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return child;
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                "Register Now",
                                style: GoogleFonts.poppins(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
