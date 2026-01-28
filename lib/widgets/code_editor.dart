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
import 'package:highlight/languages/kotlin.dart';
import 'package:highlight/languages/swift.dart';
import 'package:highlight/languages/cs.dart';
import 'package:highlight/languages/dos.dart';
import 'package:highlight/languages/powershell.dart';
import 'package:highlight/languages/plaintext.dart';
import 'package:highlight/languages/xml.dart';
import '../providers/app_state_provider.dart';
import '../services/syntax_service.dart';
import '../services/file_service.dart';
import '../services/format_service.dart';
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
  Timer? _formatCheckTimer;
  EditorState? _currentEditorState;
  List<String> _formatIssues = [];
  bool _showFormatIssues = false;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '',
      language: dart,
      stringMap: _getCodeTheme(),
    );
    _setupAutoSave();
    _setupFormatCheck();
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
              IconButton(
                icon: Icon(
                  _formatIssues.isEmpty
                      ? Icons.check_circle
                      : Icons.error_outline,
                  color: _formatIssues.isEmpty ? Colors.green : Colors.orange,
                ),
                onPressed: () {
                  setState(() {
                    _showFormatIssues = !_showFormatIssues;
                  });
                },
                tooltip: '格式检查',
              ),
              IconButton(
                icon: const Icon(Icons.format_align_left),
                onPressed: _formatCode,
                tooltip: '格式化代码',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'find':
                      _showFindDialog();
                      break;
                    case 'replace':
                      _showReplaceDialog();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(value: 'find', child: Text('查找')),
                  const PopupMenuItem<String>(
                    value: 'replace',
                    child: Text('替换'),
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
              : _buildEditorWithFormatCheck(),
        );
      },
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _formatCheckTimer?.cancel();
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

  void _setupFormatCheck() {
    _codeController.addListener(() {
      // 延迟格式检查
      _formatCheckTimer?.cancel();
      _formatCheckTimer = Timer(const Duration(seconds: 1), _checkFormat);
    });
  }

  void _checkFormat() {
    if (!mounted) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;

    if (editorState != null && _codeController.text.isNotEmpty) {
      final language = SyntaxService.getLanguageFromFileName(
        editorState.fileName,
      );
      final issues = FormatService.checkFormatIssues(
        _codeController.text,
        language,
      );

      if (mounted) {
        setState(() {
          _formatIssues = issues;
        });
      }
    }
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
            _codeController.dispose(); // 释放旧的控制器
            _codeController = CodeController(
              text: content,
              language: language,
              stringMap: _getCodeTheme(),
            );
            _isModified = false;
          });

          _setupAutoSave();
          _setupFormatCheck();
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
      case 'kotlin':
        return kotlin;
      case 'swift':
        return swift;
      case 'python':
        return python;
      case 'javascript':
        return javascript;
      case 'typescript':
        return typescript;
      case 'html':
        return xml; // HTML使用XML语法高亮
      case 'css':
        return css;
      case 'scss':
        return css; // SCSS使用CSS语法高亮
      case 'json':
        return json;
      case 'xml':
        return xml;
      case 'yaml':
        return yaml;
      case 'markdown':
        return markdown;
      case 'c':
        return cpp; // C语言使用C++语法高亮
      case 'cpp':
        return cpp;
      case 'csharp':
        return cs; // C#使用cs.dart语法高亮
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
      case 'batch':
        return dos; // Batch使用dos.dart语法高亮
      case 'powershell':
        return powershell;
      case 'plaintext':
        return plaintext;
      default:
        return plaintext; // 默认使用纯文本语法
    }
  }

  Map<String, TextStyle> _getCodeTheme() {
    return {
      'root': const TextStyle(color: Color(0xFF000000)),
      'comment': const TextStyle(color: Color(0xFF008000)),
      'quote': const TextStyle(color: Color(0xFF008000)),
      'keyword': const TextStyle(
        color: Color(0xFF0000FF),
        fontWeight: FontWeight.bold,
      ),
      'selector-tag': const TextStyle(
        color: Color(0xFF0000FF),
        fontWeight: FontWeight.bold,
      ),
      'built_in': const TextStyle(color: Color(0xFF0000FF)),
      'name': const TextStyle(color: Color(0xFF0000FF)),
      'type': const TextStyle(color: Color(0xFF0000FF)),
      'literal': const TextStyle(color: Color(0xFF000080)),
      'number': const TextStyle(color: Color(0xFF000080)),
      'string': const TextStyle(color: Color(0xFF008000)),
      'subst': const TextStyle(color: Color(0xFF000000)),
      'regexp': const TextStyle(color: Color(0xFF008000)),
      'link': const TextStyle(color: Color(0xFF008000)),
      'function': const TextStyle(color: Color(0xFF0000FF)),
      'title': const TextStyle(color: Color(0xFF0000FF)),
      'attr': const TextStyle(color: Color(0xFF0000FF)),
      'variable': const TextStyle(color: Color(0xFF000000)),
      'template-variable': const TextStyle(color: Color(0xFF000000)),
      'class-title': const TextStyle(color: Color(0xFF0000FF)),
      'tag': const TextStyle(color: Color(0xFF000080)),
      'meta': const TextStyle(color: Color(0xFF808080)),
      'doctag': const TextStyle(color: Color(0xFF808080)),
      'section': const TextStyle(color: Color(0xFF0000FF)),
      'attribute': const TextStyle(color: Color(0xFF0000FF)),
      'bullet': const TextStyle(color: Color(0xFF000080)),
      'params': const TextStyle(color: Color(0xFF000000)),
      'addition': const TextStyle(color: Color(0xFF008000)),
      'deletion': const TextStyle(color: Color(0xFF800000)),
      'emphasis': const TextStyle(fontStyle: FontStyle.italic),
      'strong': const TextStyle(fontWeight: FontWeight.bold),
    };
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

  Widget _buildEditorWithFormatCheck() {
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
                '行: ${_codeController.selection.base.offset}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Text(
                '列: ${_codeController.selection.extent.offset}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (_formatIssues.isNotEmpty)
                Text(
                  '${_formatIssues.length}个格式问题',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                ),
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

        // 格式检查结果
        if (_showFormatIssues && _formatIssues.isNotEmpty)
          Container(
            height: 120,
            color: Colors.orange.withOpacity(0.1),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '格式检查结果 (${_formatIssues.length}个问题)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        setState(() {
                          _showFormatIssues = false;
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _formatIssues.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          _formatIssues[index],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        // 代码编辑器
        Expanded(
          child: CodeField(
            controller: _codeController,
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Color(0xFF000000),
            ),
            lineNumberStyle: LineNumberStyle(
              margin: 8,
              textStyle: TextStyle(
                fontFamily: 'monospace',
                color: Colors.grey.shade600,
              ),
              background: Colors.grey.shade100,
            ),
            expands: true,
            wrap: false,
            background: Colors.white,
            cursorColor: Colors.blue,
          ),
        ),
      ],
    );
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
                '行: ${_codeController.selection.base.offset}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Text(
                '列: ${_codeController.selection.extent.offset}',
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
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;

    if (editorState != null && _codeController.text.isNotEmpty) {
      try {
        final language = SyntaxService.getLanguageFromFileName(
          editorState.fileName,
        );
        final formattedCode = FormatService.formatCode(
          _codeController.text,
          language,
        );

        setState(() {
          _codeController.value = _codeController.value.copyWith(
            text: formattedCode,
            selection: const TextSelection.collapsed(offset: 0),
          );
          _isModified = true;
          _formatIssues = [];
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('代码格式化完成')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('格式化失败: $e')));
      }
    }
  }
}
