import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';

class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.colors,
    this.trackColor,
  });

  final double progress;
  final double height;
  final List<Color>? colors;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(height);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor ?? p.surfaceRaised,
        borderRadius: radius,
      ),
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => FractionallySizedBox(
          widthFactor: value,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(colors: colors ?? [p.brand, p.accent]),
            ),
          ),
        ),
      ),
    );
  }
}
