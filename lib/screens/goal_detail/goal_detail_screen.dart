import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/format/formatters.dart';
import '../../core/theme/app_palette.dart';
import '../../models/goal.dart';
import '../../services/savings_calculator.dart';
import '../../state/goals_store.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/projection_chart.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/surface_card.dart';
import '../goal_editor/goal_editor_screen.dart';
import 'add_money_sheet.dart';
import 'what_if_card.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  /// Monthly amount being explored in the what-if card; `null` = no change.
  double? _whatIfMonthly;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GoalsStore>();
    final goal = store.byId(widget.goalId);
    // The goal was just deleted and this route is popping.
    if (goal == null) return const Scaffold();

    final money = Money(store.currency);
    final now = store.now;
    final projection = SavingsCalculator.forGoal(goal);
    final whatIf = _whatIfMonthly == null ||
            _whatIfMonthly == goal.monthlyContribution
        ? null
        : SavingsCalculator.forGoal(goal, monthlyOverride: _whatIfMonthly);

    final p = context.palette;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.category.label),
        actions: [
          IconButton(
            tooltip: 'Edit goal',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => GoalEditorScreen(goal: goal),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete goal',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(goal),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            onPressed: () => AddMoneySheet.show(context, goal: goal),
            icon: const Icon(Icons.add_card_rounded),
            label: const Text('Add money'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _Hero(goal: goal, money: money),
          const SizedBox(height: 20),
          Center(child: _StatusPill(projection: projection, now: now)),
          const SizedBox(height: 24),
          _StatsGrid(goal: goal, projection: projection, money: money),
          const SizedBox(height: 16),
          SurfaceCard(
            title: 'Projection',
            trailing: Text(
              '${formatRate(goal.annualReturnRate)} / yr',
              style: text.labelMedium?.copyWith(color: p.textMuted),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProjectionChart(
                  projection: projection,
                  comparison: whatIf,
                  money: money,
                  start: now,
                ),
                const SizedBox(height: 14),
                ChartLegend(
                  items: [
                    ('Balance', p.brand, dashed: false),
                    ('You put in', p.textMuted, dashed: true),
                    if (whatIf != null) ('What-if', p.accent, dashed: false),
                  ],
                ),
              ],
            ),
          ),
          if (!goal.isComplete) ...[
            const SizedBox(height: 16),
            WhatIfCard(
              goal: goal,
              baseline: projection,
              monthly: _whatIfMonthly ?? goal.monthlyContribution,
              money: money,
              now: now,
              onChanged: (v) => setState(() => _whatIfMonthly = v),
              onApply: () {
                HapticFeedback.mediumImpact();
                store.update(goal.copyWith(monthlyContribution: _whatIfMonthly));
                setState(() => _whatIfMonthly = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New monthly plan saved')),
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          _Milestones(projection: projection, goal: goal, money: money, now: now),
          const SizedBox(height: 16),
          _Activity(goal: goal, money: money),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Goal goal) async {
    final p = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this goal?'),
        content: Text(
          '“${goal.name}” and its history will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: p.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final store = context.read<GoalsStore>();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    final index = store.remove(goal.id);
    HapticFeedback.mediumImpact();
    messenger.showSnackBar(
      SnackBar(
        content: Text('“${goal.name}” deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => store.restore(goal, index),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.goal, required this.money});

  final Goal goal;
  final Money money;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        ProgressRing(
          progress: goal.progress,
          size: 196,
          strokeWidth: 16,
          colors: goal.isComplete
              ? [p.success, p.success]
              : [goal.category.color, p.accent],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'goal-badge-${goal.id}',
                child: CategoryBadge(category: goal.category, size: 40),
              ),
              const SizedBox(height: 8),
              Text(
                formatPercent(goal.progress),
                style: text.headlineMedium,
              ),
              Text('complete', style: text.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          goal.name,
          style: text.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: money.format(goal.savedAmount),
                style: TextStyle(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(text: ' of ${money.format(goal.targetAmount)}'),
            ],
          ),
          style: text.bodyLarge?.copyWith(color: p.textMuted),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.projection, required this.now});

  final Projection projection;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (IconData icon, Color color, String label) = switch (projection.monthsToTarget) {
      0 => (Icons.celebration_rounded, p.success, 'Goal reached — nice work!'),
      null => (Icons.warning_amber_rounded, p.warning, 'Not reachable at this pace'),
      final m => (
          Icons.trending_up_rounded,
          p.brand,
          'On track for ${formatMonthYear(SavingsCalculator.addMonths(now, m))}',
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.goal,
    required this.projection,
    required this.money,
  });

  final Goal goal;
  final Projection projection;
  final Money money;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final months = projection.monthsToTarget;
    final reachable = projection.isReachable;
    final tiles = [
      StatTile(
        icon: Icons.schedule_rounded,
        label: 'Time left',
        value: months == null ? '—' : formatMonthsShort(months),
        color: p.brand,
      ),
      StatTile(
        icon: Icons.flag_rounded,
        label: 'Still to go',
        value: money.format(goal.remaining),
        color: goal.category.color,
      ),
      StatTile(
        icon: Icons.account_balance_wallet_rounded,
        label: 'You’ll add',
        value: reachable ? money.format(projection.futureContributions) : '—',
        color: p.warning,
      ),
      StatTile(
        icon: Icons.auto_graph_rounded,
        label: 'From returns',
        value: reachable ? money.format(projection.interestEarned) : '—',
        color: p.success,
      ),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: tiles[0]),
            const SizedBox(width: 12),
            Expanded(child: tiles[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: tiles[2]),
            const SizedBox(width: 12),
            Expanded(child: tiles[3]),
          ],
        ),
      ],
    );
  }
}

class _Milestones extends StatelessWidget {
  const _Milestones({
    required this.projection,
    required this.goal,
    required this.money,
    required this.now,
  });

  final Projection projection;
  final Goal goal;
  final Money money;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final milestones = projection.milestones();

    return SurfaceCard(
      title: 'Milestones',
      child: Column(
        children: [
          for (final (i, m) in milestones.indexed)
            _MilestoneRow(
              isLast: i == milestones.length - 1,
              reached: m.isReached,
              title: m.fraction == 1
                  ? 'Goal complete'
                  : '${(m.fraction * 100).round()}% saved',
              subtitle: money.format(goal.targetAmount * m.fraction),
              trailing: switch (m.month) {
                0 => 'Reached',
                null => '—',
                final month => formatMonthYear(
                    SavingsCalculator.addMonths(now, month),
                  ),
              },
              palette: p,
              text: text,
            ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.isLast,
    required this.reached,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.palette,
    required this.text,
  });

  final bool isLast;
  final bool reached;
  final String title;
  final String subtitle;
  final String trailing;
  final AppPalette palette;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reached ? p.success : Colors.transparent,
                  border: Border.all(
                    color: reached ? p.success : p.border,
                    width: 2,
                  ),
                ),
                child: reached
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: reached ? p.success.withValues(alpha: 0.5) : p.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleSmall),
                  Text(subtitle, style: text.bodySmall),
                ],
              ),
            ),
          ),
          Text(
            trailing,
            style: text.labelLarge?.copyWith(
              color: reached ? p.success : p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Activity extends StatelessWidget {
  const _Activity({required this.goal, required this.money});

  final Goal goal;
  final Money money;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final recent = goal.deposits.take(6).toList();

    return SurfaceCard(
      title: 'Recent activity',
      child: recent.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No deposits yet. Tap “Add money” to log one.',
                style: text.bodySmall,
              ),
            )
          : Column(
              children: [
                for (final (i, d) in recent.indexed) ...[
                  if (i > 0) const Divider(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (d.amount >= 0 ? p.success : p.danger)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          d.amount >= 0
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded,
                          size: 16,
                          color: d.amount >= 0 ? p.success : p.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.amount >= 0 ? 'Deposit' : 'Withdrawal',
                              style: text.titleSmall,
                            ),
                            Text(formatDayMonth(d.date), style: text.bodySmall),
                          ],
                        ),
                      ),
                      Text(
                        '${d.amount >= 0 ? '+' : '−'}${money.format(d.amount.abs())}',
                        style: text.titleSmall?.copyWith(
                          color: d.amount >= 0 ? p.success : p.danger,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
