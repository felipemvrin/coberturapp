import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.accent,
    required this.signalGood,
    required this.signalMedium,
    required this.signalPoor,
    required this.text,
    required this.muted,
  });

  final Color background;
  final Color surface;
  final Color primary;
  final Color accent;
  final Color signalGood;
  final Color signalMedium;
  final Color signalPoor;
  final Color text;
  final Color muted;

  static const light = AppColors(
    background: Color(0xFFF4F1E8),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF182A25),
    accent: Color(0xFFD8FF3E),
    signalGood: Color(0xFF32D583),
    signalMedium: Color(0xFFFFB547),
    signalPoor: Color(0xFFF97068),
    text: Color(0xFF16201D),
    muted: Color(0xFF69756F),
  );

  static const dark = AppColors(
    background: Color(0xFF101411),
    surface: Color(0xFF19201B),
    primary: Color(0xFFB8FF4A),
    accent: Color(0xFFD8FF3E),
    signalGood: Color(0xFF32D583),
    signalMedium: Color(0xFFFFB547),
    signalPoor: Color(0xFFFF5C5C),
    text: Color(0xFFE8F0E5),
    muted: Color(0xFF96A39A),
  );
}

extension AppColorsExtension on ThemeData {
  AppColors get appColors {
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }
}
