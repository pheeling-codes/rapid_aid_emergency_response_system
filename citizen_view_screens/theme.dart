import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A2B5C); // Deep navy blue
  static const Color accent = Color(0xFFB91C1C); // Emergency red
  static const Color accentLight = Color(0xFFDC2626); // Lighter red
  static const Color background = Color(0xFFF3F4F6); // Light grey bg
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color resolved = Color(0xFF16A34A);
  static const Color cancelled = Color(0xFF6B7280);
  static const Color urgent = Color(0xFFB91C1C);
  static const Color toggleActive = Color(0xFF1A2B5C);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color inputBg = Color(0xFFF9FAFB);
  static const Color borderColor = Color(0xFFD1D5DB);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
  );
}
