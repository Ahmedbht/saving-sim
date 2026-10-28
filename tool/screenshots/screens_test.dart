// Renders README screenshots with the real fonts.
// Run: flutter test tool/screenshots --update-goldens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:savings_sim/app.dart';
import 'package:savings_sim/data/goal_repository.dart';
import 'package:savings_sim/state/goals_store.dart';

Future<void> loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Future<GoalsStore> pumpApp(WidgetTester tester, ThemeMode mode, {bool seed = true}) async {
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final store = GoalsStore(InMemoryGoalRepository(goals: seed ? null : [], themeMode: mode),
      clock: () => DateTime(2026, 10, 28, 9));
  await store.load();
  await tester.pumpWidget(ChangeNotifierProvider.value(value: store, child: const HorizonApp()));
  await tester.pumpAndSettle();
  return store;
}

void shotTest(String name, Future<void> Function(WidgetTester) body) {
  testWidgets(name, (t) async {
    debugDisableShadows = false;
    try {
      await body(t);
    } finally {
      debugDisableShadows = true;
    }
  });
}

void main() {
  setUpAll(() async {
    await loadFont('PlusJakartaSans', [
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold'])
        'assets/fonts/PlusJakartaSans-$w.ttf',
    ]);
    await loadFont('MaterialIcons', [
      '${Platform.environment['HOME']}/develop/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  });

  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    shotTest('home ${mode.name}', (t) async {
      await pumpApp(t, mode);
      await expectLater(find.byType(HorizonApp), matchesGoldenFile('../../docs/screenshots/home_${mode.name}.png'));
    });
    shotTest('detail ${mode.name}', (t) async {
      await pumpApp(t, mode);
      await t.tap(find.text('Tesla Model 3'));
      await t.pumpAndSettle();
      await expectLater(find.byType(HorizonApp), matchesGoldenFile('../../docs/screenshots/detail_${mode.name}.png'));
    });
  }
  shotTest('editor', (t) async {
    await pumpApp(t, ThemeMode.dark);
    await t.tap(find.text('New goal'));
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextFormField, 'Goal name'), 'MacBook Pro');
    await t.enterText(find.widgetWithText(TextFormField, 'Target amount'), '3200');
    await t.enterText(find.widgetWithText(TextFormField, 'Already saved'), '450');
    await t.enterText(find.widgetWithText(TextFormField, 'Monthly contribution'), '250');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    await expectLater(find.byType(HorizonApp), matchesGoldenFile('../../docs/screenshots/editor.png'));
  });
  shotTest('what-if', (t) async {
    await pumpApp(t, ThemeMode.dark);
    await t.tap(find.text('Tesla Model 3'));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('What if I saved…'), 300);
    await t.drag(find.byType(ListView), const Offset(0, -300));
    await t.pumpAndSettle();
    final r = t.getRect(find.byType(Slider));
    await t.tapAt(Offset(r.left + r.width * 0.55, r.center.dy));
    await t.pumpAndSettle();
    await t.drag(find.byType(ListView), const Offset(0, 420));
    await t.pumpAndSettle();
    await expectLater(find.byType(HorizonApp), matchesGoldenFile('../../docs/screenshots/whatif.png'));
  });
  shotTest('sheets', (t) async {
    await pumpApp(t, ThemeMode.dark);
    await t.tap(find.byTooltip('Settings'));
    await t.pumpAndSettle();
    await expectLater(find.byType(HorizonApp), matchesGoldenFile('../../docs/screenshots/settings.png'));
  });
}
