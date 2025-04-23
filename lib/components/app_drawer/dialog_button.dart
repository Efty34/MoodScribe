import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable button component for dialogs that supports both outlined and filled styles
class DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final bool isOutlined;

  const DialogButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isOutlined
                ? Colors.transparent
                : color ?? theme.colorScheme.primary,
            border: isOutlined
                ? Border.all(
                    color: isDark ? theme.dividerColor : theme.dividerColor,
                    width: 1.5,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isOutlined
                ? null
                : [
                    BoxShadow(
                      color: (color ?? theme.colorScheme.primary)
                          .withOpacity(isDark ? 0.3 : 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isOutlined
                  ? isDark
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface
                  : textColor ?? theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
