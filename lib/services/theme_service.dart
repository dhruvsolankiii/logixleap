import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeService {
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

  static Future<void> loadTheme() async {
    bool? isDark = await StorageService.getTheme();
    if (isDark != null) {
      themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  static Future<void> toggleTheme() async {
    bool isDark = themeModeNotifier.value == ThemeMode.dark;
    themeModeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    await StorageService.saveTheme(!isDark);
  }
}

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E88E5),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1E88E5),
      secondary: Colors.teal,
      surface: Colors.white,
    ),
    cardColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F2027),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F2027),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1E88E5),
      secondary: Colors.greenAccent,
      surface: Color(0xFF203A43),
    ),
    cardColor: const Color(0xFF203A43),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}
