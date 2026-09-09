import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF0C2D82);
  static const royalBlue = Color(0xFF204DB5);
  static const skyBlue = Color(0xFF3998D8);
  static const gold = Color(0xFFC9B260);
  static const ivory = Color(0xFFF8FAFF);
  static const ink = Color(0xFF10214F);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.royalBlue,
    primary: AppColors.navy,
    secondary: AppColors.gold,
    surface: Colors.white,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.ivory,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w700,
        height: 1.08,
      ),
      headlineSmall: TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.ink, height: 1.55),
      bodyMedium: TextStyle(color: Color(0xFF445173), height: 1.45),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE6EAF4)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF7B86A4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE3E8F2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Color(0x1FC9B260),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
