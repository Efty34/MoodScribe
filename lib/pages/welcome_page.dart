import 'package:diary/components/my_button.dart';
import 'package:diary/utils/app_routes.dart';
import 'package:diary/utils/media.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to the Login Page
    void goToLogin() {
      Navigator.of(context).pushNamed(AppRoutes.loginPage);
    }

    // Navigate to the Register Page
    void goToRegister() {
      Navigator.of(context).pushNamed(AppRoutes.loginPage);
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppMedia.bg), // Path to background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Capture your",
                  style: GoogleFonts.dancingScript(
                    fontSize: 34,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Mind's whispers.",
                  style: GoogleFonts.dancingScript(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyButton(
                      text: "Sign In",
                      onTap: goToLogin, // Navigate to Login
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: goToRegister, // Navigate to Register
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AppRoutes.registerPage);
                        },
                        child: Text(
                          "Create an account",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
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
    );
  }
}
