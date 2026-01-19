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
      colorScheme: ColorScheme.light(
        primary: SelahColors.primary,
        onPrimary: Colors.white,
        primaryContainer: SelahColors.primaryLight,
        onPrimaryContainer: SelahColors.primaryDark,
        secondary: SelahColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: SelahColors.secondaryLight,
        onSecondaryContainer: SelahColors.secondaryDark,
        tertiary: SelahColors.accent,
        onTertiary: Colors.white,
        error: SelahColors.error,
        onError: Colors.white,
        surface: SelahColors.surfaceLight,
        onSurface: SelahColors.textPrimaryLight,
        surfaceContainerHighest: SelahColors.dividerLight,
        onSurfaceVariant: SelahColors.textSecondaryLight,
      ),
      scaffoldBackgroundColor: SelahColors.backgroundLight,
      textTheme: SelahTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: SelahColors.surfaceLight,
        foregroundColor: SelahColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: SelahTypography.titleLarge.copyWith(
          color: SelahColors.textPrimaryLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: SelahColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SelahColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: SelahSpacing.lg,
            vertical: SelahSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          ),
          textStyle: SelahTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SelahColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: SelahSpacing.lg,
            vertical: SelahSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          ),
          side: const BorderSide(color: SelahColors.primary),
          textStyle: SelahTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SelahColors.primary,
          textStyle: SelahTypography.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SelahColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SelahColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: const BorderSide(color: SelahColors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: const BorderSide(color: SelahColors.dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: const BorderSide(color: SelahColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SelahSpacing.md,
          vertical: SelahSpacing.md,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: SelahColors.dividerLight,
        thickness: 1,
        space: SelahSpacing.md,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SelahColors.surfaceLight,
        selectedItemColor: SelahColors.primary,
        unselectedItemColor: SelahColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: SelahColors.primaryLight,
        onPrimary: SelahColors.primaryDark,
        primaryContainer: SelahColors.primary,
        onPrimaryContainer: Colors.white,
        secondary: SelahColors.secondary,
        onSecondary: SelahColors.secondaryDark,
        secondaryContainer: SelahColors.secondaryDark,
        onSecondaryContainer: SelahColors.secondaryLight,
        tertiary: SelahColors.accentLight,
        onTertiary: SelahColors.accentDark,
        error: SelahColors.error,
        onError: Colors.white,
        surface: SelahColors.surfaceDark,
        onSurface: SelahColors.textPrimaryDark,
        surfaceContainerHighest: SelahColors.dividerDark,
        onSurfaceVariant: SelahColors.textSecondaryDark,
      ),
      scaffoldBackgroundColor: SelahColors.backgroundDark,
      textTheme: TextTheme(
        displayLarge: SelahTypography.displayLarge.copyWith(color: SelahColors.textPrimaryDark),
        displayMedium: SelahTypography.displayMedium.copyWith(color: SelahColors.textPrimaryDark),
        displaySmall: SelahTypography.displaySmall.copyWith(color: SelahColors.textPrimaryDark),
        headlineLarge: SelahTypography.headlineLarge.copyWith(color: SelahColors.textPrimaryDark),
        headlineMedium: SelahTypography.headlineMedium.copyWith(color: SelahColors.textPrimaryDark),
        headlineSmall: SelahTypography.headlineSmall.copyWith(color: SelahColors.textPrimaryDark),
        titleLarge: SelahTypography.titleLarge.copyWith(color: SelahColors.textPrimaryDark),
        titleMedium: SelahTypography.titleMedium.copyWith(color: SelahColors.textPrimaryDark),
        titleSmall: SelahTypography.titleSmall.copyWith(color: SelahColors.textPrimaryDark),
        bodyLarge: SelahTypography.bodyLarge.copyWith(color: SelahColors.textPrimaryDark),
        bodyMedium: SelahTypography.bodyMedium.copyWith(color: SelahColors.textPrimaryDark),
        bodySmall: SelahTypography.bodySmall.copyWith(color: SelahColors.textSecondaryDark),
        labelLarge: SelahTypography.labelLarge.copyWith(color: SelahColors.textPrimaryDark),
        labelMedium: SelahTypography.labelMedium.copyWith(color: SelahColors.textSecondaryDark),
        labelSmall: SelahTypography.labelSmall.copyWith(color: SelahColors.textSecondaryDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SelahColors.surfaceDark,
        foregroundColor: SelahColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: SelahTypography.titleLarge.copyWith(
          color: SelahColors.textPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: SelahColors.surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SelahColors.primaryLight,
          foregroundColor: SelahColors.primaryDark,
          padding: const EdgeInsets.symmetric(
            horizontal: SelahSpacing.lg,
            vertical: SelahSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          ),
          textStyle: SelahTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SelahColors.primaryLight,
          padding: const EdgeInsets.symmetric(
            horizontal: SelahSpacing.lg,
            vertical: SelahSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          ),
          side: const BorderSide(color: SelahColors.primaryLight),
          textStyle: SelahTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SelahColors.primaryLight,
          textStyle: SelahTypography.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SelahColors.primaryLight,
        foregroundColor: SelahColors.primaryDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SelahColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: const BorderSide(color: SelahColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: const BorderSide(color: SelahColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          borderSide: const BorderSide(color: SelahColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SelahSpacing.md,
          vertical: SelahSpacing.md,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: SelahColors.dividerDark,
        thickness: 1,
        space: SelahSpacing.md,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SelahColors.surfaceDark,
        selectedItemColor: SelahColors.primaryLight,
        unselectedItemColor: SelahColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
