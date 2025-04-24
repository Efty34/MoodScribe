import 'package:flutter/material.dart';

class ChartContainer extends StatelessWidget {
  final Widget child;
  final Color shadowColor;

  const ChartContainer({
    super.key,
    required this.child,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? shadowColor.withOpacity(0.15)
                : shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: child,
    );
  }
}
