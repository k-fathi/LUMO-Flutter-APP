import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get instance {
    if (_preferences == null) {
      throw Exception('SharedPreferencesService not initialized. Call init() first.');
    }
    return _preferences!;
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    return await instance.setString(key, value);
  }

  String? getString(String key) {
    return instance.getString(key);
  }

  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return await instance.setBool(key, value);
  }

  bool? getBool(String key) {
    return instance.getBool(key);
  }

  // Int operations
  Future<bool> setInt(String key, int value) async {
    return await instance.setInt(key, value);
  }

  int? getInt(String key) {
    return instance.getInt(key);
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return await instance.setDouble(key, value);
  }

  double? getDouble(String key) {
    return instance.getDouble(key);
  }

  // StringList operations
  Future<bool> setStringList(String key, List<String> value) async {
    return await instance.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return instance.getStringList(key);
  }

  // Remove operations
  Future<bool> remove(String key) async {
    return await instance.remove(key);
  }

  // Clear all
  Future<bool> clear() async {
    return await instance.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return instance.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return instance.getKeys();
  }
}