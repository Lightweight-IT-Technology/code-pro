import 'package:flutter/material.dart';
import '../models/file_model.dart';
import '../models/editor_state.dart';

class AppStateProvider with ChangeNotifier {
  String _currentDirectory = '';
  List<FileModel> _files = [];
  EditorState? _currentEditorState;
  bool _isFileBarVisible = true; // 默认显示文件栏
  bool _isLoading = false;
  String? _errorMessage;

  String get currentDirectory => _currentDirectory;
  List<FileModel> get files => _files;
  EditorState? get currentEditorState => _currentEditorState;
  bool get isFileBarVisible => _isFileBarVisible;
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
}
