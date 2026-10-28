import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_sim/data/goal_repository.dart';
import 'package:savings_sim/models/currency.dart';
import 'package:savings_sim/models/goal.dart';
import 'package:savings_sim/models/goal_category.dart';
import 'package:savings_sim/state/goals_store.dart';

void main() {
  final fixedNow = DateTime(2026, 10, 28, 9);

  Future<(GoalsStore, InMemoryGoalRepository)> makeStore({
    List<Goal>? goals,
  }) async {
    final repo = InMemoryGoalRepository(goals: goals);
    final store = GoalsStore(repo, clock: () => fixedNow);
    await store.load();
    return (store, repo);
  }

  test('first launch seeds sample goals and persists them', () async {
    final (store, repo) = await makeStore();
    expect(store.goals, isNotEmpty);
    expect(repo.goals, hasLength(store.goals.length));
  });

  test('an explicitly empty list stays empty', () async {
    final (store, _) = await makeStore(goals: []);
    expect(store.goals, isEmpty);
  });

  test('create / update / remove / restore round-trip', () async {
    final (store, repo) = await makeStore(goals: []);

    final goal = store.create(
      name: 'Laptop',
      category: GoalCategory.tech,
      targetAmount: 2000,
      savedAmount: 500,
      monthlyContribution: 250,
      annualReturnRate: 0,
    );
    expect(repo.goals!.single.name, 'Laptop');

    store.update(goal.copyWith(targetAmount: 2500));
    expect(store.byId(goal.id)!.targetAmount, 2500);

    final removed = store.byId(goal.id)!;
    final index = store.remove(goal.id);
    expect(store.goals, isEmpty);

    store.restore(removed, index);
    expect(store.goals.single.targetAmount, 2500);
  });

  test('deposits update the balance and history; withdrawals floor at 0',
      () async {
    final (store, _) = await makeStore(goals: []);
    final goal = store.create(
      name: 'Trip',
      category: GoalCategory.travel,
      targetAmount: 1000,
      savedAmount: 100,
      monthlyContribution: 50,
      annualReturnRate: 0,
    );

    store.addDeposit(goal.id, 400);
    expect(store.byId(goal.id)!.savedAmount, 500);
    expect(store.byId(goal.id)!.deposits.first.amount, 400);

    store.addDeposit(goal.id, -9999);
    expect(store.byId(goal.id)!.savedAmount, 0);
  });

  test('totals and next finish', () async {
    final (store, _) = await makeStore(goals: [
      _goal('a', target: 1000, saved: 500, monthly: 100), // 5 months
      _goal('b', target: 4000, saved: 1000, monthly: 100), // 30 months
    ]);
    expect(store.totalSaved, 1500);
    expect(store.totalTarget, 5000);
    expect(store.totalMonthly, 200);
    expect(store.overallProgress, closeTo(0.3, 1e-9));
    expect(store.nextFinish!.goal.id, 'a');
    expect(store.nextFinish!.months, 5);
  });

  test('settings persist', () async {
    final (store, repo) = await makeStore(goals: []);
    store.setCurrency(Currency.mad);
    store.setThemeMode(ThemeMode.light);
    expect(repo.currency, Currency.mad);
    expect(repo.themeMode, ThemeMode.light);
  });

  test('Goal JSON round-trip', () {
    final g = _goal('x', target: 10, saved: 2, monthly: 1).copyWith(
      deposits: [Deposit(amount: 5, date: DateTime(2026, 1, 2))],
    );
    final back = Goal.fromJson(g.toJson());
    expect(back.toJson(), g.toJson());
  });
}

Goal _goal(
  String id, {
  required double target,
  required double saved,
  required double monthly,
}) =>
    Goal(
      id: id,
      name: id,
      category: GoalCategory.other,
      targetAmount: target,
      savedAmount: saved,
      monthlyContribution: monthly,
      annualReturnRate: 0,
      createdAt: DateTime(2026),
    );
