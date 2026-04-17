import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette (Tonal Hierarchy)
  static const Color primary = Color(0xFF005EB8);
  static const Color secondary = Color(0xFF445E91);
  static const Color emergencyUrl = Color(0xFFD32F2F);
  
  static const Color backgroundBase = Color(0xFFF9FAFB);
  static const Color surfaceContainerLowest = Colors.white; // Pure white for active cards
  static const Color surfaceContainerLow = Color(0xFFF3F4F6); // Background shifts
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB); // For inputs
  
  static const Color headingColor = Color(0xFF111827); // Deep Slate
  static const Color bodyColor = Color(0xFF191C1D); // On-Surface

  static ThemeData get clinicalVanguardTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundBase,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: emergencyUrl,
        error: emergencyUrl,
        background: backgroundBase,
        surface: backgroundBase,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerHigh: surfaceContainerHigh,
        onSurface: bodyColor,
        onBackground: bodyColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 56, // 3.5rem
          fontWeight: FontWeight.w700,
          color: headingColor,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28, // 1.75rem
          fontWeight: FontWeight.w700,
          color: headingColor,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22, // 1.375rem
          fontWeight: FontWeight.w600,
          color: headingColor,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16, // 1rem
          fontWeight: FontWeight.w400,
          color: bodyColor,
          height: 1.5,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12, // 0.75rem
          fontWeight: FontWeight.w500,
          color: bodyColor,
          letterSpacing: 0.6, // 5% of 12px
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundBase,
        elevation: 0, // Disable standard drop shadows
        centerTitle: true,
        iconTheme: IconThemeData(color: headingColor),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: headingColor,
        ),
      ),
      // No borders, leverage surface colors for input
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        border: InputBorder.none, // The 'No-Line' rule
        enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primary, width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      cardTheme: const CardTheme(
        color: surfaceContainerLowest,
        elevation: 0, // Disable standard drop shadows
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
