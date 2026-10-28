import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/format/formatters.dart';
import '../../core/theme/app_palette.dart';
import '../../models/goal.dart';
import '../../models/goal_category.dart';
import '../../services/savings_calculator.dart';
import '../../state/goals_store.dart';
import '../../widgets/amount_field.dart';

/// Create a new goal, or edit [goal] when provided.
class GoalEditorScreen extends StatefulWidget {
  const GoalEditorScreen({super.key, this.goal});

  final Goal? goal;

  @override
  State<GoalEditorScreen> createState() => _GoalEditorScreenState();
}

class _GoalEditorScreenState extends State<GoalEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _saved;
  late final TextEditingController _monthly;
  late GoalCategory _category;
  late double _rate;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _name = TextEditingController(text: g?.name ?? '');
    _target = TextEditingController(text: formatAmountInput(g?.targetAmount ?? 0));
    _saved = TextEditingController(text: formatAmountInput(g?.savedAmount ?? 0));
    _monthly = TextEditingController(
      text: formatAmountInput(g?.monthlyContribution ?? 0),
    );
    _category = g?.category ?? GoalCategory.car;
    _rate = g?.annualReturnRate ?? 4;
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _saved.dispose();
    _monthly.dispose();
    super.dispose();
  }

  Projection? get _preview {
    final target = parseAmount(_target.text);
    if (target <= 0) return null;
    return SavingsCalculator.project(
      saved: parseAmount(_saved.text),
      monthly: parseAmount(_monthly.text),
      annualRatePercent: _rate,
      target: target,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    final store = context.read<GoalsStore>();
    final name = _name.text.trim().isEmpty ? _category.label : _name.text.trim();
    final target = parseAmount(_target.text);
    final saved = parseAmount(_saved.text);
    final monthly = parseAmount(_monthly.text);

    if (_isEditing) {
      store.update(widget.goal!.copyWith(
        name: name,
        category: _category,
        targetAmount: target,
        savedAmount: saved,
        monthlyContribution: monthly,
        annualReturnRate: _rate,
      ));
    } else {
      store.create(
        name: name,
        category: _category,
        targetAmount: target,
        savedAmount: saved,
        monthlyContribution: monthly,
        annualReturnRate: _rate,
      );
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GoalsStore>();
    final currency = store.currency;
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? 'Edit goal' : 'New goal'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _submit,
            child: Text(_isEditing ? 'Save changes' : 'Create goal'),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            _Label('What are you saving for?'),
            const SizedBox(height: 12),
            _CategoryPicker(
              selected: _category,
              onChanged: (c) {
                HapticFeedback.selectionClick();
                setState(() => _category = c);
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              maxLength: 40,
              decoration: InputDecoration(
                labelText: 'Goal name',
                hintText: 'e.g. ${_category.label}',
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            _Label('The numbers'),
            const SizedBox(height: 12),
            AmountField(
              controller: _target,
              label: 'Target amount',
              currency: currency,
              validator: (v) =>
                  parseAmount(v ?? '') <= 0 ? 'Enter how much you need' : null,
            ),
            const SizedBox(height: 14),
            AmountField(
              controller: _saved,
              label: 'Already saved',
              currency: currency,
            ),
            const SizedBox(height: 14),
            AmountField(
              controller: _monthly,
              label: 'Monthly contribution',
              currency: currency,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _Label('Expected annual return')),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.brand.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formatRate(_rate),
                    style: text.labelLarge?.copyWith(color: p.brand),
                  ),
                ),
              ],
            ),
            Slider(
              value: _rate,
              min: 0,
              max: 12,
              divisions: 24,
              label: formatRate(_rate),
              onChanged: (v) => setState(() => _rate = v),
            ),
            Text(
              _rateHint(_rate),
              style: text.bodySmall,
            ),
            const SizedBox(height: 24),
            _PreviewCard(projection: _preview, now: store.now, money: Money(currency)),
          ],
        ),
      ),
    );
  }

  static String _rateHint(double rate) => switch (rate) {
        0 => 'Cash savings with no interest.',
        <= 3 => 'Typical of a standard savings account.',
        <= 5 => 'Typical of a high-yield savings account.',
        <= 8 => 'Long-run average of a diversified index fund (not guaranteed).',
        _ => 'Aggressive — higher returns usually mean higher risk.',
      };
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleSmall);
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.selected, required this.onChanged});

  final GoalCategory selected;
  final ValueChanged<GoalCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in GoalCategory.values)
          _CategoryChip(
            category: c,
            selected: c == selected,
            palette: p,
            onTap: () => onChanged(c),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final GoalCategory category;
  final bool selected;
  final AppPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.16)
                : palette.surfaceRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 18,
                color: selected ? color : palette.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                category.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? palette.textPrimary : palette.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.projection,
    required this.now,
    required this.money,
  });

  final Projection? projection;
  final DateTime now;
  final Money money;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final proj = projection;

    final (IconData icon, Color color, String title, String body) = switch (proj) {
      null => (
          Icons.auto_graph_rounded,
          p.textMuted,
          'Live forecast',
          'Enter a target amount to see when you’ll reach it.',
        ),
      Projection(monthsToTarget: 0) => (
          Icons.celebration_rounded,
          p.success,
          'Already there!',
          'You’ve already saved enough for this goal.',
        ),
      Projection(monthsToTarget: null) => (
          Icons.warning_amber_rounded,
          p.warning,
          'Not reachable yet',
          'Add a monthly contribution or a starting balance to build a plan.',
        ),
      Projection(monthsToTarget: final m?) => (
          Icons.flag_rounded,
          p.brand,
          formatMonthsLong(m),
          'You’ll reach your goal around '
              '${formatMonthYear(SavingsCalculator.addMonths(now, m))}'
              '${proj.interestEarned > 1 ? ', with ${money.format(proj.interestEarned)} coming from returns.' : '.'}',
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: text.bodyMedium?.copyWith(color: p.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
