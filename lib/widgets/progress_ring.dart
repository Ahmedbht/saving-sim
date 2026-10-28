import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';

/// Animated circular progress with a gradient sweep and rounded caps.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 180,
    this.strokeWidth = 14,
    this.colors,
    this.child,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color>? colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(
          progress: value,
          strokeWidth: strokeWidth,
          trackColor: p.surfaceRaised,
          colors: colors ?? [p.brand, p.accent],
        ),
        child: child,
      ),
      child: SizedBox.square(dimension: size, child: Center(child: child)),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.colors,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);

    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    final sweep = math.pi * 2 * progress;
    // The round start cap sits just *before* the arc. Start the gradient one
    // cap-width earlier so that cap gets the first color instead of wrapping
    // around to the last one.
    final cap = (strokeWidth / 2) / (arcRect.width / 2);
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.min(math.max(sweep + cap * 2, 0.01), math.pi * 2),
        colors: colors,
        transform: GradientRotation(-math.pi / 2 - cap),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(arcRect, -math.pi / 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.colors != colors;
}
