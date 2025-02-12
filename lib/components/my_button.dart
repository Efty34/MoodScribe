import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isSecondary;

  const MyButton({
    super.key,
    required this.text,
    this.onTap,
    this.isSecondary = false, required bool isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSecondary
              ? null
              : LinearGradient(
                  colors: [
                    Colors.blue.shade600,
                    Colors.blue.shade700,
                  ],
                ),
          color: onTap == null ? Colors.grey : isSecondary ? Colors.grey[200] : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSecondary
              ? null
              : [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: onTap == null ? Colors.grey : isSecondary ? Colors.grey[800] : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
