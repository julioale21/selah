import 'package:flutter/material.dart';

import 'selah_colors.dart';
import 'selah_typography.dart';
import 'selah_spacing.dart';

/// Selah theme configuration
class SelahTheme {
  SelahTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: SelahTypography.textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      floatingActionButtonTheme: _fabTheme,
      bottomNavigationBarTheme: _bottomNavTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      textTheme: SelahTypography.textTheme,
      appBarTheme: _appBarThemeDark,
      cardTheme: _cardThemeDark,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationThemeDark,
      floatingActionButtonTheme: _fabTheme,
      bottomNavigationBarTheme: _bottomNavThemeDark,
    );
  }

  // Color Schemes
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: SelahColors.primary,
    onPrimary: SelahColors.onPrimary,
    primaryContainer: SelahColors.primaryLight,
    secondary: SelahColors.secondary,
    onSecondary: SelahColors.onSecondary,
    secondaryContainer: SelahColors.secondaryLight,
    tertiary: SelahColors.tertiary,
    tertiaryContainer: SelahColors.tertiaryLight,
    surface: SelahColors.surface,
    onSurface: SelahColors.onSurface,
    surfaceContainerHighest: SelahColors.surfaceVariant,
    error: SelahColors.error,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: SelahColors.primaryLight,
    onPrimary: SelahColors.primaryDark,
    primaryContainer: SelahColors.primary,
    secondary: SelahColors.secondaryLight,
    onSecondary: SelahColors.secondaryDark,
    secondaryContainer: SelahColors.secondary,
    tertiary: SelahColors.tertiaryLight,
    tertiaryContainer: SelahColors.tertiary,
    surface: SelahColors.surfaceDark,
    onSurface: SelahColors.onSurfaceDark,
    surfaceContainerHighest: SelahColors.surfaceVariantDark,
    error: SelahColors.errorDark,
  );

  // AppBar Theme
  static const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: SelahColors.surface,
    foregroundColor: SelahColors.onSurface,
  );

  static const AppBarTheme _appBarThemeDark = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: SelahColors.surfaceDark,
    foregroundColor: SelahColors.onSurfaceDark,
  );

  // Card Theme
  static CardThemeData get _cardTheme => CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
        ),
        color: SelahColors.surface,
      );

  static CardThemeData get _cardThemeDark => CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
        ),
        color: SelahColors.surfaceDark,
      );

  // Button Themes
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: SelahSpacing.lg,
            vertical: SelahSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          ),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: SelahSpacing.lg,
            vertical: SelahSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          ),
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: SelahSpacing.md,
            vertical: SelahSpacing.xs,
          ),
        ),
      );

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: SelahColors.surfaceVariant.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: const BorderSide(color: SelahColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SelahSpacing.md,
          vertical: SelahSpacing.sm,
        ),
      );

  static InputDecorationTheme get _inputDecorationThemeDark =>
      InputDecorationTheme(
        filled: true,
        fillColor: SelahColors.surfaceVariantDark.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide:
              const BorderSide(color: SelahColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SelahSpacing.md,
          vertical: SelahSpacing.sm,
        ),
      );

  // FAB Theme
  static const FloatingActionButtonThemeData _fabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: SelahColors.primary,
    foregroundColor: SelahColors.onPrimary,
    elevation: 4,
  );

  // Bottom Navigation Theme
  static const BottomNavigationBarThemeData _bottomNavTheme =
      BottomNavigationBarThemeData(
    backgroundColor: SelahColors.surface,
    selectedItemColor: SelahColors.primary,
    unselectedItemColor: SelahColors.onSurface,
    type: BottomNavigationBarType.fixed,
  );

  static const BottomNavigationBarThemeData _bottomNavThemeDark =
      BottomNavigationBarThemeData(
    backgroundColor: SelahColors.surfaceDark,
    selectedItemColor: SelahColors.primaryLight,
    unselectedItemColor: SelahColors.onSurfaceDark,
    type: BottomNavigationBarType.fixed,
  );
}
