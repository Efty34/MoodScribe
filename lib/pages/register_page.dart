import 'package:diary/components/my_button.dart';
import 'package:diary/components/my_text_field.dart';
import 'package:diary/utils/app_routes.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(150),
                bottomRight: Radius.circular(150),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.face, size: 100, color: Colors.white),
                    const SizedBox(height: 40),
                    MyTextField(
                        controller: userNameController,
                        hintText: "Username",
                        obscureText: false),
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: emailController,
                        hintText: "Enter Email",
                        obscureText: false),
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: passwordController,
                        hintText: "Enter Password",
                        obscureText: true),
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        obscureText: true),
                    const SizedBox(height: 20),
                    MyButton(
                      text: "Sign Up",
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Alrady a member? ",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.loginPage);
                          },
                          child: Text(
                            "Login",
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
        ],
      ),
    );
  }
}
