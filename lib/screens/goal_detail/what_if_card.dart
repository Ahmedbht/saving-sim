import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format/formatters.dart';
import '../../core/theme/app_palette.dart';
import '../../models/goal.dart';
import '../../services/savings_calculator.dart';
import '../../widgets/surface_card.dart';

/// Lets the user drag a monthly amount and instantly see how the finish date
/// moves. Nothing is saved until they tap "Apply".
class WhatIfCard extends StatelessWidget {
  const WhatIfCard({
    super.key,
    required this.goal,
    required this.baseline,
    required this.monthly,
    required this.money,
    required this.now,
    required this.onChanged,
    required this.onApply,
  });

  final Goal goal;
  final Projection baseline;
  final double monthly;
  final Money money;
  final DateTime now;
  final ValueChanged<double> onChanged;
  final VoidCallback onApply;

  /// Slider step that feels natural for the amounts involved.
  static double _step(double max) => switch (max) {
        <= 500 => 10,
        <= 2000 => 25,
        <= 10000 => 50,
        _ => 100,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    final rawMax = math.max(goal.monthlyContribution * 3, goal.remaining / 12);
    final step = _step(rawMax);
    final max = math.max(step, (rawMax / step).ceil() * step);
    final value = monthly.clamp(0.0, max);

    final scenario =
        SavingsCalculator.forGoal(goal, monthlyOverride: value);
    final changed = value != goal.monthlyContribution;

    final base = baseline.monthsToTarget;
    final next = scenario.monthsToTarget;
    final (String headline, Color color) = switch ((base, next)) {
      (_, null) => ('Not reachable at this amount', p.warning),
      (null, final n?) => ('Reachable in ${formatMonthsShort(n)}', p.success),
      (final b?, final n?) when n < b =>
        ('${formatMonthsShort(b - n)} sooner', p.success),
      (final b?, final n?) when n > b =>
        ('${formatMonthsShort(n - b)} later', p.warning),
      _ => ('Same as your current plan', p.textMuted),
    };

    return SurfaceCard(
      title: 'What if I saved…',
      trailing: changed
          ? TextButton(
              onPressed: () => onChanged(goal.monthlyContribution),
              child: const Text('Reset'),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money.format(value),
                style: text.headlineMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4),
                child: Text('/ month', style: text.bodySmall),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: max,
            divisions: (max / step).round(),
            onChanged: onChanged,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey('$headline$next'),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.surfaceRaised,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    changed ? Icons.bolt_rounded : Icons.info_outline_rounded,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headline,
                          style: text.titleSmall?.copyWith(color: color),
                        ),
                        if (next != null)
                          Text(
                            'Finish in ${formatMonthYear(SavingsCalculator.addMonths(now, next))}',
                            style: text.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: changed
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: OutlinedButton(
                      onPressed: onApply,
                      child: const Text('Apply this plan'),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
