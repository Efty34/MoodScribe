import 'package:flutter/material.dart';

class SharedAxisPageRoute extends PageRouteBuilder {
  final Widget page;

  SharedAxisPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                child,
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: Tween<double>(
                        begin: 1.0,
                        end: 0.0,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                        ),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
} 