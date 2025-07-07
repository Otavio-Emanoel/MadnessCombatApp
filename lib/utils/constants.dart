import 'package:flutter/material.dart';

/// Cores do tema Madness Combat
class AppColors {
  // Cores principais
  static const Color primary = Color(0xFFFF0000); // Vermelho (sangue)
  static const Color secondary = Color(0xFFFFCC00); // Amarelo (aviso)
  static const Color background = Color(0xFF121212); // Preto quase
  static const Color surface = Color(0xFF1E1E1E); // Cinza escuro

  // Cores de destaque
  static const Color purple = Color(0xFF7B1FA2); // Roxo (quiz)
  static const Color orange = Color(0xFFBF360C); // Laranja (baú)
  static const Color green = Color(0xFF2E7D32); // Verde (jogo)

  // Cores de texto
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(
    0xCCFFFFFF,
  ); // Branco com 80% opacidade
}

/// Estilos de texto
class AppTextStyles {
  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.secondary,
    fontSize: 16,
    letterSpacing: 3,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );
}

/// Dimensões e espaçamentos
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 5.0;
  static const double borderRadiusMedium = 10.0;
  static const double borderRadiusLarge = 20.0;
}

/// Caminhos para as imagens
class AppImages {
  // Exemplo para quando você adicionar imagens
  static const String logo = 'assets/images/logo.png';
  static const String coin = 'assets/images/icons/coin.png';
  static const String chest = 'assets/images/icons/chest.png';

  // Pasta de personagens
  static const String charactersPath = 'assets/images/characters/';
}
