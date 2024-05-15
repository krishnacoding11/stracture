import 'dart:convert';

import 'package:asite_plugins/asite_plugins.dart';
import 'package:asite_plugins/asite_plugins_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences?> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance;
  }

  static Future<bool> setBool(String key, bool value) async {
    var prefs = await _instance;
    String encryptString = await encryptSetValue(value.toString());
    return prefs.setString(key, encryptString);
  }

  static Future<bool> getBool(String key, [bool? defValue]) async {
    String? boolValueForDecrypt = _prefsInstance?.getString(key);
    String decryptValue = defValue.toString();
    if (boolValueForDecrypt != null && boolValueForDecrypt.isNotEmpty) {
      decryptValue = await decryptGetValue(boolValueForDecrypt, key: key);
    }
    return decryptValue == "true" ? Future.value(true) : Future.value(false);
  }

  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    String encryptString = await encryptSetValue(value);
    return prefs.setString(key, encryptString);
  }

  static Future<String> getString(String key, [String? defValue]) async {
    String? storeValue = _prefsInstance?.getString(key);
    String decryptValue = defValue ?? "";
    if (storeValue != null && storeValue.isNotEmpty) {
      decryptValue = await decryptGetValue(storeValue, key: key);
    }
    return decryptValue;
  }

  static Future<bool> setInt(String key, int value) async {
    var prefs = await _instance;
    String encryptValue = await encryptSetValue(value.toString());
    return prefs.setString(key, encryptValue);
  }

  static Future<int> getInt(String key, [int? defValue]) async {
    String? storedIntValue = _prefsInstance?.getString(key);
    String decryptValue = defValue.toString();
    if (storedIntValue != null && storedIntValue.isNotEmpty) {
      decryptValue = await decryptGetValue(storedIntValue, key: key);
    }
    return int.parse(decryptValue);
  }

  static Future<Map?> getPrefData(String key) async {
    var prefs = await _instance;
    if (prefs.containsKey(key)) {
      String? decodeValue = await getString(key);
      Map json = await jsonDecode(decodeValue);
      return json;
    }
    return null;
  }

  static Future<bool> remove(String key) async {
    var prefs = await _instance;
    return prefs.remove(key);
  }

  static Future<String> encryptSetValue(data) async {
    var plugin = AsitePlugins();
    return await plugin.encrypt(data, EncryptionAlgorithm.ctr);
  }

  static Future<String> decryptGetValue(data, {String? key}) async {
    var plugin = AsitePlugins();
    return await plugin.decrypt(data, EncryptionAlgorithm.ctr);
  }
}
