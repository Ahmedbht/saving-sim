import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/currency.dart';
import '../models/goal.dart';

/// Storage boundary. The store only talks to this interface, so tests can
/// swap in [InMemoryGoalRepository].
abstract interface class GoalRepository {
  /// `null` means "never saved before" (first launch), not "empty list".
  Future<List<Goal>?> loadGoals();
  Future<void> saveGoals(List<Goal> goals);

  Future<Currency?> loadCurrency();
  Future<void> saveCurrency(Currency currency);

  Future<ThemeMode?> loadThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}

class SharedPrefsGoalRepository implements GoalRepository {
  SharedPrefsGoalRepository(this._prefs);

  static const _goalsKey = 'goals.v2';
  static const _currencyKey = 'settings.currency';
  static const _themeKey = 'settings.themeMode';

  final SharedPreferencesAsync _prefs;

  @override
  Future<List<Goal>?> loadGoals() async {
    final raw = await _prefs.getString(_goalsKey);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> saveGoals(List<Goal> goals) => _prefs.setString(
        _goalsKey,
        jsonEncode(goals.map((g) => g.toJson()).toList()),
      );

  @override
  Future<Currency?> loadCurrency() async {
    final code = await _prefs.getString(_currencyKey);
    return code == null ? null : Currency.fromCode(code);
  }

  @override
  Future<void> saveCurrency(Currency currency) =>
      _prefs.setString(_currencyKey, currency.code);

  @override
  Future<ThemeMode?> loadThemeMode() async {
    final name = await _prefs.getString(_themeKey);
    return ThemeMode.values.where((m) => m.name == name).firstOrNull;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);
}

class InMemoryGoalRepository implements GoalRepository {
  InMemoryGoalRepository({this.goals, this.currency, this.themeMode});

  List<Goal>? goals;
  Currency? currency;
  ThemeMode? themeMode;

  @override
  Future<List<Goal>?> loadGoals() async => goals == null ? null : [...goals!];

  @override
  Future<void> saveGoals(List<Goal> goals) async => this.goals = [...goals];

  @override
  Future<Currency?> loadCurrency() async => currency;

  @override
  Future<void> saveCurrency(Currency currency) async =>
      this.currency = currency;

  @override
  Future<ThemeMode?> loadThemeMode() async => themeMode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async => themeMode = mode;
}
