import 'package:flutter/material.dart';

import '../core/format/formatters.dart';
import '../core/theme/app_palette.dart';
import '../models/goal.dart';
import '../services/savings_calculator.dart';
import 'category_badge.dart';
import 'gradient_progress_bar.dart';
import 'surface_card.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.money,
    required this.now,
    this.onTap,
  });

  final Goal goal;
  final Money money;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final projection = SavingsCalculator.forGoal(goal);
    final months = projection.monthsToTarget;

    final (String status, Color statusColor) = switch (months) {
      0 => ('Goal reached', p.success),
      null => ('Off track — adjust your plan', p.warning),
      final m => (
          '${formatMonthYear(SavingsCalculator.addMonths(now, m))} · ${formatMonthsShort(m)}',
          p.textMuted,
        ),
    };

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Hero(
                tag: 'goal-badge-${goal.id}',
                child: CategoryBadge(category: goal.category),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (months != 0) ...[
                          Icon(
                            months == null
                                ? Icons.warning_amber_rounded
                                : Icons.flag_rounded,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatPercent(goal.progress),
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: goal.isComplete ? p.success : p.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GradientProgressBar(
            progress: goal.progress,
            colors: goal.isComplete
                ? [p.success, p.success]
                : [goal.category.color, p.accent],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: money.format(goal.savedAmount),
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '  of ${money.format(goal.targetAmount)}',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+${money.compact(goal.monthlyContribution)}/mo',
                style: text.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
