import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/settings_model.dart';
import '../utils/version_info.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    const _AppearanceSettingsPage(),
    const _EditorSettingsPage(),
    const _AboutPage(),
  ];

  final List<String> _pageTitles = ['外观设置', '编辑器设置', '关于'];

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLargeScreen ? 800 : 500,
          maxHeight: 600,
        ),
        child: Column(
          children: [
            // 标题栏
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    _pageTitles[_currentPageIndex],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  // 侧边导航栏（仅在大屏幕上显示）
                  if (isLargeScreen) _buildSidebar(),

                  // 内容区域
                  Expanded(child: _pages[_currentPageIndex]),
                ],
              ),
            ),

            // 底部操作栏（仅在小屏幕上显示）
            if (!isLargeScreen) _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView(
        children: [
          _buildNavItem(0, Icons.palette, '外观设置'),
          _buildNavItem(1, Icons.edit, '编辑器设置'),
          _buildNavItem(2, Icons.info, '关于'),
          const SizedBox(height: 20),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _currentPageIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => setState(() => _currentPageIndex = index),
      tileColor: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(0, Icons.palette, '外观'),
          _buildBottomNavItem(1, Icons.edit, '编辑器'),
          _buildBottomNavItem(2, Icons.info, '关于'),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _currentPageIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentPageIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => _showResetConfirmationDialog(context),
        icon: const Icon(Icons.restore, size: 16),
        label: const Text('恢复默认'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复默认设置'),
        content: const Text('确定要恢复所有设置为默认值吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              settingsProvider.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('设置已恢复为默认值')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSettingsPage extends StatelessWidget {
  const _AppearanceSettingsPage();

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          _buildSectionHeader('主题模式'),
          _buildThemeModeOption(
            context,
            '浅色模式',
            Icons.wb_sunny,
            ThemeModeType.light,
            settingsProvider.settings.themeMode,
            settingsProvider,
          ),
          _buildThemeModeOption(
            context,
            '深色模式',
            Icons.nightlight_round,
            ThemeModeType.dark,
            settingsProvider.settings.themeMode,
            settingsProvider,
          ),
          _buildThemeModeOption(
            context,
            '跟随系统',
            Icons.settings_suggest,
            ThemeModeType.system,
            settingsProvider.settings.themeMode,
            settingsProvider,
          ),

          _buildSectionHeader('主题颜色'),
          _buildColorPalette(context, settingsProvider),

          _buildSectionHeader('字体大小'),
          _buildFontSizeSlider(context, settingsProvider),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeModeType mode,
    ThemeModeType currentMode,
    SettingsProvider settingsProvider,
  ) {
    final isSelected = currentMode == mode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () => settingsProvider.setThemeMode(mode),
    );
  }

  Widget _buildColorPalette(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected =
            settingsProvider.settings.primaryColor.value == color.value;

        return GestureDetector(
          onTap: () => settingsProvider.setPrimaryColor(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.text_fields, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '字体大小: ${settingsProvider.settings.fontSize.toInt()}px',
                style: TextStyle(fontSize: settingsProvider.settings.fontSize),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Slider(
          value: settingsProvider.settings.fontSize,
          min: 10,
          max: 24,
          divisions: 14,
          label: '${settingsProvider.settings.fontSize.toInt()}px',
          onChanged: (value) => settingsProvider.setFontSize(value),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _EditorSettingsPage extends StatelessWidget {
  const _EditorSettingsPage();

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          _buildSwitchItem(
            context,
            '显示行号',
            '在编辑器中显示行号',
            Icons.format_list_numbered,
            settingsProvider.settings.lineNumbers,
            (value) => settingsProvider.setLineNumbers(value),
          ),
          _buildSwitchItem(
            context,
            '自动换行',
            '在编辑器中启用自动换行',
            Icons.wrap_text,
            settingsProvider.settings.wordWrap,
            (value) => settingsProvider.setWordWrap(value),
          ),
          _buildSwitchItem(
            context,
            '自动保存',
            '自动保存文件更改',
            Icons.save,
            settingsProvider.settings.autoSave,
            (value) => settingsProvider.setAutoSave(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.code, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  '代码编辑器 Pro',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  VersionInfo.displayVersion,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  '功能强大的跨平台代码编辑器，支持多种编程语言和丰富的自定义选项。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '版本信息',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '完整版本: ${VersionInfo.fullVersion}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '构建日期: ${VersionInfo.buildDate}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildFeatureList(context),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final features = [
      '支持多种编程语言语法高亮',
      '文件管理和编辑功能',
      '深色/浅色主题切换',
      '自定义字体大小和颜色',
      '自动保存和自动换行',
      '跨平台兼容（Windows、macOS、Linux）',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '主要功能',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(feature, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
