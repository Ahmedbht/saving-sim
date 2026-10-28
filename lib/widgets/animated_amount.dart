import 'package:flutter/material.dart';

/// Counts up/down to [value] whenever it changes.
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  final double value;
  final String Function(double) format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        format(v),
        style: style?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
