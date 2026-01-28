import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  AppSettings _settings = const AppSettings();
  bool _isDarkMode = false;

  AppSettings get settings => _settings;
  bool get isDarkMode => _isDarkMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await SettingsService.loadSettings();
    _updateThemeMode();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await SettingsService.saveSettings(newSettings);
    _updateThemeMode();
    notifyListeners();
  }

  void _updateThemeMode() {
    switch (_settings.themeMode) {
      case ThemeModeType.light:
        _isDarkMode = false;
        break;
      case ThemeModeType.dark:
        _isDarkMode = true;
        break;
      case ThemeModeType.system:
        _isDarkMode =
            WidgetsBinding.instance.window.platformBrightness ==
            Brightness.dark;
        break;
    }
  }

  void setThemeMode(ThemeModeType themeMode) {
    updateSettings(_settings.copyWith(themeMode: themeMode));
  }

  void setLanguage(LanguageType language) {
    updateSettings(_settings.copyWith(language: language));
  }

  void setPrimaryColor(Color color) {
    updateSettings(_settings.copyWith(primaryColor: color));
  }

  void setAccentColor(Color color) {
    updateSettings(_settings.copyWith(accentColor: color));
  }

  void setFontSize(double fontSize) {
    updateSettings(_settings.copyWith(fontSize: fontSize));
  }

  void setLineNumbers(bool enabled) {
    updateSettings(_settings.copyWith(lineNumbers: enabled));
  }

  void setWordWrap(bool enabled) {
    updateSettings(_settings.copyWith(wordWrap: enabled));
  }

  void setAutoSave(bool enabled) {
    updateSettings(_settings.copyWith(autoSave: enabled));
  }

  void setAutoSaveInterval(int interval) {
    updateSettings(_settings.copyWith(autoSaveInterval: interval));
  }

  Future<void> resetToDefaults() async {
    _settings = const AppSettings();
    await SettingsService.saveSettings(_settings);
    _updateThemeMode();
    notifyListeners();
  }

  ThemeData getCurrentTheme() {
    return SettingsService.getThemeData(_settings, _isDarkMode);
  }

  String getThemeModeDisplayName() {
    switch (_settings.themeMode) {
      case ThemeModeType.light:
        return '浅色模式';
      case ThemeModeType.dark:
        return '深色模式';
      case ThemeModeType.system:
        return '跟随系统';
    }
  }

  String getLanguageDisplayName() {
    switch (_settings.language) {
      case LanguageType.zh:
        return '中文';
      case LanguageType.en:
        return 'English';
      case LanguageType.system:
        return '跟随系统';
    }
  }
}
