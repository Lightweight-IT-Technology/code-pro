import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'theme_settings_page.dart';
import 'language_settings_page.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('外观设置'),
          _buildSettingItem(
            context,
            '主题模式',
            settingsProvider.getThemeModeDisplayName(),
            Icons.brightness_6,
            () => _navigateToThemeSettings(context),
          ),
          _buildSettingItem(
            context,
            '语言设置',
            settingsProvider.getLanguageDisplayName(),
            Icons.language,
            () => _navigateToLanguageSettings(context),
          ),

          _buildSectionHeader('编辑器设置'),
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

          _buildSectionHeader('其他'),
          _buildSettingItem(
            context,
            '关于',
            '应用信息和版本',
            Icons.info,
            () => _navigateToAboutPage(context),
          ),

          const SizedBox(height: 20),
          _buildResetButton(context, settingsProvider),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
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
        activeTrackColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildResetButton(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () =>
            _showResetConfirmationDialog(context, settingsProvider),
        icon: const Icon(Icons.restore),
        label: const Text('恢复默认设置'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _navigateToThemeSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ThemeSettingsPage()),
    );
  }

  void _navigateToLanguageSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LanguageSettingsPage()),
    );
  }

  void _navigateToAboutPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutPage()),
    );
  }

  void _showResetConfirmationDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
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
