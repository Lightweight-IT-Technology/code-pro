import 'package:flutter/material.dart';
import 'dart:io';
import 'file_model.dart';

class FileTreeItem {
  final String path;
  final String name;
  final bool isDirectory;
  final int size;
  final DateTime modifiedDate;
  bool isExpanded;
  List<FileTreeItem> children;

  FileTreeItem({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.size,
    required this.modifiedDate,
    this.isExpanded = false,
    this.children = const [],
  }) {
    // 确保children是可修改的列表
    children = List<FileTreeItem>.from(children);
  }

  FileTreeItem copyWith({
    String? path,
    String? name,
    bool? isDirectory,
    int? size,
    DateTime? modifiedDate,
    bool? isExpanded,
    List<FileTreeItem>? children,
  }) {
    return FileTreeItem(
      path: path ?? this.path,
      name: name ?? this.name,
      isDirectory: isDirectory ?? this.isDirectory,
      size: size ?? this.size,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      isExpanded: isExpanded ?? this.isExpanded,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileTreeItem &&
        other.path == path &&
        other.name == name &&
        other.isDirectory == isDirectory &&
        other.size == size &&
        other.modifiedDate == modifiedDate &&
        other.isExpanded == isExpanded &&
        other.children.length == children.length;
  }

  @override
  int get hashCode {
    return Object.hash(
      path,
      name,
      isDirectory,
      size,
      modifiedDate,
      isExpanded,
      children.length,
    );
  }
}

class FileTreeManager {
  static Future<List<FileTreeItem>> buildFileTree(String directoryPath) async {
    try {
      print('Building file tree for directory: $directoryPath');

      final rootItems = <FileTreeItem>[];

      // 递归扫描目录
      await _scanDirectory(directoryPath, rootItems, 0);

      // 对根项目进行排序（文件夹在前，文件在后，按名称排序）
      rootItems.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      print('File tree built successfully with ${rootItems.length} root items');
      return rootItems;
    } catch (e) {
      print('Error building file tree: $e');
      rethrow;
    }
  }

  static Future<void> _scanDirectory(
    String directoryPath,
    List<FileTreeItem> parentItems,
    int depth,
  ) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return;
      }

      final entities = await directory.list().toList();

      for (final entity in entities) {
        final stat = entity.statSync();
        final item = FileTreeItem(
          path: entity.path,
          name: _getBasename(entity.path),
          isDirectory: stat.type == FileSystemEntityType.directory,
          size: stat.size,
          modifiedDate: stat.modified,
        );

        parentItems.add(item);
        print('Added item: ${item.name} (${item.path}) at depth $depth');

        // 如果是目录，递归扫描（但不在初始构建时展开）
        if (item.isDirectory) {
          await _scanDirectory(entity.path, item.children, depth + 1);
        }
      }

      // 对当前层级的项目进行排序
      parentItems.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    } catch (e) {
      print('Error scanning directory $directoryPath: $e');
    }
  }

  static String _getBasename(String filePath) {
    final separatorIndex = filePath.lastIndexOf(Platform.pathSeparator);
    if (separatorIndex == -1) {
      return filePath;
    }
    return filePath.substring(separatorIndex + 1);
  }

  static String _getParentPath(String path) {
    try {
      // 使用Platform.pathSeparator来处理路径
      final separator = Platform.pathSeparator;
      final segments = path.split(separator);

      // 过滤掉空字符串
      final filteredSegments = segments
          .where((segment) => segment.isNotEmpty)
          .toList();

      if (filteredSegments.length > 1) {
        // 重建父路径
        final parentSegments = filteredSegments.sublist(
          0,
          filteredSegments.length - 1,
        );

        // 对于Windows路径，确保包含驱动器号
        if (path.contains(':')) {
          // 如果原始路径有驱动器号，确保父路径也有
          return parentSegments.join(separator);
        } else {
          return parentSegments.join(separator);
        }
      }

      // 如果只有一个段，说明是根目录
      if (filteredSegments.length == 1) {
        return '';
      }

      return '';
    } catch (e) {
      print('Error getting parent path for $path: $e');
      return '';
    }
  }

  static List<FileTreeItem> flattenTree(List<FileTreeItem> tree) {
    final List<FileTreeItem> result = [];

    void traverse(List<FileTreeItem> items, int level) {
      for (final item in items) {
        result.add(item.copyWith());
        if (item.isDirectory && item.isExpanded) {
          traverse(item.children, level + 1);
        }
      }
    }

    traverse(tree, 0);
    return result;
  }

  static void toggleExpansion(FileTreeItem item, List<FileTreeItem> tree) {
    void traverse(List<FileTreeItem> items) {
      for (final currentItem in items) {
        if (currentItem.path == item.path) {
          currentItem.isExpanded = !currentItem.isExpanded;
          return;
        }
        traverse(currentItem.children);
      }
    }

    traverse(tree);
  }

  static FileTreeItem? findItem(String path, List<FileTreeItem> tree) {
    for (final item in tree) {
      if (item.path == path) {
        return item;
      }
      final found = findItem(path, item.children);
      if (found != null) {
        return found;
      }
    }
    return null;
  }
}
