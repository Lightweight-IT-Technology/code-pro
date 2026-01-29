import 'package:flutter/material.dart';

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
    'dart', 'javascript', 'typescript', 'python', 'java', 
    'cpp', 'csharp', 'html', 'css', 'sql', 'json', 'xml'
  ];
  
  final List<String> _categories = [
    '通用', '函数', '类', '算法', '数据结构', '工具函数', '模板'
  ];
  
  List<CodeSnippet> _snippets = [
    CodeSnippet(
      name: 'Hello World',
      description: '基础输出示例',
      language: 'dart',
      category: '通用',
      code: 'void main() {\n  print("Hello World");\n}',
      tags: ['基础', '示例'],
    ),
    CodeSnippet(
      name: '快速排序',
      description: '快速排序算法实现',
      language: 'dart',
      category: '算法',
      code: 'void quickSort(List<int> arr, int low, int high) {\n  if (low < high) {\n    int pi = _partition(arr, low, high);\n    quickSort(arr, low, pi - 1);\n    quickSort(arr, pi + 1, high);\n  }\n}',
      tags: ['排序', '算法'],
    ),
    CodeSnippet(
      name: 'HTTP请求',
      description: '简单的HTTP GET请求',
      language: 'dart',
      category: '工具函数',
      code: 'Future<String> fetchData(String url) async {\n  final response = await http.get(Uri.parse(url));\n  if (response.statusCode == 200) {\n    return response.body;\n  } else {\n    throw Exception("请求失败");\n  }\n}',
      tags: ['网络', 'HTTP'],
    ),
  ];
  
  List<CodeSnippet> get _filteredSnippets {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _snippets;
    
    return _snippets.where((snippet) =>
      snippet.name.toLowerCase().contains(query) ||
      snippet.description.toLowerCase().contains(query) ||
      snippet.language.toLowerCase().contains(query) ||
      snippet.category.toLowerCase().contains(query) ||
      snippet.tags.any((tag) => tag.toLowerCase().contains(query))
    ).toList();
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
      tags: _extractTags(_codeController.text),
    );
    
    setState(() {
      if (_isEditing) {
        _snippets[_editingIndex] = snippet;
      } else {
        _snippets.add(snippet);
      }
      _resetForm();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? '片段已更新' : '片段已添加')),
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

  void _deleteSnippet(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${_snippets[index].name}"吗？'),
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
                const SnackBar(content: Text('片段已删除')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
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

  List<String> _extractTags(String code) {
    // 简单的关键词提取
    final keywords = ['class', 'function', 'async', 'await', 'if', 'for', 'while'];
    return keywords.where((keyword) => code.contains(keyword)).toList();
  }

  void _copyToClipboard(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('代码已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('代码片段管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _resetForm,
            tooltip: '新建片段',
          ),
        ],
      ),
      body: Row(
        children: [
          // 片段列表
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  // 搜索栏
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜索片段...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  
                  // 片段列表
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredSnippets.length,
                      itemBuilder: (context, index) {
                        final snippet = _filteredSnippets[index];
                        return _buildSnippetItem(snippet, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 编辑区域
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 表单标题
                  Row(
                    children: [
                      Text(
                        _isEditing ? '编辑片段' : '新建片段',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (_isEditing)
                        TextButton(
                          onPressed: _resetForm,
                          child: const Text('取消编辑'),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 基本信息
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: '片段名称',
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
                  
                  // 语言和分类
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedLanguage,
                          decoration: const InputDecoration(
                            labelText: '语言',
                            border: OutlineInputBorder(),
                          ),
                          items: _languages.map((lang) {
                            return DropdownMenuItem<String>(
                              value: lang,
                              child: Text(lang),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() {
                            _selectedLanguage = value!;
                          }),
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
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() {
                            _selectedCategory = value!;
                          }),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 代码编辑区域
                  const Text('代码:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          contentPadding: EdgeInsets.all(8),
                          border: InputBorder.none,
                          hintText: '输入代码片段...',
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 操作按钮
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addSnippet,
                        icon: Icon(_isEditing ? Icons.save : Icons.add),
                        label: Text(_isEditing ? '保存修改' : '添加片段'),
                      ),
                      const SizedBox(width: 16),
                      if (_isEditing)
                        ElevatedButton.icon(
                          onPressed: () => _deleteSnippet(_editingIndex),
                          icon: const Icon(Icons.delete),
                          label: const Text('删除'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnippetItem(CodeSnippet snippet, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.code),
        title: Text(snippet.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(snippet.description),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: [
                Chip(
                  label: Text(snippet.language, style: const TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(snippet.category, style: const TextStyle(fontSize: 10)),
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
              icon: const Icon(Icons.content_copy, size: 16),
              onPressed: () => _copyToClipboard(snippet.code),
              tooltip: '复制代码',
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => _editSnippet(index),
              tooltip: '编辑',
            ),
          ],
        ),
        onTap: () => _editSnippet(index),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}

class CodeSnippet {
  final String name;
  final String description;
  final String language;
  final String category;
  final String code;
  final List<String> tags;
  final DateTime createdAt;

  CodeSnippet({
    required this.name,
    required this.description,
    required this.language,
    required this.category,
    required this.code,
    required this.tags,
  }) : createdAt = DateTime.now();
}