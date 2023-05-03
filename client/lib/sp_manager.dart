import 'package:shared_preferences/shared_preferences.dart';

bool spInitSuccess = false;

class SpManager {
  SpManager._internal();

  static SharedPreferences? _prefs;

  static Future<bool> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs != null;
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  static bool? containsKey(String key) => _prefs?.containsKey(key);
}
