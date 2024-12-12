import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured =
        widget.obscureText; // Initialize with the provided obscureText value
  }

  void toggleObscureText() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: isObscured,
      maxLines: isObscured
          ? 1
          : null, // Single line for obscured text, multi-line otherwise
      style: GoogleFonts.manrope(
        color: Colors.grey[800],
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: GoogleFonts.manrope(
          color: Colors.grey[500],
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.brown,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.obscureText
            ? GestureDetector(
                onTap: toggleObscureText,
                child: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black.withOpacity(0.5),
                ),
              )
            : null,
      ),
    );
  }
}
