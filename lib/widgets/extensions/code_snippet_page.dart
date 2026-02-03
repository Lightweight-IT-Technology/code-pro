import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class CodeSnippetPage extends StatefulWidget {
  const CodeSnippetPage({super.key});

  @override
  State<CodeSnippetPage> createState() => _CodeSnippetPageState();
}

class _CodeSnippetPageState extends State<CodeSnippetPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String _selectedLanguage = 'dart';
  String _selectedCategory = '通用';
  bool _isEditing = false;
  int _editingIndex = -1;

  final List<String> _languages = [
    'dart',
    'javascript',
    'typescript',
    'python',
    'java',
    'cpp',
    'csharp',
    'html',
    'css',
    'sql',
    'json',
    'xml',
  ];

  final List<String> _categories = [
    '通用',
    '函数',
    '类',
    '算法',
    '数据结构',
    '工具函数',
    '模板',
  ];

  List<CodeSnippet> _snippets = [
    CodeSnippet(
      name: 'Hello World',
      description: '基础输出示例',
      language: 'dart',
      category: '通用',
      code: 'void main() {\n  print(\'Hello, World!\');\n}',
    ),
    CodeSnippet(
      name: '函数定义',
      description: 'Dart函数定义示例',
      language: 'dart',
      category: '函数',
      code: 'int add(int a, int b) {\n  return a + b;\n}',
    ),
    CodeSnippet(
      name: '类定义',
      description: 'Dart类定义示例',
      language: 'dart',
      category: '类',
      code: 'class Person {\n  String name;\n  int age;\n  \n  Person(this.name, this.age);\n  \n  void introduce() {\n    print(\'我叫\$name，今年\$age岁\');\n  }\n}',
    ),
  ];

  List<CodeSnippet> get _filteredSnippets {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _snippets;
    
    return _snippets.where((snippet) {
      return snippet.name.toLowerCase().contains(query) ||
             snippet.description.toLowerCase().contains(query) ||
             snippet.language.toLowerCase().contains(query) ||
             snippet.category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _addSnippet() {
    if (_nameController.text.isEmpty || _codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写名称和代码')),
      );
      return;
    }

    final snippet = CodeSnippet(
      name: _nameController.text,
      description: _descriptionController.text,
      language: _selectedLanguage,
      category: _selectedCategory,
      code: _codeController.text,
    );

    setState(() {
      _snippets.add(snippet);
      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('代码片段已添加')),
    );
  }

  void _editSnippet(int index) {
    final snippet = _snippets[index];
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _nameController.text = snippet.name;
      _descriptionController.text = snippet.description;
      _selectedLanguage = snippet.language;
      _selectedCategory = snippet.category;
      _codeController.text = snippet.code;
    });
  }

  void _updateSnippet() {
    if (_editingIndex == -1) return;

    final snippet = CodeSnippet(
      name: _nameController.text,
      description: _descriptionController.text,
      language: _selectedLanguage,
      category: _selectedCategory,
      code: _codeController.text,
    );

    setState(() {
      _snippets[_editingIndex] = snippet;
      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('代码片段已更新')),
    );
  }

  void _deleteSnippet(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除代码片段"${_snippets[index].name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _snippets.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('代码片段已删除')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _isEditing = false;
      _editingIndex = -1;
      _nameController.clear();
      _descriptionController.clear();
      _codeController.clear();
      _selectedLanguage = 'dart';
      _selectedCategory = '通用';
    });
  }

  void _insertSnippet(CodeSnippet snippet) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final editorState = appState.currentEditorState;
    
    if (editorState != null) {
      appState.insertTextAtCursor(snippet.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已插入代码片段: ${snippet.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先打开编辑器')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('代码片段管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearForm,
            tooltip: '清空表单',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索代码片段...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // 表单区域
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? '编辑代码片段' : '添加新代码片段',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: '名称*',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: '描述',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            decoration: const InputDecoration(
                              labelText: '语言',
                              border: OutlineInputBorder(),
                            ),
                            items: _languages.map((language) {
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
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: '分类',
                              border: OutlineInputBorder(),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('代码:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextField(
                          controller: _codeController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_isEditing) ...[
                          ElevatedButton(
                            onPressed: _clearForm,
                            child: const Text('取消'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton(
                          onPressed: _isEditing ? _updateSnippet : _addSnippet,
                          child: Text(_isEditing ? '更新' : '添加'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 代码片段列表
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '代码片段列表 (${_filteredSnippets.length}个)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _filteredSnippets.isEmpty
                        ? const Center(child: Text('没有找到代码片段'))
                        : ListView.builder(
                            itemCount: _filteredSnippets.length,
                            itemBuilder: (context, index) {
                              final snippet = _filteredSnippets[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    _getLanguageIcon(snippet.language),
                                    color: Colors.blue,
                                  ),
                                  title: Text(snippet.name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(snippet.description),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Chip(
                                            label: Text(snippet.language),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          const SizedBox(width: 4),
                                          Chip(
                                            label: Text(snippet.category),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.play_arrow, size: 20),
                                        onPressed: () => _insertSnippet(snippet),
                                        tooltip: '插入代码',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _editSnippet(index),
                                        tooltip: '编辑',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        onPressed: () => _deleteSnippet(index),
                                        tooltip: '删除',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      'sql': 'SQL',
      'json': 'JSON',
      'xml': 'XML',
    };
    return languageNames[language] ?? language;
  }

  IconData _getLanguageIcon(String language) {
    final iconMap = {
      'dart': Icons.code,
      'javascript': Icons.javascript,
      'typescript': Icons.javascript,
      'python': Icons.code,
      'java': Icons.code,
      'cpp': Icons.code,
      'csharp': Icons.code,
      'html': Icons.html,
      'css': Icons.css,
      'sql': Icons.storage,
      'json': Icons.data_object,
      'xml': Icons.data_object,
    };
    return iconMap[language] ?? Icons.code;
  }
}

class CodeSnippet {
  final String name;
  final String description;
  final String language;
  final String category;
  final String code;

  CodeSnippet({
    required this.name,
    required this.description,
    required this.language,
    required this.category,
    required this.code,
  });
}