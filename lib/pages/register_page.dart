import 'package:diary/auth/auth_service.dart';
import 'package:diary/components/animate_button.dart';
import 'package:diary/components/modern_text_field.dart';
import 'package:diary/pages/login_page.dart';
import 'package:diary/utils/app_snackbar.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text field controllers
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      AppSnackBar.show(
        context: context,
        message: 'Passwords do not match',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await AuthService().signUpWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      username: userNameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error != null && mounted) {
      AppSnackBar.show(
        context: context,
        message: error,
        type: SnackBarType.error,
        actionLabel: 'Try Again',
        onAction: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      );
    } else if (mounted) {
      // Clear all text fields
      userNameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      // Show success message
      AppSnackBar.show(
        context: context,
        message: 'Registration successful! Please login.',
        type: SnackBarType.success,
      );

      // Navigate to login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Top Image and Welcome Section
          Container(
            height: MediaQuery.of(context).size.height *
                0.35, // Slightly smaller than login
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppMedia.registerbg),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your journey with us',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Registration Form Section
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ModernTextField(
                        controller: userNameController,
                        hintText: 'Username',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        controller: emailController,
                        hintText: 'Enter Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.blue,
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
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      AnimatedButton(
                        text: "Sign Up",
                        onTap: _isLoading ? null : () => _signUp(),
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already a member? ",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Login",
                                      style: GoogleFonts.poppins(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.blue[700],
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
