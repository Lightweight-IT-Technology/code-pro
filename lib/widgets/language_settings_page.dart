import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/settings_model.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('语言设置'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('语言选择'),
          _buildLanguageOption(
            context,
            '中文',
            '简体中文',
            '🇨🇳',
            LanguageType.zh,
            settingsProvider.settings.language,
            settingsProvider,
          ),
          _buildLanguageOption(
            context,
            'English',
            'English',
            '🇺🇸',
            LanguageType.en,
            settingsProvider.settings.language,
            settingsProvider,
          ),
          _buildLanguageOption(
            context,
            '跟随系统',
            '根据系统语言自动选择',
            '🌐',
            LanguageType.system,
            settingsProvider.settings.language,
            settingsProvider,
          ),

          _buildSectionHeader('语言说明'),
          _buildLanguageInfoCard(context),

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

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    String subtitle,
    String flag,
    LanguageType language,
    LanguageType currentLanguage,
    SettingsProvider settingsProvider,
  ) {
    final isSelected = currentLanguage == language;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(flag, style: const TextStyle(fontSize: 20))),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () => settingsProvider.setLanguage(language),
    );
  }

  Widget _buildLanguageInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '语言设置说明',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '语言设置将影响应用程序的界面语言。选择"跟随系统"将根据您的设备系统语言自动切换界面语言。',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '更改语言后需要重启应用生效',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
