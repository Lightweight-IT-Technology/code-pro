import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  static Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settingsMap = _parseSettingsJson(settingsJson);
        return AppSettings.fromJson(settingsMap);
      }
    } catch (e) {
      print('加载设置失败: $e');
    }

    return const AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = _encodeSettingsJson(settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('保存设置失败: $e');
    }
  }

  static Map<String, dynamic> _parseSettingsJson(String jsonString) {
    try {
      final Map<String, dynamic> result = {};
      final pairs = jsonString.split('&');

      for (final pair in pairs) {
        final keyValue = pair.split('=');
        if (keyValue.length == 2) {
          final key = keyValue[0];
          final value = keyValue[1];

          switch (key) {
            case 'themeMode':
            case 'language':
            case 'autoSaveInterval':
              result[key] = int.tryParse(value);
              break;
            case 'primaryColor':
            case 'accentColor':
              result[key] = int.tryParse(value);
              break;
            case 'fontSize':
              result[key] = double.tryParse(value);
              break;
            case 'lineNumbers':
            case 'wordWrap':
            case 'autoSave':
              result[key] = value == 'true';
              break;
          }
        }
      }

      return result;
    } catch (e) {
      print('解析设置JSON失败: $e');
      return {};
    }
  }

  static String _encodeSettingsJson(Map<String, dynamic> settingsMap) {
    final buffer = StringBuffer();

    settingsMap.forEach((key, value) {
      if (buffer.isNotEmpty) {
        buffer.write('&');
      }
      buffer.write('$key=$value');
    });

    return buffer.toString();
  }

  static Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
    } catch (e) {
      print('重置设置失败: $e');
    }
  }

  static ThemeData getThemeData(AppSettings settings, bool isDarkMode) {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;

    return ThemeData(
      brightness: brightness,
      primaryColor: settings.primaryColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(settings.primaryColor),
        brightness: brightness,
      ),
      fontFamily: 'RobotoMono',
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: settings.fontSize),
        bodyLarge: TextStyle(fontSize: settings.fontSize + 2),
        titleMedium: TextStyle(fontSize: settings.fontSize + 4),
        titleLarge: TextStyle(fontSize: settings.fontSize + 6),
      ),
      useMaterial3: true,
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    final Map<int, Color> shades = {
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color.withOpacity(0.6),
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.8),
      800: color.withOpacity(0.9),
      900: color.withOpacity(1.0),
    };

    return MaterialColor(color.value, shades);
  }
}
