import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

/// 插件元数据配置
class PluginMetadata {
  final String name;
  final String version;
  final String description;
  final String author;
  final String type;
  final String entryPoint;
  final List<String> dependencies;
  final Map<String, dynamic> config;
  final DateTime createdAt;
  final DateTime updatedAt;

  PluginMetadata({
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.type,
    required this.entryPoint,
    this.dependencies = const [],
    this.config = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON创建插件元数据
  factory PluginMetadata.fromJson(Map<String, dynamic> json) {
    return PluginMetadata(
      name: json['name'] ?? '',
      version: json['version'] ?? '1.0.0',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      type: json['type'] ?? 'tool',
      entryPoint: json['entryPoint'] ?? 'main.dart',
      dependencies: List<String>.from(json['dependencies'] ?? []),
      config: Map<String, dynamic>.from(json['config'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'author': author,
      'type': type,
      'entryPoint': entryPoint,
      'dependencies': dependencies,
      'config': config,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 验证元数据完整性
  List<String> validate() {
    final errors = <String>[];

    if (name.isEmpty) errors.add('插件名称不能为空');
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(name)) {
      errors.add('插件名称只能包含字母、数字和下划线，且必须以字母开头');
    }

    if (version.isEmpty) errors.add('版本号不能为空');
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
      errors.add('版本号格式不正确，应为x.y.z格式');
    }

    if (description.isEmpty) errors.add('描述不能为空');
    if (author.isEmpty) errors.add('作者不能为空');
    if (type.isEmpty) errors.add('类型不能为空');
    if (entryPoint.isEmpty) errors.add('入口文件不能为空');

    return errors;
  }
}

/// 插件模板配置
class PluginTemplate {
  final String type;
  final String name;
  final String description;
  final Map<String, dynamic> files;
  final List<String> dependencies;

  const PluginTemplate({
    required this.type,
    required this.name,
    required this.description,
    required this.files,
    this.dependencies = const [],
  });

  /// 获取模板文件内容
  String getFileContent(String fileName) {
    return files[fileName] ?? '';
  }
}

/// 模板类型常量
class PluginTemplateTypes {
  static const String tool = 'tool';
  static const String theme = 'theme';
  static const String language = 'language';
  static const String integration = 'integration';
  static const String custom = 'custom';

  /// 获取所有模板类型
  static List<String> get allTypes => [
    tool,
    theme,
    language,
    integration,
    custom,
  ];

  /// 获取模板显示名称
  static String getDisplayName(String type) {
    switch (type) {
      case tool:
        return '工具插件';
      case theme:
        return '主题插件';
      case language:
        return '语言支持';
      case integration:
        return '集成插件';
      case custom:
        return '自定义插件';
      default:
        return '工具插件';
    }
  }

  /// 获取模板描述
  static String getDescription(String type) {
    switch (type) {
      case tool:
        return '提供特定功能的工具';
      case theme:
        return '提供界面主题和样式';
      case language:
        return '提供编程语言支持';
      case integration:
        return '集成第三方服务';
      case custom:
        return '完全自定义的插件';
      default:
        return '提供特定功能的工具';
    }
  }

  /// 获取模板图标
  static IconData getIcon(String type) {
    switch (type) {
      case tool:
        return Icons.build;
      case theme:
        return Icons.palette;
      case language:
        return Icons.code;
      case integration:
        return Icons.link;
      case custom:
        return Icons.settings;
      default:
        return Icons.build;
    }
  }
}

/// 插件创建器
class PluginCreator {
  static final Map<String, PluginTemplate> _templates = {
    PluginTemplateTypes.tool: PluginTemplate(
      type: PluginTemplateTypes.tool,
      name: '工具插件模板',
      description: '提供特定功能的工具插件模板',
      dependencies: ['flutter', 'provider'],
      files: {
        'manifest.json': '''
{
  "name": "{name}",
  "version": "{version}",
  "description": "{description}",
  "author": "{author}",
  "type": "tool",
  "entryPoint": "lib/main.dart",
  "dependencies": ["flutter", "provider"],
  "config": {}
}
''',
        'pubspec.yaml': '''
name: {name}
description: {description}
version: {version}

environment:
  sdk: ">=2.19.0 <3.0.0"
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
''',
        'lib/main.dart': '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PluginState(),
      child: const PluginApp(),
    ),
  );
}

class PluginState extends ChangeNotifier {
  // 插件状态管理
}

class PluginApp extends StatelessWidget {
  const PluginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '{name}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PluginHomePage(),
    );
  }
}

class PluginHomePage extends StatelessWidget {
  const PluginHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{name}'),
      ),
      body: const Center(
        child: Text('欢迎使用 {name} 插件！'),
      ),
    );
  }
}
''',
        'README.md': '''
# {name}

{description}

## 功能特性

- 功能1
- 功能2
- 功能3

## 安装说明

1. 下载插件文件
2. 在系统中安装插件
3. 重启应用

## 使用说明

详细的使用说明...

## 开发信息

- 作者: {author}
- 版本: {version}
- 更新日期: {createdAt}
''',
      },
    ),
    PluginTemplateTypes.theme: PluginTemplate(
      type: PluginTemplateTypes.theme,
      name: '主题插件模板',
      description: '提供界面主题和样式的插件模板',
      dependencies: ['flutter'],
      files: {
        'manifest.json': '''
{
  "name": "{name}",
  "version": "{version}",
  "description": "{description}",
  "author": "{author}",
  "type": "theme",
  "entryPoint": "lib/theme.dart",
  "dependencies": ["flutter"],
  "config": {
    "primaryColor": "#2196F3",
    "accentColor": "#FF4081"
  }
}
''',
        'lib/theme.dart': '''
import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Color(0xFF2196F3),
      colorScheme: ColorScheme.light(
        primary: Color(0xFF2196F3),
        secondary: Color(0xFFFF4081),
      ),
      // 更多主题配置...
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Color(0xFF2196F3),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF2196F3),
        secondary: Color(0xFFFF4081),
      ),
      // 更多主题配置...
    );
  }
}
''',
      },
    ),
  };

  /// 创建插件项目
  static Future<PluginCreationResult> createPlugin({
    required PluginMetadata metadata,
    required String templateType,
    required String outputDirectory,
  }) async {
    try {
      // 验证元数据
      final validationErrors = metadata.validate();
      if (validationErrors.isNotEmpty) {
        return PluginCreationResult(success: false, errors: validationErrors);
      }

      // 检查输出目录
      final outputDir = Directory(outputDirectory);
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // 获取模板
      final template = _templates[templateType];
      if (template == null) {
        return PluginCreationResult(
          success: false,
          errors: ['不支持的插件模板类型: $templateType'],
        );
      }

      // 创建插件目录结构
      final pluginDir = Directory(path.join(outputDirectory, metadata.name));
      if (await pluginDir.exists()) {
        return PluginCreationResult(
          success: false,
          errors: ['插件目录已存在: ${pluginDir.path}'],
        );
      }
      await pluginDir.create(recursive: true);

      // 生成文件
      final createdFiles = <String>[];
      for (final entry in template.files.entries) {
        final filePath = path.join(pluginDir.path, entry.key);
        final fileContent = _processTemplate(entry.value, metadata);

        // 确保目录存在
        final fileDir = Directory(path.dirname(filePath));
        if (!await fileDir.exists()) {
          await fileDir.create(recursive: true);
        }

        // 写入文件
        final file = File(filePath);
        await file.writeAsString(fileContent);
        createdFiles.add(filePath);
      }

      // 创建插件包
      final packageResult = await _createPluginPackage(
        pluginDir.path,
        metadata,
      );
      if (!packageResult.success) {
        return packageResult;
      }

      return PluginCreationResult(
        success: true,
        pluginPath: pluginDir.path,
        packagePath: packageResult.packagePath,
        createdFiles: createdFiles,
      );
    } catch (e) {
      return PluginCreationResult(success: false, errors: ['创建插件时发生错误: $e']);
    }
  }

  /// 处理模板变量替换
  static String _processTemplate(String template, PluginMetadata metadata) {
    return template
        .replaceAll('{name}', metadata.name)
        .replaceAll('{version}', metadata.version)
        .replaceAll('{description}', metadata.description)
        .replaceAll('{author}', metadata.author)
        .replaceAll('{type}', metadata.type)
        .replaceAll('{createdAt}', metadata.createdAt.toIso8601String())
        .replaceAll('{updatedAt}', metadata.updatedAt.toIso8601String());
  }

  /// 创建插件包
  static Future<PluginCreationResult> _createPluginPackage(
    String pluginDir,
    PluginMetadata metadata,
  ) async {
    try {
      final packageName = '${metadata.name}_v${metadata.version}.pkg-app';
      final packagePath = path.join(pluginDir, packageName);

      // 这里应该实现实际的打包逻辑
      // 目前先创建一个简单的标记文件
      final packageFile = File(packagePath);
      await packageFile.writeAsString('Plugin Package: ${metadata.name}');

      return PluginCreationResult(success: true, packagePath: packagePath);
    } catch (e) {
      return PluginCreationResult(success: false, errors: ['创建插件包失败: $e']);
    }
  }

  /// 获取所有可用的模板
  static List<PluginTemplate> getAvailableTemplates() {
    return _templates.values.toList();
  }

  /// 验证插件目录结构
  static Future<List<String>> validatePluginDirectory(String directory) async {
    final errors = <String>[];
    final dir = Directory(directory);

    if (!await dir.exists()) {
      errors.add('目录不存在: $directory');
      return errors;
    }

    // 检查必需文件
    final requiredFiles = ['manifest.json', 'pubspec.yaml'];
    for (final file in requiredFiles) {
      final filePath = path.join(directory, file);
      if (!await File(filePath).exists()) {
        errors.add('必需文件缺失: $file');
      }
    }

    // 验证manifest.json
    final manifestFile = File(path.join(directory, 'manifest.json'));
    if (await manifestFile.exists()) {
      try {
        final content = await manifestFile.readAsString();
        final manifest = json.decode(content);
        final metadata = PluginMetadata.fromJson(manifest);
        errors.addAll(metadata.validate());
      } catch (e) {
        errors.add('manifest.json格式错误: $e');
      }
    }

    return errors;
  }
}

/// 插件创建结果
class PluginCreationResult {
  final bool success;
  final String? pluginPath;
  final String? packagePath;
  final List<String> createdFiles;
  final List<String> errors;

  PluginCreationResult({
    required this.success,
    this.pluginPath,
    this.packagePath,
    this.createdFiles = const [],
    this.errors = const [],
  });

  @override
  String toString() {
    if (success) {
      return '插件创建成功!\\n'
          '插件路径: $pluginPath\\n'
          '包路径: $packagePath\\n'
          '创建文件: ${createdFiles.length}个';
    } else {
      return '插件创建失败!\\n错误: ${errors.join("\\n")}';
    }
  }
}

/// 插件管理器
class PluginManager {
  static final PluginManager _instance = PluginManager._internal();

  factory PluginManager() => _instance;

  PluginManager._internal();

  final Map<String, dynamic> _loadedPlugins = {};

  /// 安装插件
  Future<PluginInstallResult> installPlugin(String packagePath) async {
    try {
      // 验证插件包
      final validationResult = await _validatePluginPackage(packagePath);
      if (!validationResult.success) {
        return PluginInstallResult(
          success: false,
          errors: validationResult.errors,
        );
      }

      // 解压插件包
      final extractResult = await _extractPluginPackage(packagePath);
      if (!extractResult.success) {
        return PluginInstallResult(
          success: false,
          errors: extractResult.errors,
        );
      }

      // 加载插件
      final loadResult = await _loadPlugin(extractResult.pluginPath!);
      if (!loadResult.success) {
        return PluginInstallResult(success: false, errors: loadResult.errors);
      }

      return PluginInstallResult(
        success: true,
        pluginId: loadResult.pluginId,
        pluginPath: extractResult.pluginPath,
      );
    } catch (e) {
      return PluginInstallResult(success: false, errors: ['安装插件时发生错误: $e']);
    }
  }

  /// 验证插件包
  Future<PluginValidationResult> _validatePluginPackage(
    String packagePath,
  ) async {
    final file = File(packagePath);
    if (!await file.exists()) {
      return PluginValidationResult(
        success: false,
        errors: ['插件包文件不存在: $packagePath'],
      );
    }

    // 这里应该实现实际的验证逻辑
    // 目前先简单返回成功
    return PluginValidationResult(success: true);
  }

  /// 解压插件包
  Future<PluginExtractResult> _extractPluginPackage(String packagePath) async {
    // 这里应该实现实际的解压逻辑
    // 目前先简单返回插件目录
    final pluginDir = path.join(
      path.dirname(packagePath),
      path.basenameWithoutExtension(packagePath),
    );

    return PluginExtractResult(success: true, pluginPath: pluginDir);
  }

  /// 加载插件
  Future<PluginLoadResult> _loadPlugin(String pluginPath) async {
    // 这里应该实现实际的加载逻辑
    // 目前先简单返回成功
    final pluginId = 'plugin_${DateTime.now().millisecondsSinceEpoch}';

    return PluginLoadResult(success: true, pluginId: pluginId);
  }
}

/// 插件安装结果
class PluginInstallResult {
  final bool success;
  final String? pluginId;
  final String? pluginPath;
  final List<String> errors;

  PluginInstallResult({
    required this.success,
    this.pluginId,
    this.pluginPath,
    this.errors = const [],
  });
}

/// 插件验证结果
class PluginValidationResult {
  final bool success;
  final List<String> errors;

  PluginValidationResult({required this.success, this.errors = const []});
}

/// 插件解压结果
class PluginExtractResult {
  final bool success;
  final String? pluginPath;
  final List<String> errors;

  PluginExtractResult({
    required this.success,
    this.pluginPath,
    this.errors = const [],
  });
}

/// 插件加载结果
class PluginLoadResult {
  final bool success;
  final String? pluginId;
  final List<String> errors;

  PluginLoadResult({
    required this.success,
    this.pluginId,
    this.errors = const [],
  });
}
