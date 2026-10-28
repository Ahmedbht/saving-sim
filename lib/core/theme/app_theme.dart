import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';

abstract final class AppTheme {
  static const fontFamily = 'PlusJakartaSans';
  static const radius = 20.0;

  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);
  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.brand,
      onPrimary: Colors.white,
      secondary: p.accent,
      onSecondary: isDark ? p.background : Colors.white,
      error: p.danger,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textMuted,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceRaised,
      surfaceContainerHighest: p.surfaceRaised,
      outline: p.border,
      outlineVariant: p.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: scheme,
    );

    final text = base.textTheme.apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    );

    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.45),
        bodySmall: text.bodySmall?.copyWith(color: p.textMuted, height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: p.textPrimary,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: p.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: p.surfaceRaised,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: p.textMuted),
        labelStyle: TextStyle(color: p.textMuted),
        floatingLabelStyle: TextStyle(color: p.brand),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.brand, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.danger, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: roundedShape,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: roundedShape,
          side: BorderSide(color: p.border),
          foregroundColor: p.textPrimary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        extendedTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        shape: roundedShape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? p.surfaceRaised : p.textPrimary,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: isDark ? p.textPrimary : p.surface,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: p.accent,
        shape: roundedShape,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.brand,
        inactiveTrackColor: p.surfaceRaised,
        thumbColor: p.brand,
        overlayColor: p.brand.withValues(alpha: 0.12),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        trackHeight: 6,
        valueIndicatorColor: p.brand,
        valueIndicatorTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: p.surfaceRaised,
          selectedBackgroundColor: p.brand,
          selectedForegroundColor: Colors.white,
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.border),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
