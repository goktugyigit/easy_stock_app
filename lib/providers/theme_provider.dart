import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'appThemeMode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Light Theme - Optimized Professional Design
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3), // Modern Blue
      brightness: Brightness.light,
      surface: const Color(0xFFFAFAFA), // Very light gray for cards
      surfaceContainerHighest: const Color(0xFFF5F5F5), // Search bar background
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Pure white
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF212121),
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Color(0xFF212121),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: const Color(0xFF2196F3).withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF2196F3),
    ),
    textTheme: const TextTheme(
      headlineLarge:
          TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w700),
      headlineMedium:
          TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600),
      titleLarge:
          TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600),
      titleMedium:
          TextStyle(color: Color(0xFF424242), fontWeight: FontWeight.w500),
      titleSmall:
          TextStyle(color: Color(0xFF424242), fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Color(0xFF424242)),
      bodyMedium: TextStyle(color: Color(0xFF424242)),
      bodySmall: TextStyle(color: Color(0xFF757575)),
    ),
  );

  // Dark Theme - Optimized Modern Dark Design
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF64B5F6), // Lighter blue for better contrast
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
      surfaceContainerHighest: const Color(0xFF2A2A2A), // Search bar background
    ),
    scaffoldBackgroundColor: const Color(0xFF121212), // True dark
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFE0E0E0),
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF64B5F6),
        foregroundColor: const Color(0xFF121212),
        elevation: 4,
        shadowColor: const Color(0xFF64B5F6).withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF64B5F6),
    ),
    textTheme: const TextTheme(
      headlineLarge:
          TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.w700),
      headlineMedium:
          TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.w600),
      titleLarge:
          TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.w600),
      titleMedium:
          TextStyle(color: Color(0xFFBDBDBD), fontWeight: FontWeight.w500),
      titleSmall:
          TextStyle(color: Color(0xFFBDBDBD), fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Color(0xFFBDBDBD)),
      bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
      bodySmall: TextStyle(color: Color(0xFF9E9E9E)),
    ),
  );

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';

    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  Future<void> setTheme(String themeString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeString);

    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  String get currentThemeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode {
    return _themeMode == ThemeMode.light;
  }

  bool get isSystemMode {
    return _themeMode == ThemeMode.system;
  }
}
