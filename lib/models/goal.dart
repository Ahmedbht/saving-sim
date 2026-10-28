import 'package:flutter/foundation.dart';

import 'goal_category.dart';

@immutable
class Deposit {
  const Deposit({required this.amount, required this.date});

  final double amount;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory Deposit.fromJson(Map<String, dynamic> json) => Deposit(
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
      );
}

@immutable
class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.category,
    required this.targetAmount,
    required this.savedAmount,
    required this.monthlyContribution,
    required this.annualReturnRate,
    required this.createdAt,
    this.deposits = const [],
  });

  final String id;
  final String name;
  final GoalCategory category;
  final double targetAmount;
  final double savedAmount;
  final double monthlyContribution;

  /// Expected yearly return in percent, e.g. `4.5` for 4.5 %.
  final double annualReturnRate;
  final DateTime createdAt;

  /// Manual top-ups, newest first.
  final List<Deposit> deposits;

  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  double get remaining =>
      (targetAmount - savedAmount).clamp(0.0, double.infinity);

  bool get isComplete => savedAmount >= targetAmount;

  Goal copyWith({
    String? name,
    GoalCategory? category,
    double? targetAmount,
    double? savedAmount,
    double? monthlyContribution,
    double? annualReturnRate,
    List<Deposit>? deposits,
  }) {
    return Goal(
      id: id,
      createdAt: createdAt,
      name: name ?? this.name,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      annualReturnRate: annualReturnRate ?? this.annualReturnRate,
      deposits: deposits ?? this.deposits,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'monthlyContribution': monthlyContribution,
        'annualReturnRate': annualReturnRate,
        'createdAt': createdAt.toIso8601String(),
        'deposits': deposits.map((d) => d.toJson()).toList(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        name: json['name'] as String,
        category: GoalCategory.fromName(json['category'] as String?),
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
        monthlyContribution: (json['monthlyContribution'] as num).toDouble(),
        annualReturnRate: (json['annualReturnRate'] as num? ?? 0).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        deposits: (json['deposits'] as List<dynamic>? ?? const [])
            .map((d) => Deposit.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}
