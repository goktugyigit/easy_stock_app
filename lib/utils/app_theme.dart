// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Ana Renkler
  static const Color primaryColor = Color(0xFF00AFFF);
  static const Color accentColor = Color(0xFF00EFFF);

  // Arka Plan ve Yüzey Renkleri
  static const Color appBackgroundColor = Colors.black;
  static const Color surfaceColor = Color(0xFF1B1B1B);

  // Metin Renkleri
  static Color primaryTextColor = Colors.white.withAlpha((0.95 * 255).round());
  static Color secondaryTextColor = Colors.white.withAlpha((0.75 * 255).round());
  static Color hintTextColor = Colors.white.withAlpha((0.55 * 255).round());
  static Color disabledTextColor = Colors.white.withAlpha((0.40 * 255).round());

  // Glassmorphism için Kart Rengi (StockItemCard)
  static Color glassCardBackgroundColor = Colors.white.withAlpha((0.12 * 255).round());
  static Color glassCardBorderColor = Colors.white.withAlpha((0.18 * 255).round());

  // Bottom Nav Bar için Glassmorphism (MainScreenWithBottomNav)
  static Color glassNavBarBackgroundColor = Colors.white.withAlpha((0.15 * 255).round());
  static Color glassNavBarBorderColor = Colors.white.withAlpha((0.20 * 255).round());

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark( // DİKKAT: background ve onBackground buradan kaldırıldı.
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      error: Colors.redAccent.shade100,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: primaryTextColor,
      onError: Colors.black,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: appBackgroundColor,
    fontFamily: 'Poppins',

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: primaryTextColor.withAlpha((0.85 * 255).round())),
      titleTextStyle: TextStyle(
        color: primaryTextColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
      displayMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
      displaySmall: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
      headlineLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      headlineMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      headlineSmall: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      titleLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
      titleMedium: TextStyle(color: primaryTextColor, fontFamily: 'Poppins'),
      titleSmall: TextStyle(color: primaryTextColor, fontFamily: 'Poppins'),
      bodyLarge: TextStyle(color: primaryTextColor, fontSize: 15, height: 1.4, fontFamily: 'Poppins'),
      bodyMedium: TextStyle(color: secondaryTextColor, fontSize: 13.5, height: 1.35, fontFamily: 'Poppins'),
      bodySmall: TextStyle(color: hintTextColor, fontSize: 12, height: 1.3, fontFamily: 'Poppins'),
      labelLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'Poppins'),
      labelMedium: TextStyle(color: secondaryTextColor, fontFamily: 'Poppins'),
      labelSmall: TextStyle(color: hintTextColor, fontFamily: 'Poppins'),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withAlpha((0.05 * 255).round()),
      hintStyle: TextStyle(color: hintTextColor, fontSize: 14.5, fontFamily: 'Poppins'),
      labelStyle: TextStyle(color: secondaryTextColor.withAlpha((0.9 * 255).round()), fontSize: 15, fontFamily: 'Poppins'),
      iconColor: secondaryTextColor.withAlpha((0.8 * 255).round()),
      prefixIconColor: secondaryTextColor.withAlpha((0.8 * 255).round()),
      suffixIconColor: secondaryTextColor.withAlpha((0.8 * 255).round()),
      errorStyle: TextStyle(color: Colors.redAccent.shade100.withAlpha((0.9 * 255).round()), fontSize: 12.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white.withAlpha((0.12 * 255).round()), width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white.withAlpha((0.12 * 255).round()), width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryColor.withAlpha((0.7 * 255).round()), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.redAccent.shade100.withAlpha((0.7 * 255).round()), width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.redAccent.shade100, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
        shadowColor: primaryColor.withAlpha((0.3 * 255).round()),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      )
    ),

    iconTheme: IconThemeData(
      color: primaryTextColor.withAlpha((0.90 * 255).round()),
      size: 24.0,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor.withAlpha((0.92 * 255).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      titleTextStyle: TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      contentTextStyle: TextStyle(color: secondaryTextColor, fontSize: 15, fontFamily: 'Poppins'),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white.withAlpha((0.03 * 255).round()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: Colors.white.withAlpha((0.08 * 255).round()), width: 0.5)
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    dividerTheme: DividerThemeData(
      color: Colors.white.withAlpha((0.10 * 255).round()),
      thickness: 0.7,
      space: 1,
      indent: 16,
      endIndent: 16,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryTextColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
  );
}