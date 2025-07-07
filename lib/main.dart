import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MadnessCombatApp());
}

class MadnessCombatApp extends StatelessWidget {
  const MadnessCombatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madness Combat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: AppColors.surface,
        ),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}
