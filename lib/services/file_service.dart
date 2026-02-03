import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/file_model.dart';

class FileService {
  static Future<String> getApplicationDocumentsDirectory() async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  static Future<String> getUserHomeDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  static Future<List<FileModel>> listFiles(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return [];
      }

      final entities = await directory.list().toList();
      final files = entities
          .map((entity) => FileModel.fromFileSystemEntity(entity))
          .toList();

      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return files;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  static Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  static Future<void> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  static Future<void> createFile(String directoryPath, String fileName) async {
    try {
      final filePath = path.join(directoryPath, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        throw Exception('File already exists: $fileName');
      }

      await file.create();
    } catch (e) {
      throw Exception('Failed to create file: $e');
    }
  }

  static Future<void> createDirectory(
    String parentPath,
    String directoryName,
  ) async {
    try {
      final directoryPath = path.join(parentPath, directoryName);
      final directory = Directory(directoryPath);

      if (await directory.exists()) {
        throw Exception('Directory already exists: $directoryName');
      }

      await directory.create(recursive: true);
    } catch (e) {
      throw Exception('Failed to create directory: $e');
    }
  }

  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  static Future<void> deleteDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to delete directory: $e');
    }
  }

  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  static Future<bool> directoryExists(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      return await directory.exists();
    } catch (e) {
      return false;
    }
  }

  static String getFileExtension(String fileName) {
    return path.extension(fileName).toLowerCase();
  }

  static String getFileNameWithoutExtension(String fileName) {
    return path.basenameWithoutExtension(fileName);
  }

  static String getParentDirectory(String filePath) {
    return path.dirname(filePath);
  }

  static Future<String?> selectDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      return selectedDirectory;
    } catch (e) {
      throw Exception('Failed to select directory: $e');
    }
  }

  static Future<String?> selectFile({List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            allowedExtensions ??
            [
              'dart',
              'txt',
              'md',
              'json',
              'yaml',
              'xml',
              'html',
              'css',
              'js',
              'ts',
              'py',
              'java',
              'cpp',
              'c',
              'cs',
              'php',
              'rb',
              'go',
              'rs',
              'sql',
              'sh',
            ],
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.single.path;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to select file: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchFiles({
    required String directory,
    required String searchPattern,
    String filePattern = '*',
    bool recursive = true,
    bool caseSensitive = false,
    bool matchWholeWord = false,
    bool useRegex = false,
    String searchType = 'content',
  }) async {
    try {
      final results = <Map<String, dynamic>>[];
      final dir = Directory(directory);
      
      if (!await dir.exists()) {
        return results;
      }

      final stream = dir.list(recursive: recursive);
      
      await for (final entity in stream) {
        if (entity is File) {
          final fileName = path.basename(entity.path);
          
          // 检查文件名模式匹配
          if (_matchesPattern(fileName, filePattern)) {
            if (searchType == 'filename') {
              // 文件名搜索
              if (_matchesSearchPattern(fileName, searchPattern, caseSensitive, matchWholeWord, useRegex)) {
                results.add({
                  'path': entity.path,
                  'name': fileName,
                  'type': 'file',
                  'matches': [{'line': 0, 'content': fileName}],
                });
              }
            } else {
              // 文件内容搜索
              try {
                final content = await entity.readAsString();
                final lines = content.split('\n');
                final matches = <Map<String, dynamic>>[];
                
                for (int i = 0; i < lines.length; i++) {
                  final line = lines[i];
                  if (_matchesSearchPattern(line, searchPattern, caseSensitive, matchWholeWord, useRegex)) {
                    matches.add({
                      'line': i + 1,
                      'content': line.trim(),
                    });
                  }
                }
                
                if (matches.isNotEmpty) {
                  results.add({
                    'path': entity.path,
                    'name': fileName,
                    'type': 'file',
                    'matches': matches,
                  });
                }
              } catch (e) {
                // 跳过无法读取的文件
                continue;
              }
            }
          }
        }
      }
      
      return results;
    } catch (e) {
      throw Exception('Failed to search files: $e');
    }
  }

  static bool _matchesPattern(String fileName, String pattern) {
    if (pattern == '*' || pattern.isEmpty) return true;
    
    final regexPattern = pattern
        .replaceAll('.', '\\.')
        .replaceAll('*', '.*')
        .replaceAll('?', '.');
    
    final regex = RegExp(regexPattern, caseSensitive: false);
    return regex.hasMatch(fileName);
  }

  static bool _matchesSearchPattern(
    String text,
    String pattern,
    bool caseSensitive,
    bool matchWholeWord,
    bool useRegex,
  ) {
    if (pattern.isEmpty) return false;
    
    if (useRegex) {
      try {
        final regex = RegExp(pattern, caseSensitive: caseSensitive);
        return regex.hasMatch(text);
      } catch (e) {
        return text.contains(pattern);
      }
    }
    
    if (matchWholeWord) {
      final regexPattern = r'\b' + RegExp.escape(pattern) + r'\b';
      final regex = RegExp(regexPattern, caseSensitive: caseSensitive);
      return regex.hasMatch(text);
    }
    
    return caseSensitive 
        ? text.contains(pattern)
        : text.toLowerCase().contains(pattern.toLowerCase());
  }
}
