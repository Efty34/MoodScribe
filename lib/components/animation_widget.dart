import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A reusable Lottie animation widget with flexible configuration options
///
/// This widget provides a standardized way to display Lottie animations
/// throughout the app with customizable parameters.
class AnimationWidget extends StatelessWidget {
  /// The asset path to the Lottie animation file
  final String animationPath;

  /// Whether the animation should repeat
  final bool repeat;

  /// Whether the animation should play
  final bool animate;

  /// How the animation should be fitted within its container
  final BoxFit fit;

  /// Width of the animation
  final double? width;

  /// Height of the animation
  final double? height;

  /// Animation playback speed
  final double? speed;

  /// Callback when animation completes
  final Function()? onComplete;

  /// Optional widget to display when animation is loading or if there's an error
  final Widget? placeholder;

  /// Optional error widget
  final Widget? errorWidget;

  const AnimationWidget({
    super.key,
    required this.animationPath,
    this.repeat = true,
    this.animate = true,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.speed = 1.0,
    this.onComplete,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animationPath,
      fit: fit,
      repeat: repeat,
      animate: animate,
      width: width,
      height: height,
      frameRate: FrameRate.max,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['**'],
            value: Theme.of(context).brightness == Brightness.dark
                ? null // Use default colors in dark mode
                : null, // Use default colors in light mode too
          ),
        ],
      ),
      options: LottieOptions(
        enableMergePaths: true,
      ),
      onLoaded: (composition) {
        // Optional additional configuration when loaded
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Center(
              child: Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
            );
      },
      frameBuilder: (context, child, composition) {
        if (composition == null) {
          return placeholder ??
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
        }
        return child;
      },
    );
  }
}
