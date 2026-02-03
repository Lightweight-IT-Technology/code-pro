import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../services/file_service.dart';

class FileComparePage extends StatefulWidget {
  const FileComparePage({super.key});

  @override
  State<FileComparePage> createState() => _FileComparePageState();
}

class _FileComparePageState extends State<FileComparePage> {
  final TextEditingController _leftFileController = TextEditingController();
  final TextEditingController _rightFileController = TextEditingController();
  final TextEditingController _leftContentController = TextEditingController();
  final TextEditingController _rightContentController = TextEditingController();
  
  String _leftFilePath = '';
  String _rightFilePath = '';
  List<DiffLine> _diffLines = [];
  bool _isLoading = false;
  bool _showLineNumbers = true;
  bool _ignoreWhitespace = false;
  bool _ignoreCase = false;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentFile();
  }

  void _loadCurrentFile() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;
    
    if (editorState != null && editorState.filePath.isNotEmpty) {
      setState(() {
        _leftFileController.text = editorState.filePath;
        _leftFilePath = editorState.filePath;
      });
    }
  }

  void _selectLeftFile() async {
    final selectedFile = await FileService.selectFile();
    if (selectedFile != null) {
      setState(() {
        _leftFileController.text = selectedFile;
        _leftFilePath = selectedFile;
      });
    }
  }

  void _selectRightFile() async {
    final selectedFile = await FileService.selectFile();
    if (selectedFile != null) {
      setState(() {
        _rightFileController.text = selectedFile;
        _rightFilePath = selectedFile;
      });
    }
  }

  void _compareFiles() async {
    if (_leftFilePath.isEmpty || _rightFilePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要比较的两个文件')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _diffLines.clear();
    });

    try {
      final leftContent = await FileService.readFile(_leftFilePath);
      final rightContent = await FileService.readFile(_rightFilePath);

      setState(() {
        _leftContentController.text = leftContent;
        _rightContentController.text = rightContent;
      });

      final diffResult = _computeDiff(leftContent, rightContent);

      setState(() {
        _diffLines = diffResult;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('比较完成，找到 ${_diffLines.where((d) => d.type != DiffType.equal).length} 处差异')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('比较失败: $e')),
      );
    }
  }

  List<DiffLine> _computeDiff(String leftContent, String rightContent) {
    final leftLines = _prepareContent(leftContent).split('\n');
    final rightLines = _prepareContent(rightContent).split('\n');
    
    final diffLines = <DiffLine>[];
    int leftIndex = 0;
    int rightIndex = 0;
    
    while (leftIndex < leftLines.length || rightIndex < rightLines.length) {
      if (leftIndex < leftLines.length && rightIndex < rightLines.length) {
        if (leftLines[leftIndex] == rightLines[rightIndex]) {
          diffLines.add(DiffLine(
            leftLineNumber: leftIndex + 1,
            rightLineNumber: rightIndex + 1,
            leftContent: leftLines[leftIndex],
            rightContent: rightLines[rightIndex],
            type: DiffType.equal,
          ));
          leftIndex++;
          rightIndex++;
        } else {
          // 查找最长匹配
          final match = _findBestMatch(leftLines, rightLines, leftIndex, rightIndex);
          
          // 添加删除的行
          for (int i = leftIndex; i < match.leftIndex; i++) {
            diffLines.add(DiffLine(
              leftLineNumber: i + 1,
              rightLineNumber: -1,
              leftContent: leftLines[i],
              rightContent: '',
              type: DiffType.deleted,
            ));
          }
          
          // 添加新增的行
          for (int i = rightIndex; i < match.rightIndex; i++) {
            diffLines.add(DiffLine(
              leftLineNumber: -1,
              rightLineNumber: i + 1,
              leftContent: '',
              rightContent: rightLines[i],
              type: DiffType.added,
            ));
          }
          
          leftIndex = match.leftIndex;
          rightIndex = match.rightIndex;
        }
      } else if (leftIndex < leftLines.length) {
        // 剩余左文件内容
        diffLines.add(DiffLine(
          leftLineNumber: leftIndex + 1,
          rightLineNumber: -1,
          leftContent: leftLines[leftIndex],
          rightContent: '',
          type: DiffType.deleted,
        ));
        leftIndex++;
      } else {
        // 剩余右文件内容
        diffLines.add(DiffLine(
          leftLineNumber: -1,
          rightLineNumber: rightIndex + 1,
          leftContent: '',
          rightContent: rightLines[rightIndex],
          type: DiffType.added,
        ));
        rightIndex++;
      }
    }
    
    return diffLines;
  }

  String _prepareContent(String content) {
    String prepared = content;
    
    if (_ignoreWhitespace) {
      prepared = prepared.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    
    if (_ignoreCase) {
      prepared = prepared.toLowerCase();
    }
    
    return prepared;
  }

  MatchResult _findBestMatch(List<String> left, List<String> right, int leftStart, int rightStart) {
    int maxLength = 0;
    int bestLeft = leftStart;
    int bestRight = rightStart;
    
    for (int i = leftStart; i < left.length; i++) {
      for (int j = rightStart; j < right.length; j++) {
        if (left[i] == right[j]) {
          int length = 1;
          while (i + length < left.length && 
                 j + length < right.length && 
                 left[i + length] == right[j + length]) {
            length++;
          }
          
          if (length > maxLength) {
            maxLength = length;
            bestLeft = i;
            bestRight = j;
          }
        }
      }
    }
    
    return MatchResult(bestLeft, bestRight);
  }

  void _clearComparison() {
    setState(() {
      _leftContentController.clear();
      _rightContentController.clear();
      _diffLines.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件比较'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearComparison,
            tooltip: '清空比较',
          ),
        ],
      ),
      body: Column(
        children: [
          // 文件选择
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('文件选择:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _leftFileController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: '左侧文件',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _selectLeftFile,
                        icon: const Icon(Icons.file_open),
                        label: const Text('选择'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _rightFileController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: '右侧文件',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _selectRightFile,
                        icon: const Icon(Icons.file_open),
                        label: const Text('选择'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 比较选项
                  Wrap(
                    spacing: 16,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showLineNumbers,
                            onChanged: (value) {
                              setState(() {
                                _showLineNumbers = value ?? false;
                              });
                            },
                          ),
                          const Text('显示行号'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _ignoreWhitespace,
                            onChanged: (value) {
                              setState(() {
                                _ignoreWhitespace = value ?? false;
                              });
                            },
                          ),
                          const Text('忽略空白'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _ignoreCase,
                            onChanged: (value) {
                              setState(() {
                                _ignoreCase = value ?? false;
                              });
                            },
                          ),
                          const Text('忽略大小写'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 比较按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _compareFiles,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.compare),
                    label: Text(_isLoading ? '比较中...' : '开始比较'),
                  ),
                ),
              ],
            ),
          ),
          
          // 比较结果
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _diffLines.isEmpty
                    ? const Center(child: Text('没有比较结果'))
                    : Row(
                        children: [
                          // 左侧文件
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.grey)),
                              ),
                              child: ListView.builder(
                                itemCount: _diffLines.length,
                                itemBuilder: (context, index) {
                                  final diff = _diffLines[index];
                                  return _buildDiffLine(diff, true);
                                },
                              ),
                            ),
                          ),
                          
                          // 右侧文件
                          Expanded(
                            child: ListView.builder(
                              itemCount: _diffLines.length,
                              itemBuilder: (context, index) {
                                final diff = _diffLines[index];
                                return _buildDiffLine(diff, false);
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffLine(DiffLine diff, bool isLeft) {
    final lineNumber = isLeft ? diff.leftLineNumber : diff.rightLineNumber;
    final content = isLeft ? diff.leftContent : diff.rightContent;
    
    Color backgroundColor;
    Color textColor;
    
    switch (diff.type) {
      case DiffType.equal:
        backgroundColor = Colors.transparent;
        textColor = Colors.black;
        break;
      case DiffType.added:
        backgroundColor = isLeft ? Colors.transparent : Colors.green.shade100;
        textColor = isLeft ? Colors.grey : Colors.green.shade900;
        break;
      case DiffType.deleted:
        backgroundColor = isLeft ? Colors.red.shade100 : Colors.transparent;
        textColor = isLeft ? Colors.red.shade900 : Colors.grey;
        break;
    }
    
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showLineNumbers) ...[
            Container(
              width: 40,
              alignment: Alignment.centerRight,
              child: Text(
                lineNumber > 0 ? lineNumber.toString() : '',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontFamily: 'Courier New',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiffLine {
  final int leftLineNumber;
  final int rightLineNumber;
  final String leftContent;
  final String rightContent;
  final DiffType type;

  DiffLine({
    required this.leftLineNumber,
    required this.rightLineNumber,
    required this.leftContent,
    required this.rightContent,
    required this.type,
  });
}

enum DiffType {
  equal,
  added,
  deleted,
}

class MatchResult {
  final int leftIndex;
  final int rightIndex;

  MatchResult(this.leftIndex, this.rightIndex);
}