import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/goal_repository.dart';
import 'state/goals_store.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final store = GoalsStore(SharedPrefsGoalRepository(SharedPreferencesAsync()));
  await store.load();

  runApp(
    ChangeNotifierProvider.value(value: store, child: const HorizonApp()),
  );
  // Data is ready — no reason to keep the splash any longer.
  FlutterNativeSplash.remove();
}
