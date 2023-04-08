import 'package:shared_preferences/shared_preferences.dart';

class SpUtil {
  SpUtil._internal();

  static SharedPreferences? prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setInt(String key, int value) async {
    return await prefs?.setInt(key, value) ?? false;
  }

  static int? getInt(String key) {
    return prefs?.getInt(key);
  }

  static Future<bool> setDouble(String key, double value) async {
    return await prefs?.setDouble(key, value) ?? false;
  }

  static double? getDouble(String key) {
    return prefs?.getDouble(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await prefs?.setBool(key, value) ?? false;
  }

  static bool? getBool(String key) {
    return prefs?.getBool(key);
  }

  static Future<bool> setString(String key, String value) async {
    return await prefs?.setString(key, value) ?? false;
  }

  static String? getString(String key) {
    return prefs?.getString(key);
  }

  static Future<bool> remove(String key) async {
    return await prefs?.remove(key) ?? false;
  }

  static bool? containsKey(String key) => prefs?.containsKey(key);
}
