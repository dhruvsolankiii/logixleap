import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  // Save data to cache
  static Future<void> saveCache(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cache_$key", jsonEncode(data));
  }

  // Load cached data
  static Future<dynamic> getCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString("cache_$key");
    if (cached != null) {
      return jsonDecode(cached);
    }
    return null;
  }

  // Clear all cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith("cache_"));
    for (var key in keys) {
      await prefs.remove(key);
    }
  }
}
