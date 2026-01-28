import 'package:code_text_field/code_text_field.dart';

class EditorState {
  final String filePath;
  final String fileName;
  final CodeController? codeController;
  final bool isModified;
  final DateTime lastSaved;

  EditorState({
    required this.filePath,
    required this.fileName,
    this.codeController,
    this.isModified = false,
    required this.lastSaved,
  });

  EditorState copyWith({
    String? filePath,
    String? fileName,
    CodeController? codeController,
    bool? isModified,
    DateTime? lastSaved,
  }) {
    return EditorState(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      codeController: codeController ?? this.codeController,
      isModified: isModified ?? this.isModified,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorState &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath;

  @override
  int get hashCode => filePath.hashCode;
}
