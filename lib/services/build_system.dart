import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

/// 构建配置类
class BuildConfig {
  final String name;
  final String version;
  final String description;
  final String targetPlatform;
  final String buildMode;
  final Map<String, dynamic> buildOptions;
  final List<String> dependencies;
  final List<String> buildSteps;
  final DateTime createdAt;
  final DateTime updatedAt;

  BuildConfig({
    required this.name,
    required this.version,
    required this.description,
    required this.targetPlatform,
    this.buildMode = 'release',
    this.buildOptions = const {},
    this.dependencies = const [],
    this.buildSteps = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON创建构建配置
  factory BuildConfig.fromJson(Map<String, dynamic> json) {
    return BuildConfig(
      name: json['name'] ?? '',
      version: json['version'] ?? '1.0.0',
      description: json['description'] ?? '',
      targetPlatform: json['targetPlatform'] ?? 'windows',
      buildMode: json['buildMode'] ?? 'release',
      buildOptions: Map<String, dynamic>.from(json['buildOptions'] ?? {}),
      dependencies: List<String>.from(json['dependencies'] ?? []),
      buildSteps: List<String>.from(json['buildSteps'] ?? []),
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
      'targetPlatform': targetPlatform,
      'buildMode': buildMode,
      'buildOptions': buildOptions,
      'dependencies': dependencies,
      'buildSteps': buildSteps,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 验证配置完整性
  List<String> validate() {
    final errors = <String>[];

    if (name.isEmpty) errors.add('构建配置名称不能为空');
    if (version.isEmpty) errors.add('版本号不能为空');
    if (description.isEmpty) errors.add('描述不能为空');
    if (targetPlatform.isEmpty) errors.add('目标平台不能为空');
    if (buildMode.isEmpty) errors.add('构建模式不能为空');

    // 验证目标平台
    final supportedPlatforms = [
      'windows',
      'linux',
      'macos',
      'web',
      'android',
      'ios',
    ];
    if (!supportedPlatforms.contains(targetPlatform)) {
      errors.add('不支持的目标平台: $targetPlatform');
    }

    // 验证构建模式
    final supportedModes = ['debug', 'profile', 'release'];
    if (!supportedModes.contains(buildMode)) {
      errors.add('不支持的构建模式: $buildMode');
    }

    return errors;
  }
}

/// 构建结果类
class BuildResult {
  final bool success;
  final String? buildPath;
  final String? outputPath;
  final List<String> builtFiles;
  final List<String> warnings;
  final List<String> errors;
  final Duration buildDuration;
  final DateTime buildTime;

  BuildResult({
    required this.success,
    this.buildPath,
    this.outputPath,
    this.builtFiles = const [],
    this.warnings = const [],
    this.errors = const [],
    required this.buildDuration,
    required this.buildTime,
  });

  @override
  String toString() {
    if (success) {
      return '构建成功!\n'
          '构建路径: $buildPath\n'
          '输出路径: $outputPath\n'
          '构建文件: ${builtFiles.length}个\n'
          '构建耗时: ${buildDuration.inSeconds}秒\n'
          '警告: ${warnings.length}个';
    } else {
      return '构建失败!\n'
          '错误: ${errors.join("\n")}\n'
          '警告: ${warnings.join("\n")}';
    }
  }
}

/// 构建引擎类
class BuildEngine {
  static final BuildEngine _instance = BuildEngine._internal();

  factory BuildEngine() => _instance;

  BuildEngine._internal();

  /// 构建插件项目
  static Future<BuildResult> buildPlugin({
    required String projectPath,
    required BuildConfig config,
    String? outputPath,
  }) async {
    final stopwatch = Stopwatch()..start();
    final buildTime = DateTime.now();
    final builtFiles = <String>[];
    final warnings = <String>[];
    final errors = <String>[];

    try {
      // 验证配置
      final validationErrors = config.validate();
      if (validationErrors.isNotEmpty) {
        return BuildResult(
          success: false,
          errors: validationErrors,
          buildDuration: stopwatch.elapsed,
          buildTime: buildTime,
        );
      }

      // 检查项目目录
      final projectDir = Directory(projectPath);
      if (!await projectDir.exists()) {
        return BuildResult(
          success: false,
          errors: ['项目目录不存在: $projectPath'],
          buildDuration: stopwatch.elapsed,
          buildTime: buildTime,
        );
      }

      // 检查必需文件
      final requiredFiles = ['pubspec.yaml', 'lib/main.dart'];
      for (final file in requiredFiles) {
        final filePath = path.join(projectPath, file);
        if (!await File(filePath).exists()) {
          errors.add('必需文件缺失: $file');
        }
      }

      if (errors.isNotEmpty) {
        return BuildResult(
          success: false,
          errors: errors,
          buildDuration: stopwatch.elapsed,
          buildTime: buildTime,
        );
      }

      // 设置输出路径
      final buildOutputPath = outputPath ?? path.join(projectPath, 'build');
      final buildDir = Directory(buildOutputPath);
      if (!await buildDir.exists()) {
        await buildDir.create(recursive: true);
      }

      // 执行构建步骤
      final buildSteps = config.buildSteps.isNotEmpty
          ? config.buildSteps
          : _getDefaultBuildSteps(config);

      for (final step in buildSteps) {
        final result = await _executeBuildStep(step, projectPath, config);
        if (!result.success) {
          errors.addAll(result.errors);
          break;
        }
        builtFiles.addAll(result.builtFiles);
        warnings.addAll(result.warnings);
      }

      // 构建完成
      stopwatch.stop();

      return BuildResult(
        success: errors.isEmpty,
        buildPath: projectPath,
        outputPath: buildOutputPath,
        builtFiles: builtFiles,
        warnings: warnings,
        errors: errors,
        buildDuration: stopwatch.elapsed,
        buildTime: buildTime,
      );
    } catch (e) {
      stopwatch.stop();
      return BuildResult(
        success: false,
        errors: ['构建过程中发生错误: $e'],
        buildDuration: stopwatch.elapsed,
        buildTime: buildTime,
      );
    }
  }

  /// 获取默认构建步骤
  static List<String> _getDefaultBuildSteps(BuildConfig config) {
    final steps = <String>[];

    // 根据目标平台和构建模式生成构建步骤
    switch (config.targetPlatform) {
      case 'windows':
        steps.addAll([
          'flutter pub get',
          'flutter build windows --${config.buildMode}',
        ]);
        break;
      case 'linux':
        steps.addAll([
          'flutter pub get',
          'flutter build linux --${config.buildMode}',
        ]);
        break;
      case 'macos':
        steps.addAll([
          'flutter pub get',
          'flutter build macos --${config.buildMode}',
        ]);
        break;
      case 'web':
        steps.addAll([
          'flutter pub get',
          'flutter build web --${config.buildMode}',
        ]);
        break;
      case 'android':
        steps.addAll([
          'flutter pub get',
          'flutter build apk --${config.buildMode}',
        ]);
        break;
      case 'ios':
        steps.addAll([
          'flutter pub get',
          'flutter build ios --${config.buildMode}',
        ]);
        break;
    }

    return steps;
  }

  /// 执行构建步骤
  static Future<BuildStepResult> _executeBuildStep(
    String step,
    String projectPath,
    BuildConfig config,
  ) async {
    final builtFiles = <String>[];
    final warnings = <String>[];
    final errors = <String>[];

    try {
      // 解析构建步骤
      final parts = step.split(' ');
      final command = parts.first;
      final arguments = parts.sublist(1);

      // 执行命令
      final process = await Process.start(
        command,
        arguments,
        workingDirectory: projectPath,
      );

      // 读取输出
      final stdout = await process.stdout.transform(utf8.decoder).join();
      final stderr = await process.stderr.transform(utf8.decoder).join();

      // 等待进程完成
      final exitCode = await process.exitCode;

      if (exitCode != 0) {
        errors.add('构建步骤失败: $step\n错误输出: $stderr');
      } else {
        // 解析构建输出，收集生成的文件
        final outputLines = stdout.split('\n');
        for (final line in outputLines) {
          if (line.contains('Built') || line.contains('Generated')) {
            final fileMatch = RegExp(
              r'([\w\\/.-]+\.(exe|apk|app|dart|js|html))',
            ).firstMatch(line);
            if (fileMatch != null) {
              builtFiles.add(fileMatch.group(1)!);
            }
          }
          if (line.contains('Warning') || line.contains('warning')) {
            warnings.add(line);
          }
        }
      }

      return BuildStepResult(
        success: exitCode == 0,
        builtFiles: builtFiles,
        warnings: warnings,
        errors: errors,
      );
    } catch (e) {
      return BuildStepResult(
        success: false,
        errors: ['执行构建步骤失败: $step\n错误: $e'],
      );
    }
  }

  /// 验证项目结构
  static Future<List<String>> validateProjectStructure(
    String projectPath,
  ) async {
    final errors = <String>[];
    final dir = Directory(projectPath);

    if (!await dir.exists()) {
      errors.add('项目目录不存在: $projectPath');
      return errors;
    }

    // 检查必需文件
    final requiredFiles = ['pubspec.yaml', 'lib/main.dart', 'manifest.json'];

    for (final file in requiredFiles) {
      final filePath = path.join(projectPath, file);
      if (!await File(filePath).exists()) {
        errors.add('必需文件缺失: $file');
      }
    }

    // 验证pubspec.yaml
    final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    if (await pubspecFile.exists()) {
      try {
        final content = await pubspecFile.readAsString();
        if (!content.contains('name:') || !content.contains('version:')) {
          errors.add('pubspec.yaml格式错误: 缺少name或version字段');
        }
      } catch (e) {
        errors.add('pubspec.yaml解析错误: $e');
      }
    }

    // 验证manifest.json
    final manifestFile = File(path.join(projectPath, 'manifest.json'));
    if (await manifestFile.exists()) {
      try {
        final content = await manifestFile.readAsString();
        final manifest = json.decode(content);
        if (manifest['name'] == null || manifest['version'] == null) {
          errors.add('manifest.json格式错误: 缺少必需字段');
        }
      } catch (e) {
        errors.add('manifest.json解析错误: $e');
      }
    }

    return errors;
  }
}

/// 构建步骤结果类
class BuildStepResult {
  final bool success;
  final List<String> builtFiles;
  final List<String> warnings;
  final List<String> errors;

  BuildStepResult({
    required this.success,
    this.builtFiles = const [],
    this.warnings = const [],
    this.errors = const [],
  });
}

/// 构建管理器类
class BuildManager {
  static final BuildManager _instance = BuildManager._internal();

  factory BuildManager() => _instance;

  BuildManager._internal();

  final Map<String, BuildConfig> _buildConfigs = {};
  final Map<String, BuildResult> _buildHistory = {};

  /// 添加构建配置
  void addBuildConfig(String name, BuildConfig config) {
    _buildConfigs[name] = config;
  }

  /// 获取构建配置
  BuildConfig? getBuildConfig(String name) {
    return _buildConfigs[name];
  }

  /// 获取所有构建配置
  List<BuildConfig> getAllBuildConfigs() {
    return _buildConfigs.values.toList();
  }

  /// 执行构建
  Future<BuildResult> executeBuild({
    required String projectPath,
    required String configName,
    String? outputPath,
  }) async {
    final config = _buildConfigs[configName];
    if (config == null) {
      return BuildResult(
        success: false,
        errors: ['构建配置不存在: $configName'],
        buildDuration: Duration.zero,
        buildTime: DateTime.now(),
      );
    }

    final result = await BuildEngine.buildPlugin(
      projectPath: projectPath,
      config: config,
      outputPath: outputPath,
    );

    // 保存构建历史
    _buildHistory['${DateTime.now().millisecondsSinceEpoch}'] = result;

    return result;
  }

  /// 获取构建历史
  List<BuildResult> getBuildHistory() {
    return _buildHistory.values.toList();
  }

  /// 清除构建历史
  void clearBuildHistory() {
    _buildHistory.clear();
  }
}
