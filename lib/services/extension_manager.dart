import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/extensions/code_format_page.dart';
import '../widgets/extensions/code_snippet_page.dart';

/// 拓展接口定义
abstract class Extension {
  String get name;
  String get description;
  String get version;
  String get author;
  String get type;
  IconData get icon;

  /// 执行拓展功能
  Future<void> execute(BuildContext context);

  /// 检查拓展是否可用
  bool isAvailable();
}

/// 拓展管理器
class ExtensionManager {
  static final ExtensionManager _instance = ExtensionManager._internal();

  factory ExtensionManager() => _instance;

  ExtensionManager._internal() {
    _initializeExtensions();
  }

  final Map<String, Extension> _extensions = {};

  /// 初始化所有内置拓展
  void _initializeExtensions() {
    // 代码工具类拓展
    _registerExtension(CodeFormatExtension());
    _registerExtension(CodeSnippetExtension());

    // 文件操作类拓展
    _registerExtension(BatchRenameExtension());
    _registerExtension(FileSearchExtension());

    // 开发工具类拓展
    _registerExtension(ApiTestExtension());
    _registerExtension(TerminalExtension());

    // 系统工具类拓展
    _registerExtension(FileCompareExtension());
    _registerExtension(DatabaseManagerExtension());
  }

  /// 注册拓展
  void _registerExtension(Extension extension) {
    _extensions[extension.name] = extension;
  }

  /// 获取所有拓展
  List<Extension> getExtensions() {
    return _extensions.values.toList();
  }

  /// 根据类型获取拓展
  List<Extension> getExtensionsByType(String type) {
    return _extensions.values.where((ext) => ext.type == type).toList();
  }

  /// 根据名称获取拓展
  Extension? getExtension(String name) {
    return _extensions[name];
  }

  /// 执行拓展
  Future<void> executeExtension(String name, BuildContext context) async {
    final extension = _extensions[name];
    if (extension != null && extension.isAvailable()) {
      await extension.execute(context);
    } else {
      throw Exception('拓展 $name 不可用或不存在');
    }
  }

  /// 搜索拓展
  List<Extension> searchExtensions(String query) {
    final queryLower = query.toLowerCase();
    return _extensions.values
        .where(
          (ext) =>
              ext.name.toLowerCase().contains(queryLower) ||
              ext.description.toLowerCase().contains(queryLower) ||
              ext.type.toLowerCase().contains(queryLower),
        )
        .toList();
  }
}

/// 代码格式化拓展
class CodeFormatExtension implements Extension {
  @override
  String get name => '代码格式化';

  @override
  String get description => '自动格式化代码，支持多种编程语言';

  @override
  String get version => '1.0.0';

  @override
  String get author => '系统内置';

  @override
  String get type => '代码工具';

  @override
  IconData get icon => Icons.format_align_left;

  @override
  Future<void> execute(BuildContext context) async {
    // 打开代码格式化界面
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CodeFormatPage()));
  }

  @override
  bool isAvailable() => true;
}

/// 代码片段管理拓展
class CodeSnippetExtension implements Extension {
  @override
  String get name => '代码片段';

  @override
  String get description => '管理常用代码片段，提高开发效率';

  @override
  String get version => '1.0.0';

  @override
  String get author => '系统内置';

  @override
  String get type => '代码工具';

  @override
  IconData get icon => Icons.snippet_folder;

  @override
  Future<void> execute(BuildContext context) async {
    // 打开代码片段管理界面
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CodeSnippetPage()));
  }

  @override
  bool isAvailable() => true;
}

/// 批量重命名拓展
class BatchRenameExtension implements Extension {
  @override
  String get name => '批量重命名';

  @override
  String get description => '批量重命名文件和文件夹';

  @override
  String get version => '1.0.0';

  @override
  String get author => '系统内置';

  @override
  String get type => '文件操作';

  @override
  IconData get icon => Icons.drive_file_rename_outline;

  @override
  Future<void> execute(BuildContext context) async {
    // 打开批量重命名界面
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => BatchRenamePage()));
  }

  @override
  bool isAvailable() => true;
}

/// 文件搜索拓展
class FileSearchExtension implements Extension {
  @override
  String get name => '文件搜索';

  @override
  String get description => '快速搜索文件内容';

  @override
  String get version => '1.0.0';

  @override
  String get author => '系统内置';

  @override
  String get type => '文件操作';

  @override
  IconData get icon => Icons.search;

  @override
  Future<void> execute(BuildContext context) async {
    // 打开文件搜索界面
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => FileSearchPage()));
  }

  @override
  bool isAvailable() => true;
}

/// API测试工具拓展
class ApiTestExtension implements Extension {
  @override
  String get name => 'API测试';

  @override
  String get description => 'REST API测试工具';

  @override
  String get version => '1.0.0';

  @override
  String get author => '系统内置';

  @override
  String get type => '开发工具';

  @override
  IconData get icon => Icons.api;

  @override
  Future<void> execute(BuildContext context) async {
    // 打开API测试界面
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ApiTestPage()));
  }

  @override
  bool isAvailable() => true;
}

/// 终端模拟器拓展
class TerminalExtension implements Extension {
  @override
  String get name => '终端模拟器';

  @override
  String get description => '内置终端模拟器';

  @override
  String get version => '1.0.0';

  @override
  String get author => '系统内置';

  @override
  String get type => '系统工具';

  @override
  IconData get icon => Icons.terminal;

  @override
  Future<void> execute(BuildContext context) async {
    // 打开终端界面
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => TerminalPage()));
  }

  @override
  bool isAvailable() => true;
}

/// 文件比较拓展
class FileCompareExtension implements Extension {
  @override
  String get name => '文件比较';

  @override
  String get description => '比较两个文件的差异';

  @override
  String get version => '1.0.0';

  @override
  String get author => '系统内置';

  @override
  String get type => '文件操作';

  @override
  IconData get icon => Icons.compare;

  @override
  Future<void> execute(BuildContext context) async {
    // 打开文件比较界面
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => FileComparePage()));
  }

  @override
  bool isAvailable() => true;
}

/// 数据库管理拓展
class DatabaseManagerExtension implements Extension {
  @override
  String get name => '数据库管理';

  @override
  String get description => '数据库连接和管理工具';

  @override
  String get version => '1.0.0';

  @override
  String get author => '系统内置';

  @override
  String get type => '开发工具';

  @override
  IconData get icon => Icons.storage;

  @override
  Future<void> execute(BuildContext context) async {
    // 打开数据库管理界面
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => DatabaseManagerPage()));
  }

  @override
  bool isAvailable() => true;
}

// 占位页面类定义（其他拓展功能页面将在后续实现）
class BatchRenamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('批量重命名')),
      body: Center(child: const Text('批量重命名功能开发中')),
    );
  }
}

class FileSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件搜索')),
      body: Center(child: const Text('文件搜索功能开发中')),
    );
  }
}

class ApiTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API测试')),
      body: Center(child: const Text('API测试功能开发中')),
    );
  }
}

class TerminalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('终端模拟器')),
      body: Center(child: const Text('终端模拟器功能开发中')),
    );
  }
}

class FileComparePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件比较')),
      body: Center(child: const Text('文件比较功能开发中')),
    );
  }
}

class DatabaseManagerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数据库管理')),
      body: Center(child: const Text('数据库管理功能开发中')),
    );
  }
}
