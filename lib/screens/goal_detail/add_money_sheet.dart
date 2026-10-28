import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/format/formatters.dart';
import '../../core/theme/app_palette.dart';
import '../../models/goal.dart';
import '../../state/goals_store.dart';
import '../../widgets/amount_field.dart';

class AddMoneySheet extends StatefulWidget {
  const AddMoneySheet({super.key, required this.goal});

  final Goal goal;

  static Future<void> show(BuildContext context, {required Goal goal}) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => AddMoneySheet(goal: goal),
      );

  @override
  State<AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<AddMoneySheet> {
  final _amount = TextEditingController();
  bool _withdraw = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseAmount(_amount.text);
    if (value <= 0) return;
    final store = context.read<GoalsStore>();
    final messenger = ScaffoldMessenger.of(context);
    final money = Money(store.currency);
    store.addDeposit(widget.goal.id, _withdraw ? -value : value);
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();

    final updated = store.byId(widget.goal.id);
    final justCompleted = !widget.goal.isComplete && (updated?.isComplete ?? false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          justCompleted
              ? '🎉 You reached “${widget.goal.name}”!'
              : '${_withdraw ? 'Withdrew' : 'Added'} ${money.format(value)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GoalsStore>();
    final money = Money(store.currency);
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final quick = {
      if (widget.goal.monthlyContribution > 0) widget.goal.monthlyContribution,
      50.0,
      100.0,
      500.0,
    }.toList()
      ..sort();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.goal.name, style: text.titleLarge),
              const SizedBox(height: 4),
              Text(
                '${money.format(widget.goal.savedAmount)} saved so far',
                style: text.bodySmall,
              ),
              const SizedBox(height: 20),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: false, label: Text('Deposit')),
                  ButtonSegment(value: true, label: Text('Withdraw')),
                ],
                selected: {_withdraw},
                onSelectionChanged: (s) => setState(() => _withdraw = s.first),
              ),
              const SizedBox(height: 16),
              AmountField(
                controller: _amount,
                label: 'Amount',
                currency: store.currency,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final q in quick)
                    ActionChip(
                      label: Text('+${money.format(q)}'),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      backgroundColor: p.surfaceRaised,
                      side: BorderSide(color: p.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        final next = parseAmount(_amount.text) + q;
                        _amount.text = formatAmountInput(next);
                        setState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: parseAmount(_amount.text) > 0 ? _submit : null,
                style: _withdraw
                    ? FilledButton.styleFrom(backgroundColor: p.danger)
                    : null,
                child: Text(_withdraw ? 'Withdraw' : 'Add to goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
