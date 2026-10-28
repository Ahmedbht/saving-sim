import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/format/formatters.dart';
import '../../core/theme/app_palette.dart';
import '../../state/goals_store.dart';
import '../../widgets/goal_card.dart';
import '../goal_detail/goal_detail_screen.dart';
import '../goal_editor/goal_editor_screen.dart';
import '../settings/settings_sheet.dart';
import 'overview_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GoalsStore>();
    final money = Money(store.currency);
    final goals = store.goals;
    final text = Theme.of(context).textTheme;
    final p = context.palette;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newGoal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New goal'),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              sliver: SliverToBoxAdapter(child: _Header(now: store.now)),
            ),
            if (goals.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: OverviewCard(store: store, money: money),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text('Your goals', style: text.titleLarge),
                    const SizedBox(width: 8),
                    if (goals.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: p.surfaceRaised,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${goals.length}',
                          style: text.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (goals.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(onCreate: () => _newGoal(context)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                sliver: SliverList.separated(
                  itemCount: goals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _StaggeredEntrance(
                    index: i,
                    child: GoalCard(
                      key: ValueKey(goals[i].id),
                      goal: goals[i],
                      money: money,
                      now: store.now,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              GoalDetailScreen(goalId: goals[i].id),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _newGoal(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const GoalEditorScreen(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.now});

  final DateTime now;

  String get _greeting => switch (now.hour) {
        < 12 => 'Good morning',
        < 18 => 'Good afternoon',
        _ => 'Good evening',
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatLongDate(now).toUpperCase(),
                style: text.labelSmall?.copyWith(
                  color: p.textMuted,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(_greeting, style: text.headlineSmall),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => SettingsSheet.show(context),
          style: IconButton.styleFrom(
            backgroundColor: p.surface,
            side: BorderSide(color: p.border),
            fixedSize: const Size.square(48),
          ),
          icon: Icon(Icons.tune_rounded, color: p.textPrimary),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: p.brandGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start your first goal',
            style: text.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pick something you want — a car, a home, a trip — and '
            "we'll show you exactly when you'll get there.",
            style: text.bodyMedium?.copyWith(color: p.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create a goal'),
          ),
        ],
      ),
    );
  }
}

/// Slides + fades list items in with a small per-index delay.
class _StaggeredEntrance extends StatelessWidget {
  const _StaggeredEntrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.12).clamp(0.0, 0.6);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (delay * 1000).round()),
      curve: Interval(delay, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
