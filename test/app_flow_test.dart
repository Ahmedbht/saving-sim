import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:savings_sim/app.dart';
import 'package:savings_sim/data/goal_repository.dart';
import 'package:savings_sim/state/goals_store.dart';

Future<GoalsStore> pumpApp(WidgetTester tester, {bool seed = true}) async {
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final store = GoalsStore(
    InMemoryGoalRepository(goals: seed ? null : []),
    clock: () => DateTime(2026, 10, 28, 9),
  );
  await store.load();
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: store, child: const HorizonApp()),
  );
  await tester.pumpAndSettle();
  return store;
}

void main() {
  testWidgets('dashboard shows overview and seeded goals', (tester) async {
    await pumpApp(tester);
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Total saved'), findsOneWidget);
    expect(find.text('Emergency fund'), findsWidgets);
    expect(find.text('Japan trip'), findsOneWidget);
  });

  testWidgets('empty state offers to create a goal', (tester) async {
    await pumpApp(tester, seed: false);
    expect(find.text('Start your first goal'), findsOneWidget);
  });

  testWidgets('create a goal end-to-end', (tester) async {
    final store = await pumpApp(tester, seed: false);

    await tester.tap(find.text('New goal'));
    await tester.pumpAndSettle();

    // Validation blocks an empty target.
    await tester.tap(find.text('Create goal'));
    await tester.pumpAndSettle();
    expect(find.text('Enter how much you need'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Goal name'), 'MacBook');
    await tester.enterText(find.widgetWithText(TextFormField, 'Target amount'), '2400');
    await tester.enterText(find.widgetWithText(TextFormField, 'Monthly contribution'), '200');
    await tester.pumpAndSettle();

    // Live thousands formatting.
    expect(find.text('2,400'), findsOneWidget);

    await tester.tap(find.text('Create goal'));
    await tester.pumpAndSettle();

    expect(store.goals.single.name, 'MacBook');
    expect(store.goals.single.targetAmount, 2400);
    expect(find.text('MacBook'), findsOneWidget);
  });

  testWidgets('goal detail renders chart, what-if and milestones',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Japan trip'));
    await tester.pumpAndSettle();

    expect(find.text('Projection'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('What if I saved…'), 200);
    expect(find.text('What if I saved…'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Milestones'), 200);
    expect(find.text('Milestones'), findsOneWidget);
  });

  testWidgets('what-if slider previews a faster plan and can be applied',
      (tester) async {
    final store = await pumpApp(tester);
    final goal = store.goals.firstWhere((g) => g.name == 'Japan trip');

    await tester.tap(find.text('Japan trip'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('What if I saved…'), 200);
    await tester.pumpAndSettle();

    final slider = find.byType(Slider);
    final rect = tester.getRect(slider);
    await tester.tapAt(Offset(rect.right - 30, rect.center.dy));
    await tester.pumpAndSettle();

    expect(find.textContaining('sooner'), findsOneWidget);
    await tester.ensureVisible(find.text('Apply this plan'));
    await tester.tap(find.text('Apply this plan'));
    await tester.pumpAndSettle();

    expect(
      store.byId(goal.id)!.monthlyContribution,
      greaterThan(goal.monthlyContribution),
    );
  });

  testWidgets('deleting a goal can be undone', (tester) async {
    final store = await pumpApp(tester);
    final before = store.goals.length;

    await tester.tap(find.text('Japan trip'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(store.goals.length, before - 1);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(store.goals.length, before);
  });
}
