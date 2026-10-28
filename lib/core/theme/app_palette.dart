import 'package:flutter/material.dart';

/// Brand colors that don't map cleanly onto Material's [ColorScheme].
///
/// Read it with `context.palette` (see [PaletteContext]).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.brand,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Color brand;
  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;

  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [brand, accent],
      );

  static const dark = AppPalette(
    background: Color(0xFF0A0E1A),
    surface: Color(0xFF121829),
    surfaceRaised: Color(0xFF1A2236),
    border: Color(0xFF242D44),
    textPrimary: Color(0xFFEEF2FF),
    textMuted: Color(0xFF8A93AD),
    brand: Color(0xFF3B82F6),
    accent: Color(0xFF14C9B8),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFFB7185),
  );

  static const light = AppPalette(
    background: Color(0xFFF4F6FB),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFEEF2F8),
    border: Color(0xFFE2E7F0),
    textPrimary: Color(0xFF0B1220),
    textMuted: Color(0xFF5F6B85),
    brand: Color(0xFF1F6BFF),
    accent: Color(0xFF0FB5A5),
    success: Color(0xFF059669),
    warning: Color(0xFFD97706),
    danger: Color(0xFFE11D48),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? border,
    Color? textPrimary,
    Color? textMuted,
    Color? brand,
    Color? accent,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
