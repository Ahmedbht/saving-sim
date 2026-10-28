import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/goal_repository.dart';
import '../models/currency.dart';
import '../models/goal.dart';
import '../models/goal_category.dart';
import '../services/savings_calculator.dart';

/// Single source of truth for goals and settings.
class GoalsStore extends ChangeNotifier {
  GoalsStore(this._repo, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final GoalRepository _repo;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  List<Goal> _goals = [];
  Currency _currency = Currency.usd;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isLoaded = false;

  List<Goal> get goals => List.unmodifiable(_goals);
  Currency get currency => _currency;
  ThemeMode get themeMode => _themeMode;
  bool get isLoaded => _isLoaded;
  DateTime get now => _clock();

  Goal? byId(String id) => _goals.where((g) => g.id == id).firstOrNull;

  double get totalSaved => _goals.fold(0, (sum, g) => sum + g.savedAmount);
  double get totalTarget => _goals.fold(0, (sum, g) => sum + g.targetAmount);
  double get totalMonthly =>
      _goals.fold(0, (sum, g) => sum + g.monthlyContribution);
  double get overallProgress =>
      totalTarget == 0 ? 0 : (totalSaved / totalTarget).clamp(0.0, 1.0);

  /// The active goal that will be finished soonest at its current pace.
  ({Goal goal, int months})? get nextFinish {
    ({Goal goal, int months})? best;
    for (final g in _goals.where((g) => !g.isComplete)) {
      final months = SavingsCalculator.forGoal(g).monthsToTarget;
      if (months != null && (best == null || months < best.months)) {
        best = (goal: g, months: months);
      }
    }
    return best;
  }

  Future<void> load() async {
    final stored = await _repo.loadGoals();
    _goals = stored ?? _sampleGoals();
    if (stored == null) await _repo.saveGoals(_goals);
    _currency = await _repo.loadCurrency() ?? Currency.usd;
    _themeMode = await _repo.loadThemeMode() ?? ThemeMode.dark;
    _isLoaded = true;
    notifyListeners();
  }

  Goal create({
    required String name,
    required GoalCategory category,
    required double targetAmount,
    required double savedAmount,
    required double monthlyContribution,
    required double annualReturnRate,
  }) {
    final goal = Goal(
      id: _uuid.v4(),
      name: name,
      category: category,
      targetAmount: targetAmount,
      savedAmount: savedAmount,
      monthlyContribution: monthlyContribution,
      annualReturnRate: annualReturnRate,
      createdAt: _clock(),
    );
    _goals = [goal, ..._goals];
    _persist();
    return goal;
  }

  void update(Goal goal) {
    _goals = [for (final g in _goals) g.id == goal.id ? goal : g];
    _persist();
  }

  /// Returns the removed goal's index so the caller can offer undo.
  int remove(String id) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return -1;
    _goals = [..._goals]..removeAt(index);
    _persist();
    return index;
  }

  void restore(Goal goal, int index) {
    _goals = [..._goals]..insert(index.clamp(0, _goals.length), goal);
    _persist();
  }

  void addDeposit(String goalId, double amount) {
    final goal = byId(goalId);
    if (goal == null || amount == 0) return;
    update(goal.copyWith(
      savedAmount: (goal.savedAmount + amount).clamp(0, double.infinity),
      deposits: [Deposit(amount: amount, date: _clock()), ...goal.deposits],
    ));
  }

  void setCurrency(Currency currency) {
    if (currency == _currency) return;
    _currency = currency;
    _repo.saveCurrency(currency);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _repo.saveThemeMode(mode);
    notifyListeners();
  }

  void _persist() {
    notifyListeners();
    _repo.saveGoals(_goals);
  }

  /// Seeded on first launch so the app never opens to a blank screen.
  List<Goal> _sampleGoals() {
    final now = _clock();
    DateTime ago(int days) => now.subtract(Duration(days: days));
    return [
      Goal(
        id: _uuid.v4(),
        name: 'Emergency fund',
        category: GoalCategory.emergency,
        targetAmount: 10000,
        savedAmount: 6200,
        monthlyContribution: 400,
        annualReturnRate: 4,
        createdAt: ago(240),
        deposits: [
          Deposit(amount: 400, date: ago(3)),
          Deposit(amount: 400, date: ago(33)),
          Deposit(amount: 250, date: ago(48)),
        ],
      ),
      Goal(
        id: _uuid.v4(),
        name: 'Tesla Model 3',
        category: GoalCategory.car,
        targetAmount: 42000,
        savedAmount: 11500,
        monthlyContribution: 850,
        annualReturnRate: 5,
        createdAt: ago(400),
        deposits: [
          Deposit(amount: 850, date: ago(5)),
          Deposit(amount: 850, date: ago(35)),
        ],
      ),
      Goal(
        id: _uuid.v4(),
        name: 'Japan trip',
        category: GoalCategory.travel,
        targetAmount: 5500,
        savedAmount: 1800,
        monthlyContribution: 300,
        annualReturnRate: 0,
        createdAt: ago(90),
      ),
      Goal(
        id: _uuid.v4(),
        name: 'First home deposit',
        category: GoalCategory.home,
        targetAmount: 80000,
        savedAmount: 14000,
        monthlyContribution: 1100,
        annualReturnRate: 6.5,
        createdAt: ago(700),
      ),
    ];
  }
}
