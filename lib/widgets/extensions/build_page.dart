import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../services/build_system.dart';

class BuildPage extends StatefulWidget {
  const BuildPage({super.key});

  @override
  State<BuildPage> createState() => _BuildPageState();
}

class _BuildPageState extends State<BuildPage> {
  final _formKey = GlobalKey<FormState>();
  
  // 构建配置字段
  final TextEditingController _projectPathController = TextEditingController();
  final TextEditingController _outputPathController = TextEditingController();
  final TextEditingController _configNameController = TextEditingController(text: 'default');
  
  // 构建选项
  String _selectedPlatform = 'windows';
  String _selectedMode = 'release';
  String _projectPath = '';
  String _outputPath = '';
  bool _isBuilding = false;
  
  // 构建结果
  BuildResult? _buildResult;
  List<String> _buildLogs = [];
  
  // 支持的平台和模式
  final List<String> _platforms = ['windows', 'linux', 'macos', 'web', 'android', 'ios'];
  final List<String> _modes = ['debug', 'profile', 'release'];
  
  @override
  void dispose() {
    _projectPathController.dispose();
    _outputPathController.dispose();
    _configNameController.dispose();
    super.dispose();
  }
  
  /// 选择项目目录
  Future<void> _selectProjectDirectory() async {
    try {
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择插件项目目录',
      );
      
      if (selectedDirectory != null) {
        setState(() {
          _projectPath = selectedDirectory;
          _projectPathController.text = selectedDirectory;
          _outputPath = path.join(selectedDirectory, 'build');
          _outputPathController.text = _outputPath;
        });
        
        // 验证项目结构
        await _validateProjectStructure();
      }
    } catch (e) {
      _showError('选择目录时发生错误: $e');
    }
  }
  
  /// 选择输出目录
  Future<void> _selectOutputDirectory() async {
    try {
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择构建输出目录',
      );
      
      if (selectedDirectory != null) {
        setState(() {
          _outputPath = selectedDirectory;
          _outputPathController.text = selectedDirectory;
        });
      }
    } catch (e) {
      _showError('选择目录时发生错误: $e');
    }
  }
  
  /// 验证项目结构
  Future<void> _validateProjectStructure() async {
    if (_projectPath.isEmpty) return;
    
    final errors = await BuildEngine.validateProjectStructure(_projectPath);
    if (errors.isNotEmpty) {
      _showWarning('项目结构验证发现以下问题:\n${errors.join("\n")}');
    } else {
      _showSuccess('项目结构验证通过');
    }
  }
  
  /// 执行构建
  Future<void> _executeBuild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_projectPath.isEmpty) {
      _showError('请选择项目目录');
      return;
    }
    
    setState(() {
      _isBuilding = true;
      _buildResult = null;
      _buildLogs.clear();
    });
    
    try {
      // 创建构建配置
      final config = BuildConfig(
        name: _configNameController.text.trim(),
        version: '1.0.0',
        description: '插件构建配置',
        targetPlatform: _selectedPlatform,
        buildMode: _selectedMode,
      );
      
      // 添加构建配置到管理器
      BuildManager().addBuildConfig(config.name, config);
      
      // 执行构建
      _addLog('开始构建插件项目...');
      _addLog('项目路径: $_projectPath');
      _addLog('目标平台: $_selectedPlatform');
      _addLog('构建模式: $_selectedMode');
      
      final result = await BuildManager().executeBuild(
        projectPath: _projectPath,
        configName: config.name,
        outputPath: _outputPath,
      );
      
      setState(() {
        _buildResult = result;
        _isBuilding = false;
      });
      
      // 记录构建结果
      if (result.success) {
        _addLog('构建成功!');
        _addLog('构建耗时: ${result.buildDuration.inSeconds}秒');
        _addLog('生成文件: ${result.builtFiles.length}个');
        if (result.warnings.isNotEmpty) {
          _addLog('警告信息:');
          for (final warning in result.warnings) {
            _addLog('  - $warning');
          }
        }
        _showSuccess('构建完成!');
      } else {
        _addLog('构建失败!');
        _addLog('错误信息:');
        for (final error in result.errors) {
          _addLog('  - $error');
        }
        _showError('构建失败: ${result.errors.join("\n")}');
      }
      
    } catch (e) {
      setState(() {
        _isBuilding = false;
      });
      _addLog('构建过程中发生错误: $e');
      _showError('构建过程中发生错误: $e');
    }
  }
  
  /// 添加日志
  void _addLog(String message) {
    setState(() {
      _buildLogs.add('${DateTime.now().toString().substring(11, 19)} $message');
    });
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
  
  /// 显示警告消息
  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
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
    _projectPathController.clear();
    _outputPathController.clear();
    _configNameController.text = 'default';
    setState(() {
      _projectPath = '';
      _outputPath = '';
      _selectedPlatform = 'windows';
      _selectedMode = 'release';
      _buildResult = null;
      _buildLogs.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件构建器'),
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
              // 项目配置
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '项目配置',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // 项目路径
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _projectPathController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '项目目录*',
                                hintText: '请选择插件项目目录',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.folder_open),
                                  onPressed: _selectProjectDirectory,
                                ),
                              ),
                              validator: (value) {
                                if (_projectPath.isEmpty) {
                                  return '请选择项目目录';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // 输出路径
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _outputPathController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '输出目录',
                                hintText: '请选择构建输出目录',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.folder_open),
                                  onPressed: _selectOutputDirectory,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 构建配置
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '构建配置',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          // 配置名称
                          Expanded(
                            child: TextFormField(
                              controller: _configNameController,
                              decoration: const InputDecoration(
                                labelText: '配置名称',
                                hintText: '构建配置名称',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '配置名称不能为空';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // 目标平台
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPlatform,
                              decoration: const InputDecoration(
                                labelText: '目标平台',
                                border: OutlineInputBorder(),
                              ),
                              items: _platforms.map((platform) {
                                return DropdownMenuItem<String>(
                                  value: platform,
                                  child: Text(_getPlatformDisplayName(platform)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedPlatform = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // 构建模式
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedMode,
                              decoration: const InputDecoration(
                                labelText: '构建模式',
                                border: OutlineInputBorder(),
                              ),
                              items: _modes.map((mode) {
                                return DropdownMenuItem<String>(
                                  value: mode,
                                  child: Text(_getModeDisplayName(mode)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedMode = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 构建按钮
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: _isBuilding ? null : _executeBuild,
                    icon: _isBuilding 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.build),
                    label: Text(_isBuilding ? '构建中...' : '开始构建'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              
              // 构建日志
              if (_buildLogs.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '构建日志',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.shade50,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildLogs.map((log) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    log,
                                    style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // 构建结果
              if (_buildResult != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: _buildResult!.success ? Colors.green.shade50 : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _buildResult!.success ? Icons.check_circle : Icons.error,
                              color: _buildResult!.success ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _buildResult!.success ? '构建成功' : '构建失败',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _buildResult!.success ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        if (_buildResult!.success) ...[
                          if (_buildResult!.buildPath != null)
                            _buildResultItem('项目路径:', _buildResult!.buildPath!),
                          if (_buildResult!.outputPath != null)
                            _buildResultItem('输出路径:', _buildResult!.outputPath!),
                          if (_buildResult!.builtFiles.isNotEmpty)
                            _buildResultItem('生成文件:', '${_buildResult!.builtFiles.length}个'),
                          _buildResultItem('构建耗时:', '${_buildResult!.buildDuration.inSeconds}秒'),
                          if (_buildResult!.warnings.isNotEmpty)
                            _buildResultItem('警告数量:', '${_buildResult!.warnings.length}个'),
                        ] else ...[
                          if (_buildResult!.errors.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildResult!.errors.map((error) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: