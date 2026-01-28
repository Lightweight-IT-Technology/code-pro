import 'dart:io';

class FileModel {
  final String name;
  final String path;
  final bool isDirectory;
  final DateTime modifiedDate;
  final int size;

  FileModel({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.modifiedDate,
    required this.size,
  });

  String get extension => isDirectory ? '' : _getExtension(name).toLowerCase();

  String get displayName =>
      isDirectory ? name : _getFileNameWithoutExtension(name);

  factory FileModel.fromFileSystemEntity(FileSystemEntity entity) {
    final stat = entity.statSync();
    return FileModel(
      name: _getBasename(entity.path),
      path: entity.path,
      isDirectory: stat.type == FileSystemEntityType.directory,
      modifiedDate: stat.modified,
      size: stat.size,
    );
  }

  static String _getExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex);
  }

  static String _getFileNameWithoutExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) {
      return fileName;
    }
    return fileName.substring(0, dotIndex);
  }

  static String _getBasename(String filePath) {
    final separatorIndex = filePath.lastIndexOf(Platform.pathSeparator);
    if (separatorIndex == -1) {
      return filePath;
    }
    return filePath.substring(separatorIndex + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileModel &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() =>
      'FileModel(name: $name, path: $path, isDirectory: $isDirectory)';
}
