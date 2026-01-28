
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'settings_dialog.dart';

class FunctionBar extends StatelessWidget {
  final double width;
  final VoidCallback onToggleFileBar;

  const FunctionBar({
    super.key,
    this.width = 60,
    required this.onToggleFileBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          // 顶部留白
          const SizedBox(height: 16),
          
          // 功能按钮区域
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 这里可以添加其他功能按钮
                // 例如：搜索、书签、调试等
                
                // 占位符，为未来功能预留空间
                const SizedBox(height: 32),
                
                // 文件栏显示/隐藏控制按钮
                _buildFileBarToggleButton(context),
                
                // 占位符，确保按钮均匀分布
                const Expanded(child: SizedBox()),
                
                // 设置按钮
                _buildSettingsButton(context),
                
                // 退出按钮
                _buildExitButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileBarToggleButton(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return IconButton(
          icon: Icon(
            appState.isFileBarVisible ? Icons.folder_open : Icons.folder,
            size: 24,
          ),
          onPressed: onToggleFileBar,
          tooltip: appState.isFileBarVisible ? '隐藏文件栏' : '显示文件栏',
          padding: const EdgeInsets.all(12),
        );
      },
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings, size: 24),
      onPressed: () => _openSettings(context),
      tooltip: '设置',
      padding: const EdgeInsets.all(12),
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.exit_to_app, size: 24),
      onPressed: () => _exitApp(context),
      tooltip: '退出',
      padding: const EdgeInsets.all(12),
    );
  }

  void _openSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  void _exitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出应用'),
        content: const Text('确定要退出代码编辑器吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 退出应用程序
              _performExit();
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _performExit() {
    // 在Windows平台上使用SystemNavigator.pop()退出应用
    // 对于其他平台，可能需要不同的退出方法
    SystemNavigator.pop();
  }
}