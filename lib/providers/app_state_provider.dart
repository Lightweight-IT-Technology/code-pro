import 'package:flutter/material.dart';
import 'dart:io';
import '../models/file_model.dart';
import '../models/editor_state.dart';

class AppStateProvider with ChangeNotifier {
  String _currentDirectory = '';
  List<FileModel> _files = [];
  EditorState? _currentEditorState;
  bool _isFileBarVisible = true; // 默认显示文件栏
  bool _isExtensionBarVisible = false; // 默认隐藏拓展栏
  bool _isLoading = false;
  String? _errorMessage;

  String get currentDirectory => _currentDirectory;
  List<FileModel> get files => _files;
  EditorState? get currentEditorState => _currentEditorState;
  bool get isFileBarVisible => _isFileBarVisible;
  bool get isExtensionBarVisible => _isExtensionBarVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setCurrentDirectory(String directory) {
    _currentDirectory = directory;
    notifyListeners();
  }

  void setFiles(List<FileModel> files) {
    _files = files;
    notifyListeners();
  }

  void setCurrentEditorState(EditorState? editorState) {
    _currentEditorState = editorState;
    notifyListeners();
  }

  void setFileBarVisible(bool visible) {
    _isFileBarVisible = visible;
    // 如果显示文件栏，则隐藏拓展栏
    if (visible) {
      _isExtensionBarVisible = false;
    }
    notifyListeners();
  }

  void setExtensionBarVisible(bool visible) {
    _isExtensionBarVisible = visible;
    // 如果显示拓展栏，则隐藏文件栏
    if (visible) {
      _isFileBarVisible = false;
    }
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void updateEditorState({
    String? filePath,
    String? fileName,
    bool? isModified,
    DateTime? lastSaved,
  }) {
    if (_currentEditorState != null) {
      _currentEditorState = _currentEditorState!.copyWith(
        filePath: filePath,
        fileName: fileName,
        isModified: isModified,
        lastSaved: lastSaved,
      );
      notifyListeners();
    }
  }

  void addFile(FileModel file) {
    _files.add(file);
    _files.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    notifyListeners();
  }

  void removeFile(FileModel file) {
    _files.removeWhere((f) => f.path == file.path);
    notifyListeners();
  }

  void updateFile(FileModel oldFile, FileModel newFile) {
    final index = _files.indexWhere((f) => f.path == oldFile.path);
    if (index != -1) {
      _files[index] = newFile;
      notifyListeners();
    }
  }

  void updateEditorContent(String content) {
    if (_currentEditorState != null) {
      // 这里应该更新编辑器内容，但具体实现取决于编辑器组件
      // 目前我们只更新状态，实际内容更新由编辑器组件处理
      notifyListeners();
    }
  }

  void insertTextAtCursor(String text) {
    if (_currentEditorState != null) {
      // 这里应该实现在光标位置插入文本的逻辑
      // 目前我们只通知监听器，实际插入由编辑器组件处理
      notifyListeners();
    }
  }

  void openFile(String filePath) {
    // 这里应该实现打开文件的逻辑
    // 目前我们只更新当前编辑器状态
    setCurrentEditorState(
      EditorState(
        filePath: filePath,
        fileName: filePath.split(Platform.pathSeparator).last,
        isModified: false,
        lastSaved: DateTime.now(),
      ),
    );
  }
}
