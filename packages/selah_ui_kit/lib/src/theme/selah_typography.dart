import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Selah typography tokens
class SelahTypography {
  SelahTypography._();

  // Font families
  static String get _headingFont => GoogleFonts.playfairDisplay().fontFamily!;
  static String get _bodyFont => GoogleFonts.lato().fontFamily!;

  // Display styles (para títulos grandes)
  static TextStyle displayLarge = TextStyle(
    fontFamily: _headingFont,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static TextStyle displayMedium = TextStyle(
    fontFamily: _headingFont,
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );

  static TextStyle displaySmall = TextStyle(
    fontFamily: _headingFont,
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  // Headline styles
  static TextStyle headlineLarge = TextStyle(
    fontFamily: _headingFont,
    fontSize: 32,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headlineMedium = TextStyle(
    fontFamily: _headingFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headlineSmall = TextStyle(
    fontFamily: _headingFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // Title styles
  static TextStyle titleLarge = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );

  static TextStyle titleMedium = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static TextStyle titleSmall = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // Body styles
  static TextStyle bodyLarge = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // Label styles
  static TextStyle labelLarge = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Special styles para la app
  static TextStyle verseText = TextStyle(
    fontFamily: _headingFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.6,
  );

  static TextStyle verseReference = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle prayerPrompt = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle timerDisplay = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 48,
    fontWeight: FontWeight.w300,
    letterSpacing: 2,
  );

  // TextTheme for ThemeData
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}
