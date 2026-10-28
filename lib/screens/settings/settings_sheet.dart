import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../models/currency.dart';
import '../../state/goals_store.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const SettingsSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GoalsStore>();
    final text = Theme.of(context).textTheme;
    final p = context.palette;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Settings', style: text.titleLarge),
            const SizedBox(height: 24),
            Text('APPEARANCE', style: _overline(text, p)),
            const SizedBox(height: 10),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_rounded),
                  label: Text('Auto'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('Dark'),
                ),
              ],
              selected: {store.themeMode},
              onSelectionChanged: (s) => store.setThemeMode(s.first),
            ),
            const SizedBox(height: 28),
            Text('CURRENCY', style: _overline(text, p)),
            const SizedBox(height: 10),
            Material(
              color: p.surfaceRaised,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final c in Currency.values)
                    ListTile(
                      onTap: () => store.setCurrency(c),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: p.surface,
                        child: Text(
                          c.symbol,
                          style: TextStyle(
                            color: p.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: c.symbol.length > 1 ? 10 : 15,
                          ),
                        ),
                      ),
                      title: Text(
                        c.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(c.code),
                      trailing: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: c == store.currency
                            ? Icon(
                                Icons.check_circle_rounded,
                                key: const ValueKey('on'),
                                color: p.brand,
                              )
                            : const SizedBox(key: ValueKey('off'), width: 24),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Amounts are shown in your chosen currency. Projections are '
              'estimates and assume returns are reinvested monthly.',
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  TextStyle? _overline(TextTheme text, AppPalette p) => text.labelSmall?.copyWith(
        color: p.textMuted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w800,
      );
}
