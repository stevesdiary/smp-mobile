import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademicContinuityTheme {
  static const Color primaryColor = Color(0xFF050057);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  static const Color secondaryColor = Color(0xFF5051BD);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  static const Color surfaceColor = Color(0xFFFAF9FE);
  static const Color onSurface = Color(0xFF1A1B1F);
  static const Color onSurfaceVariant = Color(0xFF464651);

  static const Color backgroundColor = Color(0xFFFAF9FE);
  static const Color onBackground = Color(0xFF1A1B1F);

  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color outlineColor = Color(0xFF777682);
  static const Color outlineVariant = Color(0xFFC7C5D3);
  
  static const Color interactiveBlue = Color(0xFF3B3BA8);
  static const Color systemBackground = Color(0xFFF2F2F7);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: onPrimary,
        secondary: secondaryColor,
        onSecondary: onSecondary,
        surface: surfaceColor,
        onSurface: onSurface,
        error: errorColor,
        onError: onError,
      ),
      scaffoldBackgroundColor: systemBackground,
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: onSurface,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.35,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: onSurfaceVariant,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          color: onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.08,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF8E8E93).withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: interactiveBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
