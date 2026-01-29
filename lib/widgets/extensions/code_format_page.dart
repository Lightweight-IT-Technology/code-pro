import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class CodeFormatPage extends StatefulWidget {
  const CodeFormatPage({super.key});

  @override
  State<CodeFormatPage> createState() => _CodeFormatPageState();
}

class _CodeFormatPageState extends State<CodeFormatPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _selectedLanguage = 'dart';
  bool _isFormatting = false;

  final List<String> _supportedLanguages = [
    'dart',
    'javascript',
    'typescript',
    'python',
    'java',
    'cpp',
    'csharp',
    'html',
    'css',
    'json',
    'xml',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentFileContent();
  }

  void _loadCurrentFileContent() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;

    if (editorState != null && editorState.filePath.isNotEmpty) {
      try {
        final content = await FileService.readFile(editorState.filePath);
        setState(() {
          _inputController.text = content;
          _detectLanguage(editorState.filePath);
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载文件失败: $e')));
      }
    }
  }

  void _detectLanguage(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    final languageMap = {
      'dart': 'dart',
      'js': 'javascript',
      'ts': 'typescript',
      'py': 'python',
      'java': 'java',
      'cpp': 'cpp',
      'cs': 'csharp',
      'html': 'html',
      'css': 'css',
      'json': 'json',
      'xml': 'xml',
    };

    if (languageMap.containsKey(extension)) {
      setState(() {
        _selectedLanguage = languageMap[extension]!;
      });
    }
  }

  void _formatCode() async {
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入要格式化的代码')));
      return;
    }

    setState(() {
      _isFormatting = true;
    });

    try {
      // 模拟格式化过程
      await Future.delayed(const Duration(milliseconds: 500));

      final formattedCode = _simulateFormatting(
        _inputController.text,
        _selectedLanguage,
      );

      setState(() {
        _outputController.text = formattedCode;
        _isFormatting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('代码格式化完成')));
    } catch (e) {
      setState(() {
        _isFormatting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('格式化失败: $e')));
    }
  }

  String _simulateFormatting(String code, String language) {
    // 简单的格式化模拟
    final lines = code.split('\n');
    final formattedLines = <String>[];
    int indentLevel = 0;

    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        formattedLines.add('');
        continue;
      }

      // 处理缩进减少的情况
      if (trimmedLine.endsWith('}') ||
          trimmedLine.endsWith(']') ||
          trimmedLine.endsWith(')')) {
        indentLevel = (indentLevel - 1).clamp(0, 10);
      }

      // 添加缩进
      final indentedLine = '  ' * indentLevel + trimmedLine;
      formattedLines.add(indentedLine);

      // 处理缩进增加的情况
      if (trimmedLine.endsWith('{') ||
          trimmedLine.endsWith('[') ||
          trimmedLine.endsWith('(')) {
        indentLevel++;
      }
    }

    return formattedLines.join('\n');
  }

  void _copyToClipboard() {
    if (_outputController.text.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
    }
  }

  void _applyToFile() async {
    if (_outputController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先格式化代码')));
      return;
    }

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;

    if (editorState != null && editorState.filePath.isNotEmpty) {
      try {
        await FileService.writeFile(
          editorState.filePath,
          _outputController.text,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已应用到文件')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('应用失败: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('没有打开的文件')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('代码格式化'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentFileContent,
            tooltip: '重新加载当前文件',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 语言选择
            Row(
              children: [
                const Text('选择语言:'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                  items: _supportedLanguages.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _formatCode,
                  icon: _isFormatting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.format_align_left, size: 16),
                  label: Text(_isFormatting ? '格式化中...' : '格式化代码'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 输入输出区域
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 输入区域
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '输入代码:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: _inputController,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(8),
                                border: InputBorder.none,
                                hintText: '请输入要格式化的代码...',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 输出区域
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '格式化结果:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.content_copy, size: 16),
                              onPressed: _copyToClipboard,
                              tooltip: '复制到剪贴板',
                            ),
                            IconButton(
                              icon: const Icon(Icons.file_download, size: 16),
                              onPressed: _applyToFile,
                              tooltip: '应用到文件',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.green.withOpacity(0.05),
                            ),
                            child: TextField(
                              controller: _outputController,
                              maxLines: null,
                              expands: true,
                              readOnly: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(8),
                                border: InputBorder.none,
                                hintText: '格式化结果将显示在这里...',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 统计信息
            Row(
              children: [
                Text('输入字符数: ${_inputController.text.length}'),
                const SizedBox(width: 16),
                Text('输出字符数: ${_outputController.text.length}'),
                const Spacer(),
                Text('语言: $_selectedLanguage'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}

// 文件服务模拟类
class FileService {
  static Future<String> readFile(String filePath) async {
    // 模拟文件读取
    await Future.delayed(const Duration(milliseconds: 100));
    return '// 示例代码\nvoid main() {\n  print("Hello World");\n}';
  }

  static Future<void> writeFile(String filePath, String content) async {
    // 模拟文件写入
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
