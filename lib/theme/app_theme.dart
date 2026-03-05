import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color warmBlack = Color(0xFF14110F);
  static const Color warmBlackLight = Color(0xFF1A1612);
  static const Color offWhite = Color(0xFFF3F1EC);
  static const Color background = Color(0xFFF5F4F0);
  static const Color cardWhite = Color(0xFFFFFFFD);
  static const Color accentGreen = Color(0xFFB9FF66);
  static const Color accentGreenLight = Color(0xFFC6FF7A);
  static const Color subtleBorder = Color(0xFFE0DDD6);
  static const Color textSecondary = Color(0xFF6B6560);
  static const Color textTertiary = Color(0xFF9C9690);
}

class AppShadows {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    const BoxShadow(
      color: AppColors.warmBlack,
      offset: Offset(3, 3),
    ),
  ];

  static List<BoxShadow> greenButtonShadow = [
    BoxShadow(
      color: AppColors.warmBlack.withValues(alpha: 0.8),
      offset: const Offset(3, 3),
    ),
  ];
}

class AppTheme {
  static ThemeData get theme {
    final pixelFont = GoogleFonts.pressStart2pTextTheme();
    final bodyFont = GoogleFonts.vt323TextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentGreen,
        brightness: Brightness.light,
        surface: AppColors.background,
        onSurface: AppColors.warmBlack,
      ),
      textTheme: TextTheme(
        displayLarge: pixelFont.displayLarge?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 32,
        ),
        displayMedium: pixelFont.displayMedium?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 24,
        ),
        headlineLarge: pixelFont.headlineLarge?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 20,
        ),
        headlineMedium: pixelFont.headlineMedium?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 16,
        ),
        headlineSmall: pixelFont.headlineSmall?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 14,
        ),
        titleLarge: bodyFont.titleLarge?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: bodyFont.titleMedium?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 20,
        ),
        bodyLarge: bodyFont.bodyLarge?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 22,
        ),
        bodyMedium: bodyFont.bodyMedium?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 20,
        ),
        bodySmall: bodyFont.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
        labelLarge: pixelFont.labelLarge?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 10,
        ),
        labelMedium: pixelFont.labelMedium?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 8,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.subtleBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: pixelFont.headlineSmall?.copyWith(
          color: AppColors.warmBlack,
          fontSize: 12,
        ),
        iconTheme: const IconThemeData(color: AppColors.warmBlack),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardWhite,
          foregroundColor: AppColors.warmBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: AppColors.warmBlack, width: 2),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.subtleBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.warmBlack, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardWhite,
        selectedItemColor: AppColors.warmBlack,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

