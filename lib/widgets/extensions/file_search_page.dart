import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../services/file_service.dart';

class FileSearchPage extends StatefulWidget {
  const FileSearchPage({super.key});

  @override
  State<FileSearchPage> createState() => _FileSearchPageState();
}

class _FileSearchPageState extends State<FileSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _directoryController = TextEditingController();
  final TextEditingController _filePatternController = TextEditingController();

  String _selectedDirectory = '';
  List<SearchResult> _results = [];
  bool _isSearching = false;
  bool _includeSubdirectories = true;
  bool _caseSensitive = false;
  bool _matchWholeWord = false;
  bool _useRegex = false;
  String _searchType = 'filename'; // filename, content, both

  @override
  void initState() {
    super.initState();
    _loadCurrentDirectory();
  }

  void _loadCurrentDirectory() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final currentDir = appState.currentDirectory;

    if (currentDir.isNotEmpty) {
      setState(() {
        _directoryController.text = currentDir;
        _selectedDirectory = currentDir;
      });
    }
  }

  void _selectDirectory() async {
    final selectedDir = await FileService.selectDirectory();
    if (selectedDir != null) {
      setState(() {
        _directoryController.text = selectedDir;
        _selectedDirectory = selectedDir;
      });
    }
  }

  void _searchFiles() async {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入搜索内容')));
      return;
    }

    if (_selectedDirectory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择搜索目录')));
      return;
    }

    setState(() {
      _isSearching = true;
      _results.clear();
    });

    try {
      final searchPattern = _searchController.text;
      final filePattern = _filePatternController.text.isEmpty
          ? '*'
          : _filePatternController.text;

      final rawResults = await FileService.searchFiles(
        directory: _selectedDirectory,
        searchPattern: searchPattern,
        filePattern: filePattern,
        recursive: _includeSubdirectories,
        caseSensitive: _caseSensitive,
        matchWholeWord: _matchWholeWord,
        useRegex: _useRegex,
        searchType: _searchType,
      );

      // 转换结果类型
      final results = rawResults.map((result) {
        final matches = (result['matches'] as List).map((match) {
          return MatchInfo(
            lineNumber: match['line'] ?? 0,
            startIndex: 0,
            endIndex: 0,
            matchedText: match['content'] ?? '',
          );
        }).toList();

        return SearchResult(
          fileName: result['name'] ?? '',
          filePath: result['path'] ?? '',
          isDirectory: false,
          matches: matches,
          preview: matches.isNotEmpty ? matches.first.matchedText : '',
        );
      }).toList();

      setState(() {
        _results = results;
        _isSearching = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('搜索完成，找到 ${results.length} 个结果')));
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('搜索失败: $e')));
    }
  }

  void _openFile(SearchResult result) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.openFile(result.filePath);
  }

  void _clearResults() {
    setState(() {
      _results.clear();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件搜索'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearResults,
            tooltip: '清空结果',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索配置
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '搜索配置:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 目录选择
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _directoryController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: '搜索目录',
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

                  // 搜索内容
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: '搜索内容',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 文件模式
                  TextField(
                    controller: _filePatternController,
                    decoration: const InputDecoration(
                      labelText: '文件模式 (如: *.dart, *.js)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 搜索类型
                  Row(
                    children: [
                      const Text('搜索类型:', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _searchType,
                        items: const [
                          DropdownMenuItem(
                            value: 'filename',
                            child: Text('文件名'),
                          ),
                          DropdownMenuItem(
                            value: 'content',
                            child: Text('文件内容'),
                          ),
                          DropdownMenuItem(value: 'both', child: Text('两者')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _searchType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 搜索选项
                  Wrap(
                    spacing: 16,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _includeSubdirectories,
                            onChanged: (value) {
                              setState(() {
                                _includeSubdirectories = value ?? false;
                              });
                            },
                          ),
                          const Text('包含子目录'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _caseSensitive,
                            onChanged: (value) {
                              setState(() {
                                _caseSensitive = value ?? false;
                              });
                            },
                          ),
                          const Text('区分大小写'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _matchWholeWord,
                            onChanged: (value) {
                              setState(() {
                                _matchWholeWord = value ?? false;
                              });
                            },
                          ),
                          const Text('全字匹配'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _useRegex,
                            onChanged: (value) {
                              setState(() {
                                _useRegex = value ?? false;
                              });
                            },
                          ),
                          const Text('使用正则'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 搜索按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _searchFiles,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isSearching ? '搜索中...' : '开始搜索'),
                  ),
                ),
              ],
            ),
          ),

          // 搜索结果
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? const Center(child: Text('没有搜索结果'))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '搜索结果 (${_results.length}个)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(
                                _getSearchTypeDisplayName(_searchType),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: Icon(
                                  result.isDirectory
                                      ? Icons.folder
                                      : Icons.insert_drive_file,
                                  color: result.isDirectory
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                                title: Text(result.fileName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(result.filePath),
                                    if (result.matches.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '匹配: ${result.matches.length} 处',
                                        style: const TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                    if (result.preview.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        result.preview,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: result.isDirectory
                                    ? null
                                    : const Icon(Icons.open_in_new),
                                onTap: () => _openFile(result),
                              ),
                            );
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

  String _getSearchTypeDisplayName(String type) {
    final typeNames = {'filename': '文件名搜索', 'content': '内容搜索', 'both': '综合搜索'};
    return typeNames[type] ?? type;
  }
}

class SearchResult {
  final String fileName;
  final String filePath;
  final bool isDirectory;
  final List<MatchInfo> matches;
  final String preview;

  SearchResult({
    required this.fileName,
    required this.filePath,
    required this.isDirectory,
    required this.matches,
    required this.preview,
  });
}

class MatchInfo {
  final int lineNumber;
  final int startIndex;
  final int endIndex;
  final String matchedText;

  MatchInfo({
    required this.lineNumber,
    required this.startIndex,
    required this.endIndex,
    required this.matchedText,
  });
}
