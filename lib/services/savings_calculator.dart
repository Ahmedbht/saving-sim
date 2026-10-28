import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/goal.dart';

@immutable
class ProjectionPoint {
  const ProjectionPoint({
    required this.month,
    required this.balance,
    required this.contributed,
  });

  final int month;

  /// Balance including growth.
  final double balance;

  /// What the saver put in themselves (starting balance + contributions).
  final double contributed;

  double get growth => balance - contributed;
}

@immutable
class Milestone {
  const Milestone({required this.fraction, required this.month});

  /// 0.25, 0.5, 0.75, 1.0
  final double fraction;

  /// Months from now until reached; `0` means already reached,
  /// `null` means not reachable at the current pace.
  final int? month;

  bool get isReached => month == 0;
}

@immutable
class Projection {
  const Projection({
    required this.points,
    required this.monthsToTarget,
    required this.target,
  });

  /// One point per month starting at month 0 (today).
  final List<ProjectionPoint> points;

  /// `null` when the target can't be reached within [SavingsCalculator.maxMonths].
  final int? monthsToTarget;
  final double target;

  bool get isReachable => monthsToTarget != null;

  ProjectionPoint get last => points.last;

  /// New money the saver still has to add (excludes today's balance).
  double get futureContributions => last.contributed - points.first.contributed;

  /// Growth earned from interest/returns by the end of the projection.
  double get interestEarned => last.growth;

  DateTime? completionDate([DateTime? from]) => monthsToTarget == null
      ? null
      : SavingsCalculator.addMonths(from ?? DateTime.now(), monthsToTarget!);

  List<Milestone> milestones({
    List<double> fractions = const [0.25, 0.5, 0.75, 1.0],
  }) {
    return [
      for (final f in fractions)
        Milestone(
          fraction: f,
          month: points
              .where((p) => p.balance >= target * f - 0.005)
              .map((p) => p.month)
              .firstOrNull,
        ),
    ];
  }
}

/// Pure, deterministic savings math. No Flutter widgets, no I/O — easy to test.
abstract final class SavingsCalculator {
  /// 100 years. Anything longer is "not reachable" for practical purposes.
  static const maxMonths = 1200;

  /// Simulates month-by-month growth with monthly compounding and an
  /// end-of-month contribution until [target] is hit.
  static Projection project({
    required double saved,
    required double monthly,
    required double annualRatePercent,
    required double target,
  }) {
    final r = annualRatePercent / 100 / 12;
    var balance = saved;
    var contributed = saved;
    final points = <ProjectionPoint>[
      ProjectionPoint(month: 0, balance: balance, contributed: contributed),
    ];

    if (balance >= target) {
      return Projection(points: points, monthsToTarget: 0, target: target);
    }

    final growing = monthly > 0 || (r > 0 && balance > 0);
    if (!growing) {
      return Projection(points: points, monthsToTarget: null, target: target);
    }

    for (var m = 1; m <= maxMonths; m++) {
      balance = balance * (1 + r) + monthly;
      contributed += monthly;
      points.add(
        ProjectionPoint(month: m, balance: balance, contributed: contributed),
      );
      // Tiny epsilon so floating-point noise doesn't add a phantom month.
      if (balance >= target - 0.005) {
        return Projection(points: points, monthsToTarget: m, target: target);
      }
    }
    return Projection(points: points, monthsToTarget: null, target: target);
  }

  static Projection forGoal(Goal goal, {double? monthlyOverride}) => project(
        saved: goal.savedAmount,
        monthly: monthlyOverride ?? goal.monthlyContribution,
        annualRatePercent: goal.annualReturnRate,
        target: goal.targetAmount,
      );

  /// Monthly contribution needed to reach [target] in exactly [months].
  static double requiredMonthly({
    required double saved,
    required double target,
    required int months,
    required double annualRatePercent,
  }) {
    if (months <= 0) return math.max(0, target - saved);
    final r = annualRatePercent / 100 / 12;
    if (r == 0) return math.max(0, (target - saved) / months);
    final growth = math.pow(1 + r, months);
    final needed = (target - saved * growth) * r / (growth - 1);
    return math.max(0, needed.toDouble());
  }

  /// Calendar-safe month addition (Jan 31 + 1 month = Feb 28/29).
  static DateTime addMonths(DateTime from, int months) {
    final totalMonths = from.month - 1 + months;
    final year = from.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, math.min(from.day, lastDay));
  }
}
