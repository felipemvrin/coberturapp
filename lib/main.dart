import 'package:flutter/material.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(const RangoApp());
}

class RangoApp extends StatelessWidget {
  const RangoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rango',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
