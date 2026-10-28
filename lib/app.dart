import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'state/goals_store.dart';

class HorizonApp extends StatelessWidget {
  const HorizonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<GoalsStore, ThemeMode>((s) => s.themeMode);
    return MaterialApp(
      title: 'Horizon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
