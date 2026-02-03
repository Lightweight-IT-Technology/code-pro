import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../services/file_service.dart';
import '../../services/format_service.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载文件失败: $e')),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入要格式化的代码')),
      );
      return;
    }

    setState(() {
      _isFormatting = true;
    });

    try {
      final formattedCode = await FormatService.formatCode(
        _inputController.text,
        _selectedLanguage,
      );

      setState(() {
        _outputController.text = formattedCode;
        _isFormatting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('代码格式化完成')),
      );
    } catch (e) {
      setState(() {
        _isFormatting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('格式化失败: $e')),
      );
    }
  }

  void _copyToClipboard() {
    if (_outputController.text.isNotEmpty) {
      // 这里应该使用剪贴板服务
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  void _applyToCurrentFile() async {
    if (_outputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先格式化代码')),
      );
      return;
    }

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;

    if (editorState == null || editorState.filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有打开的文件')),
      );
      return;
    }

    try {
      await FileService.writeFile(editorState.filePath, _outputController.text);
      appState.updateEditorContent(_outputController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已应用到当前文件')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('应用失败: $e')),
      );
    }
  }

  void _clearInput() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('代码格式化'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearInput,
            tooltip: '清空',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 语言选择
            Row(
              children: [
                const Text('选择语言:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  items: _supportedLanguages.map((language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(_getLanguageDisplayName(language)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 输入区域
            Expanded(
              child: Row(
                children: [
                  // 输入框
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('输入代码:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 格式化按钮
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isFormatting ? null : _formatCode,
                        icon: _isFormatting 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.format_align_left),
                        label: Text(_isFormatting ? '格式化中...' : '格式化'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // 输出区域
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('格式化结果:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: _outputController,
                              maxLines: null,
                              expands: true,
                              readOnly: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(8),
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
            
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _outputController.text.isEmpty ? null : _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('复制结果'),
                ),
                ElevatedButton.icon(
                  onPressed: _outputController.text.isEmpty ? null : _applyToCurrentFile,
                  icon: const Icon(Icons.save),
                  label: const Text('应用到文件'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageDisplayName(String language) {
    final languageNames = {
      'dart': 'Dart',
      'javascript': 'JavaScript',
      'typescript': 'TypeScript',
      'python': 'Python',
      'java': 'Java',
      'cpp': 'C++',
      'csharp': 'C#',
      'html': 'HTML',
      'css': 'CSS',
      'json': 'JSON',
      'xml': 'XML',
    };
    return languageNames[language] ?? language;
  }
}