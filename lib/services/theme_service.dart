import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeService {
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
    ThemeMode.dark,
  );

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
  static const canvas = Color(0xFFF7F8F5);
  static const charcoal = Color(0xFF17211D);
  static const forest = Color(0xFF216B52);
  static const mint = Color(0xFFDDF4E8);
  static const muted = Color(0xFF718078);
  static const amber = Color(0xFFD99122);
  static const red = Color(0xFFC95A5A);

  static ThemeData _theme({required bool dark}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: forest,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: dark ? const Color(0xFF8AD8B5) : forest,
      surface: dark ? const Color(0xFF202B25) : Colors.white,
      error: red,
    );
    final text = dark ? Colors.white : charcoal;
    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: dark ? const Color(0xFF141B17) : canvas,
      colorScheme: scheme,
      cardColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF141B17) : canvas,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          color: text,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: text, fontSize: 16),
        bodyMedium: TextStyle(
          color: dark ? const Color(0xFFB8C5BE) : muted,
          fontSize: 14,
        ),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: dark ? charcoal : Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF29362F) : const Color(0xFFF0F3EF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: dark ? const Color(0xFF315B48) : mint,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: scheme.primary)),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? Colors.white12 : const Color(0xFFE4E9E4),
      ),
    );
  }

  static final lightTheme = _theme(dark: false);
  static final darkTheme = _theme(dark: true);
}
