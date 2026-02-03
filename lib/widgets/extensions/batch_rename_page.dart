import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../services/file_service.dart';

class BatchRenamePage extends StatefulWidget {
  const BatchRenamePage({super.key});

  @override
  State<BatchRenamePage> createState() => _BatchRenamePageState();
}

class _BatchRenamePageState extends State<BatchRenamePage> {
  final TextEditingController _directoryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  
  String _selectedDirectory = '';
  List<FileInfo> _files = [];
  List<FileInfo> _filteredFiles = [];
  bool _isLoading = false;
  bool _includeSubdirectories = false;
  bool _caseSensitive = false;
  bool _previewMode = true;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentDirectory();
  }

  void _loadCurrentDirectory() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final currentDir = appState.currentDirectory;
    
    if (currentDir.isNotEmpty) {
      setState(() {
        _directoryController.text = currentDir;
        _selectedDirectory = currentDir;
      });
      await _loadFiles();
    }
  }

  void _loadFiles() async {
    if (_selectedDirectory.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final files = await FileService.listFiles(
        _selectedDirectory,
        recursive: _includeSubdirectories,
      );
      
      setState(() {
        _files = files;
        _filteredFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载文件失败: $e')),
      );
    }
  }

  void _updatePreview() {
    final searchText = _searchController.text;
    final replaceText = _replaceController.text;
    final prefix = _prefixController.text;
    final suffix = _suffixController.text;

    if (searchText.isEmpty && prefix.isEmpty && suffix.isEmpty) {
      setState(() {
        _filteredFiles = _files;
      });
      return;
    }

    setState(() {
      _filteredFiles = _files.map((file) {
        String newName = file.name;
        
        // 搜索替换
        if (searchText.isNotEmpty) {
          final pattern = _caseSensitive ? searchText : searchText.toLowerCase();
          final fileName = _caseSensitive ? file.name : file.name.toLowerCase();
          
          if (fileName.contains(pattern)) {
            newName = file.name.replaceAll(searchText, replaceText);
          }
        }
        
        // 添加前缀
        if (prefix.isNotEmpty) {
          newName = prefix + newName;
        }
        
        // 添加后缀
        if (suffix.isNotEmpty) {
          final extension = file.extension;
          if (extension.isNotEmpty) {
            newName = newName.replaceFirst(extension, suffix + extension);
          } else {
            newName = newName + suffix;
          }
        }
        
        return file.copyWith(newName: newName);
      }).toList();
    });
  }

  void _selectDirectory() async {
    final selectedDir = await FileService.selectDirectory();
    if (selectedDir != null) {
      setState(() {
        _directoryController.text = selectedDir;
        _selectedDirectory = selectedDir;
      });
      await _loadFiles();
    }
  }

  void _executeRename() async {
    if (_previewMode) {
      setState(() {
        _previewMode = false;
      });
      return;
    }

    final changes = _filteredFiles.where((file) => file.name != file.newName).toList();
    
    if (changes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有需要重命名的文件')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int successCount = 0;
      int errorCount = 0;
      
      for (final file in changes) {
        try {
          await FileService.renameFile(file.path, file.newPath);
          successCount++;
        } catch (e) {
          errorCount++;
        }
      }
      
      setState(() {
        _isLoading = false;
        _previewMode = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('重命名完成: $successCount 成功, $errorCount 失败')),
      );
      
      await _loadFiles(); // 重新加载文件列表
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('重命名失败: $e')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _searchController.clear();
      _replaceController.clear();
      _prefixController.clear();
      _suffixController.clear();
      _filteredFiles = _files;
      _previewMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('批量重命名'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: '重置',
          ),
        ],
      ),
      body: Column(
        children: [
          // 目录选择
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('选择目录:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _directoryController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            hintText: '选择目录...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _selectDirectory,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('选择'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _includeSubdirectories,
                        onChanged: (value) {
                          setState(() {
                            _includeSubdirectories = value ?? false;
                          });
                          _loadFiles();
                        },
                      ),
                      const Text('包含子目录'),
                      const SizedBox(width: 16),
                      Checkbox(
                        value: _caseSensitive,
                        onChanged: (value) {
                          setState(() {
                            _caseSensitive = value ?? false;
                          });
                          _updatePreview();
                        },
                      ),
                      const Text('区分大小写'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 重命名规则
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('重命名规则:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: '搜索文本',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updatePreview(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _replaceController,
                          decoration: const InputDecoration(
                            labelText: '替换为',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updatePreview(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _prefixController,
                          decoration: const InputDecoration(
                            labelText: '前缀',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updatePreview(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _suffixController,
                          decoration: const InputDecoration(
                            labelText: '后缀',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updatePreview(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 文件列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _files.isEmpty
                    ? const Center(child: Text('没有找到文件'))
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '文件列表 (${_filteredFiles.length}个)',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Chip(
                                  label: Text(_previewMode ? '预览模式' : '执行模式'),
                                  backgroundColor: _previewMode ? Colors.blue : Colors.orange,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _filteredFiles.length,
                              itemBuilder: (context, index) {
                                final file = _filteredFiles[index];
                                final isChanged = file.name != file.newName;
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  color: isChanged ? Colors.blue.shade50 : null,
                                  child: ListTile(
                                    leading: Icon(
                                      file.isDirectory ? Icons.folder : Icons.insert_drive_file,
                                      color: file.isDirectory ? Colors.orange : Colors.blue,
                                    ),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (isChanged) ...[
                                          Text(
                                            file.name,
                                            style: const TextStyle(
                                              decoration: TextDecoration.lineThrough,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            file.newName,
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ] else ...[
                                          Text(file.name),
                                        ],
                                      ],
                                    ),
                                    subtitle: Text(file.path),
                                    trailing: isChanged
                                        ? const Icon(Icons.arrow_forward, color: Colors.green)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
          
          // 操作按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _executeRename,
                  icon: Icon(_previewMode ? Icons.visibility : Icons.play_arrow),
                  label: Text(_previewMode ? '预览更改' : '执行重命名'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _previewMode ? Colors.blue : Colors.orange,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.clear),
                  label: const Text('重置'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FileInfo {
  final String name;
  final String path;
  final bool isDirectory;
  final String newName;
  final String newPath;
  
  FileInfo({
    required this.name,
    required this.path,
    required this.isDirectory,
    String? newName,
    String? newPath,
  }) : 
        newName = newName ?? name,
        newPath = newPath ?? path;
        
  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? '.${parts.last}' : '';
  }
  
  FileInfo copyWith({
    String? name,
    String? path,
    bool? isDirectory,
    String? newName,
    String? newPath,
  }) {
    return FileInfo(
      name: name ?? this.name,
      path: path ?? this.path,
      isDirectory: isDirectory ?? this.isDirectory,
      newName: newName ?? this.newName,
      newPath: newPath ?? this.newPath,
    );
  }
}