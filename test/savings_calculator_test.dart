import 'package:flutter_test/flutter_test.dart';
import 'package:savings_sim/core/format/formatters.dart';
import 'package:savings_sim/models/currency.dart';
import 'package:savings_sim/services/savings_calculator.dart';

void main() {
  group('SavingsCalculator.project', () {
    test('no interest: simple division, rounded up to whole months', () {
      final p = SavingsCalculator.project(
        saved: 0,
        monthly: 300,
        annualRatePercent: 0,
        target: 1000,
      );
      expect(p.monthsToTarget, 4); // 300, 600, 900, 1200
      expect(p.futureContributions, 1200);
      expect(p.interestEarned, 0);
    });

    test('exact multiples do not add a phantom month', () {
      final p = SavingsCalculator.project(
        saved: 0,
        monthly: 250,
        annualRatePercent: 0,
        target: 1000,
      );
      expect(p.monthsToTarget, 4);
    });

    test('starting balance counts toward the target', () {
      final p = SavingsCalculator.project(
        saved: 400,
        monthly: 200,
        annualRatePercent: 0,
        target: 1000,
      );
      expect(p.monthsToTarget, 3);
      expect(p.futureContributions, 600);
    });

    test('already at target → 0 months', () {
      final p = SavingsCalculator.project(
        saved: 5000,
        monthly: 0,
        annualRatePercent: 0,
        target: 5000,
      );
      expect(p.monthsToTarget, 0);
      expect(p.isReachable, isTrue);
    });

    test('nothing growing → unreachable', () {
      final p = SavingsCalculator.project(
        saved: 100,
        monthly: 0,
        annualRatePercent: 0,
        target: 5000,
      );
      expect(p.monthsToTarget, isNull);
      expect(p.isReachable, isFalse);
    });

    test('interest alone can reach the target', () {
      final p = SavingsCalculator.project(
        saved: 1000,
        monthly: 0,
        annualRatePercent: 12,
        target: 1100,
      );
      // 1% / month → 1000 · 1.01^n ≥ 1100 → n = 10
      expect(p.monthsToTarget, 10);
    });

    test('compound growth beats the no-interest plan and matches FV formula',
        () {
      final flat = SavingsCalculator.project(
        saved: 0,
        monthly: 500,
        annualRatePercent: 0,
        target: 60000,
      );
      final growing = SavingsCalculator.project(
        saved: 0,
        monthly: 500,
        annualRatePercent: 6,
        target: 60000,
      );
      expect(flat.monthsToTarget, 120);
      expect(growing.monthsToTarget, lessThan(120));
      expect(growing.interestEarned, greaterThan(0));

      // FV of an ordinary annuity: P·((1+r)^n − 1)/r with r = 0.5 %.
      final n = growing.monthsToTarget!;
      final balance = growing.points[n].balance;
      expect(balance, greaterThanOrEqualTo(60000 - 0.01));
      expect(growing.points[n - 1].balance, lessThan(60000));
    });

    test('very slow plans are capped at maxMonths', () {
      final p = SavingsCalculator.project(
        saved: 0,
        monthly: 1,
        annualRatePercent: 0,
        target: 1e9,
      );
      expect(p.monthsToTarget, isNull);
      expect(p.points.length, SavingsCalculator.maxMonths + 1);
    });
  });

  group('milestones', () {
    test('reports reached, future and final milestones', () {
      final p = SavingsCalculator.project(
        saved: 300,
        monthly: 100,
        annualRatePercent: 0,
        target: 1000,
      );
      final m = p.milestones();
      expect(m.map((e) => e.month), [0, 2, 5, 7]);
      expect(m.first.isReached, isTrue);
    });
  });

  group('requiredMonthly', () {
    test('no interest', () {
      expect(
        SavingsCalculator.requiredMonthly(
          saved: 1000,
          target: 13000,
          months: 24,
          annualRatePercent: 0,
        ),
        500,
      );
    });

    test('round-trips with project()', () {
      final monthly = SavingsCalculator.requiredMonthly(
        saved: 2000,
        target: 30000,
        months: 48,
        annualRatePercent: 5,
      );
      final p = SavingsCalculator.project(
        saved: 2000,
        monthly: monthly,
        annualRatePercent: 5,
        target: 30000,
      );
      expect(p.monthsToTarget, 48);
    });
  });

  group('addMonths', () {
    test('clamps to the last day of shorter months', () {
      expect(
        SavingsCalculator.addMonths(DateTime(2026, 1, 31), 1),
        DateTime(2026, 2, 28),
      );
      expect(
        SavingsCalculator.addMonths(DateTime(2028, 1, 31), 1),
        DateTime(2028, 2, 29),
      );
    });

    test('rolls over years', () {
      expect(
        SavingsCalculator.addMonths(DateTime(2026, 10, 15), 27),
        DateTime(2029, 1, 15),
      );
    });
  });

  group('formatters', () {
    test('month durations never show "12 months"', () {
      expect(formatMonthsShort(12), '1 yr');
      expect(formatMonthsShort(28), '2 yr 4 mo');
      expect(formatMonthsLong(13), '1 year and 1 month');
      expect(formatMonthsLong(24), '2 years');
    });

    test('money formatting per currency', () {
      expect(Money(Currency.usd).format(12400), r'$12,400');
      expect(Money(Currency.eur).compact(12400), '€12.4K');
      expect(Money(Currency.mad).format(1500), '1,500 MAD');
      expect(Money(Currency.gbp).compact(2000000), '£2M');
    });
  });
}
