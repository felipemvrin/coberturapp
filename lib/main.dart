import 'package:flutter/material.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(const CoberturApp());
}

class CoberturApp extends StatelessWidget {
  const CoberturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoberturApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
