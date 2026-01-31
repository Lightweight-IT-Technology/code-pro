import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_state_provider.dart';
import '../services/extension_manager.dart';

class EnhancedExtensionBar extends StatefulWidget {
  final double width;
  final double minWidth;
  final double maxWidth;

  const EnhancedExtensionBar({
    super.key,
    this.width = 300,
    this.minWidth = 250,
    this.maxWidth = 400,
  });

  @override
  State<EnhancedExtensionBar> createState() => _EnhancedExtensionBarState();
}

class _EnhancedExtensionBarState extends State<EnhancedExtensionBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];
  List<String> _filteredExtensions = [];
  bool _showSearchResults = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // 获取已安装的拓展列表
  List<Extension> get _installedExtensions =>
      ExtensionManager().getExtensions();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _filteredExtensions = _installedExtensions.map((e) => e.name).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchSuggestions.clear();
      });
      return;
    }

    // 实时搜索建议
    final suggestions = ExtensionManager()
        .searchExtensions(query)
        .map((ext) => ext.name)
        .toList();

    setState(() {
      _searchSuggestions = suggestions;
      _showSearchResults = true;
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // 添加到搜索历史
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.sublist(0, 10);
        }
      });
    }

    // 过滤拓展
    final results = ExtensionManager().searchExtensions(query);

    setState(() {
      _filteredExtensions = results.map((e) => e.name).toList();
      _showSearchResults = true;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showSearchResults = false;
      _searchSuggestions.clear();
      _filteredExtensions = _installedExtensions.map((e) => e.name).toList();
    });
  }

  Future<void> _uploadExtension() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pkg-code'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.extension == 'pkg-code') {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        // 模拟上传过程
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 200));
          setState(() {
            _uploadProgress = i / 100.0;
          });
        }

        // 模拟文件验证和安装
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拓展包 ${result.files.single.name} 安装成功！'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请选择有效的 .pkg-code 文件'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          // 搜索框
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: '搜索拓展...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),

          // 搜索建议
          if (_searchSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _searchSuggestions.map((suggestion) {
                  return ListTile(
                    leading: const Icon(Icons.search, size: 16),
                    title: Text(suggestion),
                    onTap: () {
                      _searchController.text = suggestion;
                      _performSearch();
                    },
                    dense: true,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _uploadExtension,
              icon: const Icon(Icons.upload, size: 16),
              label: const Text('上传拓展'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionList() {
    final extensionsToShow = _showSearchResults
        ? _installedExtensions
              .where((ext) => _filteredExtensions.contains(ext.name))
              .toList()
        : _installedExtensions;

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索结果标题
            if (_showSearchResults && _searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Text(
                      '搜索结果',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearSearch,
                      child: const Text('清除搜索'),
                    ),
                  ],
                ),
              ),

            // 拓展列表
            ...extensionsToShow.map((extension) {
              return _buildExtensionCard(extension);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionCard(Extension extension) {
    final query = _searchController.text.toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Icon(extension.icon, size: 24),
        title: _buildHighlightedText(extension.name, query),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHighlightedText(extension.description, query),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    extension.type,
                    style: const TextStyle(fontSize: 10),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                Text(
                  'v${extension.version}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          _executeExtension(extension);
        },
      ),
    );
  }

  void _executeExtension(Extension extension) async {
    try {
      await ExtensionManager().executeExtension(extension.name, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('执行拓展失败: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) return Text(text);

    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();

    if (!textLower.contains(queryLower)) return Text(text);

    final startIndex = textLower.indexOf(queryLower);
    final endIndex = startIndex + queryLower.length;

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(
              backgroundColor: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    if (!_isUploading) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '上传中... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.extension, size: 20),
                const SizedBox(width: 8),
                Text(
                  '拓展管理',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    Provider.of<AppStateProvider>(
                      context,
                      listen: false,
                    ).setExtensionBarVisible(false);
                  },
                  tooltip: '关闭拓展栏',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    maxWidth: 32,
                    maxHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // 搜索栏
          _buildSearchBar(),

          // 操作按钮
          _buildActionButtons(),

          // 上传进度
          _buildUploadProgress(),

          // 拓展列表
          _buildExtensionList(),
        ],
      ),
    );
  }
}

// 拓展创建向导
class ExtensionCreationWizard extends StatefulWidget {
  final Function(Map<String, dynamic>) onExtensionCreated;

  const ExtensionCreationWizard({super.key, required this.onExtensionCreated});

  @override
  State<ExtensionCreationWizard> createState() =>
      _ExtensionCreationWizardState();
}

class _ExtensionCreationWizardState extends State<ExtensionCreationWizard> {
  int _currentStep = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  String _selectedType = '代码工具';
  final List<String> _extensionTypes = ['代码工具', '文件操作', '开发工具', '系统工具', '自定义'];

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('基本信息'),
        content: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '拓展名称',
                hintText: '输入拓展名称',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _versionController,
              decoration: const InputDecoration(
                labelText: '版本号',
                hintText: '例如: 1.0.0',
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('详细信息'),
        content: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述',
                hintText: '输入拓展功能描述',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: '作者',
                hintText: '输入作者名称',
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('选择模板'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择拓展类型:'),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              items: _extensionTypes.map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('将生成以下文件结构:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('extension_name/'),
                  Text('├── manifest.json'),
                  Text('├── main.dart'),
                  Text('├── assets/'),
                  Text('└── README.md'),
                ],
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  void _createExtension() {
    final extensionData = {
      'name': _nameController.text,
      'version': _versionController.text,
      'description': _descriptionController.text,
      'author': _authorController.text,
      'type': _selectedType,
      'createdAt': DateTime.now().toIso8601String(),
    };

    widget.onExtensionCreated(extensionData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建新拓展'),
      content: SizedBox(
        width: 400,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < _buildSteps().length - 1) {
              setState(() {
                _currentStep++;
              });
            } else {
              _createExtension();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          steps: _buildSteps(),
        ),
      ),
    );
  }
}
