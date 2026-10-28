import 'package:flutter/material.dart';

import '../../core/format/formatters.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../services/savings_calculator.dart';
import '../../state/goals_store.dart';
import '../../widgets/animated_amount.dart';
import '../../widgets/gradient_progress_bar.dart';

/// Gradient hero card summarising every goal.
class OverviewCard extends StatelessWidget {
  const OverviewCard({super.key, required this.store, required this.money});

  final GoalsStore store;
  final Money money;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    const onBrand = Colors.white;
    final onBrandMuted = Colors.white.withValues(alpha: 0.72);
    final next = store.nextFinish;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.brand, Color.lerp(p.brand, p.accent, 0.85)!],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius + 4),
        boxShadow: [
          BoxShadow(
            color: p.brand.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radius + 4),
        child: Stack(
          children: [
            // Soft decorative orbs.
            Positioned(
              right: -40,
              top: -60,
              child: _Orb(size: 180, opacity: 0.12),
            ),
            Positioned(
              right: 60,
              bottom: -70,
              child: _Orb(size: 140, opacity: 0.08),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total saved',
                        style: text.bodyMedium?.copyWith(color: onBrandMuted),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          formatPercent(store.overallProgress),
                          style: text.labelMedium?.copyWith(
                            color: onBrand,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AnimatedAmount(
                      value: store.totalSaved,
                      format: money.format,
                      style: text.displaySmall?.copyWith(color: onBrand),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'of ${money.format(store.totalTarget)} across '
                    '${store.goals.length} goal${store.goals.length == 1 ? '' : 's'}',
                    style: text.bodySmall?.copyWith(color: onBrandMuted),
                  ),
                  const SizedBox(height: 18),
                  GradientProgressBar(
                    progress: store.overallProgress,
                    height: 8,
                    trackColor: Colors.white.withValues(alpha: 0.2),
                    colors: const [Colors.white, Colors.white],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          icon: Icons.calendar_month_rounded,
                          label: 'Monthly plan',
                          value: money.format(store.totalMonthly),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _Metric(
                          icon: Icons.emoji_events_rounded,
                          label: 'Next finish',
                          value: next == null
                              ? '—'
                              : formatMonthYear(
                                  SavingsCalculator.addMonths(
                                    store.now,
                                    next.months,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: text.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
