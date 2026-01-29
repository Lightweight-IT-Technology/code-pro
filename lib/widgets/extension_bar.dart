import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class ExtensionBar extends StatelessWidget {
  final double width;
  final double minWidth;
  final double maxWidth;

  const ExtensionBar({
    super.key,
    this.width = 300,
    this.minWidth = 250,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
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
                  '拓展功能',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    Provider.of<AppStateProvider>(context, listen: false)
                        .setExtensionBarVisible(false);
                  },
                  tooltip: '关闭拓展栏',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
                ),
              ],
            ),
          ),

          // 拓展功能内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 代码工具
                  _buildSection(
                    context,
                    '代码工具',
                    Icons.code,
                    [
                      _buildExtensionItem(
                        context,
                        '代码格式化',
                        Icons.format_align_left,
                        () {
                          // TODO: 实现代码格式化功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('代码格式化功能开发中')),
                          );
                        },
                      ),
                      _buildExtensionItem(
                        context,
                        '代码片段',
                        Icons.snippet_folder,
                        () {
                          // TODO: 实现代码片段功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('代码片段功能开发中')),
                          );
                        },
                      ),
                      _buildExtensionItem(
                        context,
                        '代码模板',
                        Icons.dashboard,
                        () {
                          // TODO: 实现代码模板功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('代码模板功能开发中')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 文件操作
                  _buildSection(
                    context,
                    '文件操作',
                    Icons.folder,
                    [
                      _buildExtensionItem(
                        context,
                        '批量重命名',
                        Icons.drive_file_rename_outline,
                        () {
                          // TODO: 实现批量重命名功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('批量重命名功能开发中')),
                          );
                        },
                      ),
                      _buildExtensionItem(
                        context,
                        '文件搜索',
                        Icons.search,
                        () {
                          // TODO: 实现文件搜索功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('文件搜索功能开发中')),
                          );
                        },
                      ),
                      _buildExtensionItem(
                        context,
                        '文件比较',
                        Icons.compare,
                        () {
                          // TODO: 实现文件比较功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('文件比较功能开发中')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 开发工具
                  _buildSection(
                    context,
                    '开发工具',
                    Icons.developer_mode,
                    [
                      _buildExtensionItem(
                        context,
                        'API测试',
                        Icons.api,
                        () {
                          // TODO: 实现API测试功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('API测试功能开发中')),
                          );
                        },
                      ),
                      _buildExtensionItem(
                        context,
                        '数据库管理',
                        Icons.storage,
                        () {
                          // TODO: 实现数据库管理功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('数据库管理功能开发中')),
                          );
                        },
                      ),
                      _buildExtensionItem(
                        context,
                        '性能分析',
                        Icons.timeline,
                        () {
                          // TODO: 实现性能分析功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('性能分析功能开发中')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 系统工具
                  _buildSection(
                    context,
                    '系统工具',
                    Icons.settings,
                    [
                      _buildExtensionItem(
                        context,
                        '终端模拟器',
                        Icons.terminal,
                        () {
                          // TODO: 实现终端模拟器功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('终端模拟器功能开发中')),
                          );
                        },
                      ),
                      _buildExtensionItem(
                        context,
                        '系统监控',
                        Icons.monitor_heart,
                        () {
                          // TODO: 实现系统监控功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('系统监控功能开发中')),
                          );
                        },
                      ),
                      _buildExtensionItem(
                        context,
                        '网络工具',
                        Icons.network_check,
                        () {
                          // TODO: 实现网络工具功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('网络工具功能开发中')),
                          );
                        },
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

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildExtensionItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minLeadingWidth: 24,
        dense: true,
      ),
    );
  }
}