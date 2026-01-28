import 'package:flutter/material.dart';

enum ThemeModeType { light, dark, system }

enum LanguageType { zh, en, system }

class AppSettings {
  final ThemeModeType themeMode;
  final LanguageType language;
  final Color primaryColor;
  final Color accentColor;
  final double fontSize;
  final bool lineNumbers;
  final bool wordWrap;
  final bool autoSave;
  final int autoSaveInterval;

  const AppSettings({
    this.themeMode = ThemeModeType.system,
    this.language = LanguageType.system,
    this.primaryColor = Colors.blue,
    this.accentColor = Colors.blueAccent,
    this.fontSize = 14.0,
    this.lineNumbers = true,
    this.wordWrap = true,
    this.autoSave = true,
    this.autoSaveInterval = 5,
  });

  AppSettings copyWith({
    ThemeModeType? themeMode,
    LanguageType? language,
    Color? primaryColor,
    Color? accentColor,
    double? fontSize,
    bool? lineNumbers,
    bool? wordWrap,
    bool? autoSave,
    int? autoSaveInterval,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      fontSize: fontSize ?? this.fontSize,
      lineNumbers: lineNumbers ?? this.lineNumbers,
      wordWrap: wordWrap ?? this.wordWrap,
      autoSave: autoSave ?? this.autoSave,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'language': language.index,
      'primaryColor': primaryColor.value,
      'accentColor': accentColor.value,
      'fontSize': fontSize,
      'lineNumbers': lineNumbers,
      'wordWrap': wordWrap,
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode:
          ThemeModeType.values[json['themeMode'] ?? ThemeModeType.system.index],
      language:
          LanguageType.values[json['language'] ?? LanguageType.system.index],
      primaryColor: Color(json['primaryColor'] ?? Colors.blue.value),
      accentColor: Color(json['accentColor'] ?? Colors.blueAccent.value),
      fontSize: json['fontSize']?.toDouble() ?? 14.0,
      lineNumbers: json['lineNumbers'] ?? true,
      wordWrap: json['wordWrap'] ?? true,
      autoSave: json['autoSave'] ?? true,
      autoSaveInterval: json['autoSaveInterval'] ?? 5,
    );
  }

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      case ThemeModeType.system:
        return ThemeMode.system;
    }
  }

  String get languageCode {
    switch (language) {
      case LanguageType.zh:
        return 'zh';
      case LanguageType.en:
        return 'en';
      case LanguageType.system:
        return 'system';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.language == language &&
        other.primaryColor == primaryColor &&
        other.accentColor == accentColor &&
        other.fontSize == fontSize &&
        other.lineNumbers == lineNumbers &&
        other.wordWrap == wordWrap &&
        other.autoSave == autoSave &&
        other.autoSaveInterval == autoSaveInterval;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      language,
      primaryColor,
      accentColor,
      fontSize,
      lineNumbers,
      wordWrap,
      autoSave,
      autoSaveInterval,
    );
  }
}
