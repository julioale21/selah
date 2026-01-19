import 'package:flutter/material.dart';

/// Selah color tokens
class SelahColors {
  SelahColors._();

  // Primary - Azul profundo espiritual
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF4A6FA5);
  static const Color primaryDark = Color(0xFF0D2137);

  // Secondary - Dorado cálido
  static const Color secondary = Color(0xFFD4A574);
  static const Color secondaryLight = Color(0xFFE8C9A0);
  static const Color secondaryDark = Color(0xFFB8864E);

  // Accent - Teal sereno
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentLight = Color(0xFF7EDDD6);
  static const Color accentDark = Color(0xFF2A9D8F);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);

  // ACTS Method Colors
  static const Color adoration = Color(0xFFFFD700);    // Dorado
  static const Color confession = Color(0xFF9C27B0);   // Púrpura
  static const Color thanksgiving = Color(0xFF4CAF50); // Verde
  static const Color supplication = Color(0xFF2196F3); // Azul

  // Category Colors
  static const Color categoryFamily = Color(0xFFE91E63);
  static const Color categoryChurch = Color(0xFF9C27B0);
  static const Color categoryWork = Color(0xFF3F51B5);
  static const Color categoryHealth = Color(0xFF4CAF50);
  static const Color categoryPersonal = Color(0xFFFF9800);
  static const Color categoryNation = Color(0xFF795548);

  // Neutrals - Light Theme
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color dividerLight = Color(0xFFE0E0E0);

  // Neutrals - Dark Theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color dividerDark = Color(0xFF2D2D2D);

  /// Helper method para obtener color de categoría
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'familia':
      case 'family':
        return categoryFamily;
      case 'iglesia':
      case 'church':
        return categoryChurch;
      case 'trabajo':
      case 'work':
        return categoryWork;
      case 'salud':
      case 'health':
        return categoryHealth;
      case 'personal':
        return categoryPersonal;
      case 'nación':
      case 'nation':
        return categoryNation;
      default:
        return primary;
    }
  }

  /// Helper method para obtener color ACTS
  static Color getActsColor(String step) {
    switch (step.toLowerCase()) {
      case 'adoration':
      case 'adoración':
        return adoration;
      case 'confession':
      case 'confesión':
        return confession;
      case 'thanksgiving':
      case 'gratitud':
        return thanksgiving;
      case 'supplication':
      case 'súplica':
        return supplication;
      default:
        return primary;
    }
  }
}
