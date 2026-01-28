import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/highlight.dart' show Mode;
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/php.dart';
import 'package:highlight/languages/ruby.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/rust.dart';
import 'package:highlight/languages/sql.dart';
import 'package:highlight/languages/bash.dart';
import '../providers/app_state_provider.dart';
import '../services/syntax_service.dart';
import '../services/file_service.dart';
import '../models/editor_state.dart';

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late CodeController _codeController;
  final ScrollController _scrollController = ScrollController();
  bool _isModified = false;
  Timer? _autoSaveTimer;
  EditorState? _currentEditorState;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(text: '', language: dart);
    _setupAutoSave();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrentFile();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final editorState = appState.currentEditorState;

        // 监听编辑器状态变化
        if (editorState != _currentEditorState) {
          _currentEditorState = editorState;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadCurrentFile();
            }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              editorState?.fileName ?? '代码编辑器',
              style: TextStyle(color: _isModified ? Colors.orange : null),
            ),
            actions: [
              if (_isModified)
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.orange),
                  onPressed: _saveFile,
                  tooltip: '保存 (Ctrl+S)',
                ),
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _undo,
                tooltip: '撤销 (Ctrl+Z)',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: _redo,
                tooltip: '重做 (Ctrl+Y)',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  // 这里将实现更多编辑功能
                  switch (value) {
                    case 'find':
                      _showFindDialog();
                      break;
                    case 'replace':
                      _showReplaceDialog();
                      break;
                    case 'format':
                      _formatCode();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(value: 'find', child: Text('查找')),
                  const PopupMenuItem<String>(
                    value: 'replace',
                    child: Text('替换'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'format',
                    child: Text('格式化代码'),
                  ),
                ],
              ),
            ],
          ),
          body: editorState == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '选择一个文件开始编辑',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : _buildEditor(),
        );
      },
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _codeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAutoSave() {
    _codeController.addListener(() {
      if (!_isModified && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isModified = true;
            });
            _updateEditorState();
          }
        });
      }

      // 延迟自动保存
      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer(const Duration(seconds: 2), _autoSave);
    });
  }

  void _autoSave() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;

    if (editorState != null && _isModified) {
      try {
        await FileService.writeFile(editorState.filePath, _codeController.text);
        if (mounted) {
          setState(() {
            _isModified = false;
          });
          _updateEditorState();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('自动保存失败: $e')));
        }
      }
    }
  }

  void _loadCurrentFile() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;

    if (editorState != null && editorState.filePath.isNotEmpty) {
      try {
        final content = await FileService.readFile(editorState.filePath);
        final language = _getLanguageFromFileName(editorState.fileName);

        if (mounted) {
          setState(() {
            _codeController = CodeController(text: content, language: language);
            _isModified = false;
          });

          _setupAutoSave();
          _updateEditorState();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('加载文件失败: $e')));
        }
      }
    }
  }

  Mode _getLanguageFromFileName(String fileName) {
    final language = SyntaxService.getLanguageFromFileName(fileName);

    switch (language) {
      case 'dart':
        return dart;
      case 'java':
        return java;
      case 'python':
        return python;
      case 'javascript':
        return javascript;
      case 'typescript':
        return typescript;
      case 'css':
        return css;
      case 'json':
        return json;
      case 'yaml':
        return yaml;
      case 'markdown':
        return markdown;
      case 'cpp':
        return cpp;
      case 'php':
        return php;
      case 'ruby':
        return ruby;
      case 'go':
        return go;
      case 'rust':
        return rust;
      case 'sql':
        return sql;
      case 'bash':
        return bash;
      default:
        return dart; // 默认使用Dart语法
    }
  }

  void _updateEditorState() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.updateEditorState(
      isModified: _isModified,
      lastSaved: DateTime.now(),
    );
  }

  void _saveFile() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;

    if (editorState != null) {
      try {
        await FileService.writeFile(editorState.filePath, _codeController.text);
        if (mounted) {
          setState(() {
            _isModified = false;
          });
          _updateEditorState();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('文件已保存')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('保存文件失败: $e')));
        }
      }
    }
  }

  void _undo() {
    // 撤销功能需要手动实现
    // 由于code_text_field包的限制，这里使用简单的文本操作
    // final text = _codeController.text;
    // final selection = _codeController.selection;
    // 这里可以添加更复杂的撤销逻辑
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('撤销功能开发中')));
  }

  void _redo() {
    // 重做功能需要手动实现
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('重做功能开发中')));
  }

  Widget _buildEditor() {
    return Column(
      children: [
        // 状态栏
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Text(
                '行: ${_codeController.selection.baseOffset}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Text(
                '列: ${_codeController.selection.extentOffset}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (_isModified)
                Text(
                  '已修改',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                ),
            ],
          ),
        ),

        // 代码编辑器
        Expanded(
          child: CodeField(
            controller: _codeController,
            textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            lineNumberStyle: const LineNumberStyle(
              margin: 8,
              textStyle: TextStyle(fontFamily: 'monospace'),
            ),
            expands: true,
            wrap: false,
          ),
        ),
      ],
    );
  }

  void _showFindDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('查找'),
        content: const Text('查找功能开发中'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showReplaceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('替换'),
        content: const Text('替换功能开发中'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _formatCode() {
    // 这里将实现代码格式化功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('代码格式化功能开发中')));
  }
}
