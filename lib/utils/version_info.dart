class VersionInfo {
  static const String version = '0.0.2';
  static const String buildNumber = '2';
  static const String versionType = 'beta预构建版';
  static const String buildDate = '2026-01-27';

  static String get fullVersion {
    return '$version ($buildNumber) - $versionType';
  }

  static String get displayVersion {
    return 'v$version $versionType';
  }

  static String get aboutInfo {
    return '''代码编辑器
版本: $fullVersion
构建日期: $buildDate

功能特性:
• 跨平台代码编辑
• 文件树导航
• 语法高亮
• 主题定制
• 多语言支持
• 文件栏显示/隐藏控制
• 退出功能完善

技术支持: 开发者团队''';
  }
}
