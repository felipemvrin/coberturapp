import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme() {
    const colors = AppColors.light;
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.light,
        primary: colors.primary,
        secondary: colors.accent,
        surface: colors.surface,
        background: colors.background,
        onPrimary: colors.surface,
        onSecondary: colors.primary,
        onSurface: colors.text,
        onBackground: colors.text,
      ),
      scaffoldBackgroundColor: colors.background,
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: base.textTheme.apply(bodyColor: colors.text, displayColor: colors.text),
    );
  }

  static ThemeData darkTheme() {
    const colors = AppColors.dark;
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.dark,
        primary: colors.primary,
        secondary: colors.accent,
        surface: colors.surface,
        background: colors.background,
        onPrimary: colors.surface,
        onSecondary: colors.primary,
        onSurface: colors.text,
        onBackground: colors.text,
      ),
      scaffoldBackgroundColor: colors.background,
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: base.textTheme.apply(bodyColor: colors.text, displayColor: colors.text),
    );
  }
}
