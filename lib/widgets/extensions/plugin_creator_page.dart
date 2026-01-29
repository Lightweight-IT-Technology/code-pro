import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../services/plugin_system.dart';

class PluginCreatorPage extends StatefulWidget {
  const PluginCreatorPage({super.key});

  @override
  State<PluginCreatorPage> createState() => _PluginCreatorPageState();
}

class _PluginCreatorPageState extends State<PluginCreatorPage> {
  final _formKey = GlobalKey<FormState>();

  // 插件元数据字段
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _versionController = TextEditingController(
    text: '1.0.0',
  );
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _entryPointController = TextEditingController(
    text: 'lib/main.dart',
  );

  // 配置选项
  String _selectedTemplate = PluginTemplateTypes.tool;
  String _outputDirectory = '';
  bool _createPackage = true;
  bool _isCreating = false;

  // 创建结果
  PluginCreationResult? _creationResult;

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _entryPointController.dispose();
    super.dispose();
  }

  /// 选择输出目录
  Future<void> _selectOutputDirectory() async {
    try {
      final String? selectedDirectory = await FilePicker.platform
          .getDirectoryPath(dialogTitle: '选择插件输出目录');

      if (selectedDirectory != null) {
        setState(() {
          _outputDirectory = selectedDirectory;
        });
      }
    } catch (e) {
      _showError('选择目录时发生错误: $e');
    }
  }

  /// 创建插件
  Future<void> _createPlugin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_outputDirectory.isEmpty) {
      _showError('请选择输出目录');
      return;
    }

    setState(() {
      _isCreating = true;
      _creationResult = null;
    });

    try {
      // 创建插件元数据
      final metadata = PluginMetadata(
        name: _nameController.text.trim(),
        version: _versionController.text.trim(),
        description: _descriptionController.text.trim(),
        author: _authorController.text.trim(),
        type: _selectedTemplate,
        entryPoint: _entryPointController.text.trim(),
      );

      // 调用插件创建器
      final result = await PluginCreator.createPlugin(
        metadata: metadata,
        templateType: _selectedTemplate,
        outputDirectory: _outputDirectory,
      );

      setState(() {
        _creationResult = result;
        _isCreating = false;
      });

      if (result.success) {
        _showSuccess('插件创建成功！');
      } else {
        _showError('插件创建失败: ${result.errors.join("\\n")}');
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
      });
      _showError('创建插件时发生错误: $e');
    }
  }

  /// 显示成功消息
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示错误消息
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// 重置表单
  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _versionController.text = '1.0.0';
    _descriptionController.clear();
    _authorController.clear();
    _entryPointController.text = 'lib/main.dart';
    setState(() {
      _selectedTemplate = PluginTemplateTypes.tool;
      _outputDirectory = '';
      _creationResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件创建器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: '重置表单',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 插件基本信息
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '插件基本信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 插件名称
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '插件名称*',
                          hintText: '请输入插件名称（只能包含字母、数字和下划线）',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '插件名称不能为空';
                          }
                          if (!RegExp(
                            r'^[a-zA-Z][a-zA-Z0-9_]*$',
                          ).hasMatch(value.trim())) {
                            return '插件名称只能包含字母、数字和下划线，且必须以字母开头';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 版本号
                      TextFormField(
                        controller: _versionController,
                        decoration: const InputDecoration(
                          labelText: '版本号*',
                          hintText: '例如: 1.0.0',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '版本号不能为空';
                          }
                          if (!RegExp(
                            r'^\d+\.\d+\.\d+$',
                          ).hasMatch(value.trim())) {
                            return '版本号格式不正确，应为x.y.z格式';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 描述
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '描述*',
                          hintText: '请输入插件的功能描述',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '描述不能为空';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 作者
                      TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          labelText: '作者*',
                          hintText: '请输入作者名称',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '作者不能为空';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 模板选择
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '模板选择',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 模板类型选择
                      DropdownButtonFormField<String>(
                        value: _selectedTemplate,
                        decoration: const InputDecoration(
                          labelText: '选择模板类型',
                          border: OutlineInputBorder(),
                        ),
                        items: PluginTemplateTypes.allTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Row(
                              children: [
                                Icon(
                                  PluginTemplateTypes.getIcon(type),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      PluginTemplateTypes.getDisplayName(type),
                                    ),
                                    Text(
                                      PluginTemplateTypes.getDescription(type),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTemplate = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // 入口文件
                      TextFormField(
                        controller: _entryPointController,
                        decoration: const InputDecoration(
                          labelText: '入口文件',
                          hintText: '插件的主入口文件路径',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '入口文件不能为空';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 输出设置
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '输出设置',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 输出目录选择
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '输出目录*',
                                hintText: '请选择插件输出目录',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.folder_open),
                                  onPressed: _selectOutputDirectory,
                                ),
                              ),
                              controller: TextEditingController(
                                text: _outputDirectory,
                              ),
                              validator: (value) {
                                if (_outputDirectory.isEmpty) {
                                  return '请选择输出目录';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 创建选项
                      CheckboxListTile(
                        title: const Text('创建插件包 (.pkg-app)'),
                        subtitle: const Text('生成可直接安装的插件包文件'),
                        value: _createPackage,
                        onChanged: (value) {
                          setState(() {
                            _createPackage = value ?? true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 创建按钮
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: _isCreating ? null : _createPlugin,
                    icon: _isCreating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.create),
                    label: Text(_isCreating ? '创建中...' : '创建插件'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              // 创建结果
              if (_creationResult != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: _creationResult!.success
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _creationResult!.success
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _creationResult!.success
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _creationResult!.success ? '创建成功' : '创建失败',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _creationResult!.success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_creationResult!.success) ...[
                          if (_creationResult!.pluginPath != null)
                            _buildResultItem(
                              '插件路径:',
                              _creationResult!.pluginPath!,
                            ),
                          if (_creationResult!.packagePath != null)
                            _buildResultItem(
                              '包路径:',
                              _creationResult!.packagePath!,
                            ),
                          if (_creationResult!.createdFiles.isNotEmpty)
                            _buildResultItem(
                              '创建文件:',
                              '${_creationResult!.createdFiles.length}个文件',
                            ),
                        ] else ...[
                          if (_creationResult!.errors.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _creationResult!.errors.map((error) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    '• $error',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建结果项
  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
