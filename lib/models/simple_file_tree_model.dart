
import 'dart:io';

class SimpleFileTreeItem {
  final String path;
  final String name;
  final bool isDirectory;
  final int size;
  final DateTime modifiedDate;
  bool isExpanded;
  List<SimpleFileTreeItem> children;

  SimpleFileTreeItem({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.size,
    required this.modifiedDate,
    this.isExpanded = false,
    this.children = const [],
  }) {
    // 确保children是可修改的列表
    children = List<SimpleFileTreeItem>.from(children);
  }

  @override
  String toString() {
    return 'SimpleFileTreeItem{name: $name, isDirectory: $isDirectory, isExpanded: $isExpanded, children: ${children.length}}';
  }
}

class SimpleFileTreeManager {
  /// 构建简单的文件树，只包含当前目录的直接子项
  static Future<List<SimpleFileTreeItem>> buildSimpleFileTree(String directoryPath) async {
    try {
      print('Building simple file tree for directory: $directoryPath');
      
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return [];
      }

      final entities = await directory.list().toList();
      final items = <SimpleFileTreeItem>[];
      
      for (final entity in entities) {
        final stat = entity.statSync();
        final item = SimpleFileTreeItem(
          path: entity.path,
          name: _getBasename(entity.path),
          isDirectory: stat.type == FileSystemEntityType.directory,
          size: stat.size,
          modifiedDate: stat.modified,
        );
        
        items.add(item);
        print('Added item: ${item.name} (${item.isDirectory ? 'dir' : 'file'})');
      }
      
      // 排序：文件夹在前，文件在后，按名称排序
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      print('Simple file tree built successfully with ${items.length} items');
      return items;
    } catch (e) {
      print('Error building simple file tree: $e');
      rethrow;
    }
  }

  /// 展开文件夹，加载子项
  static Future<void> expandFolder(SimpleFileTreeItem folder) async {
    try {
      if (!folder.isDirectory || folder.isExpanded) {
        return;
      }

      print('Expanding folder: ${folder.path}');
      
      final directory = Directory(folder.path);
      if (!await directory.exists()) {
        return;
      }

      final entities = await directory.list().toList();
      folder.children.clear();
      
      for (final entity in entities) {
        final stat = entity.statSync();
        final item = SimpleFileTreeItem(
          path: entity.path,
          name: _getBasename(entity.path),
          isDirectory: stat.type == FileSystemEntityType.directory,
          size: stat.size,
          modifiedDate: stat.modified,
        );
        
        folder.children.add(item);
        print('Added child: ${item.name} to folder ${folder.name}');
      }
      
      // 排序子项
      folder.children.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      
      folder.isExpanded = true;
      print('Folder ${folder.name} expanded with ${folder.children.length} children');
    } catch (e) {
      print('Error expanding folder ${folder.path}: $e');
    }
  }

  /// 收起文件夹
  static void collapseFolder(SimpleFileTreeItem folder) {
    if (!folder.isDirectory) {
      return;
    }
    
    print('Collapsing folder: ${folder.name}');
    folder.isExpanded = false;
    folder.children.clear();
  }

  static String _getBasename(String filePath) {
    final separatorIndex = filePath.lastIndexOf(Platform.pathSeparator);
    if (separatorIndex == -1) {
      return filePath;
    }
    return filePath.substring(separatorIndex + 1);
  }
}