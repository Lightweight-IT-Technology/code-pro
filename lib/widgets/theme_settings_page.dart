import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/settings_model.dart';
import 'color_picker_dialog.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('主题模式'),
          _buildThemeModeOption(
            context,
            '浅色模式',
            '使用明亮的主题',
            Icons.wb_sunny,
            ThemeModeType.light,
            settingsProvider.settings.themeMode,
            settingsProvider,
          ),
          _buildThemeModeOption(
            context,
            '深色模式',
            '使用暗色的主题',
            Icons.nightlight_round,
            ThemeModeType.dark,
            settingsProvider.settings.themeMode,
            settingsProvider,
          ),
          _buildThemeModeOption(
            context,
            '跟随系统',
            '根据系统设置自动切换',
            Icons.settings_suggest,
            ThemeModeType.system,
            settingsProvider.settings.themeMode,
            settingsProvider,
          ),

          _buildSectionHeader('主题颜色'),
          _buildColorPalette(context, settingsProvider),

          _buildSectionHeader('字体大小'),
          _buildFontSizeSlider(context, settingsProvider),

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

  Widget _buildThemeModeOption(
    BuildContext context,
    String title,
    String subtitle,
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
      subtitle: Text(subtitle),
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
      Colors.deepOrange,
      Colors.cyan,
      Colors.lightGreen,
      Colors.amber,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 预设颜色调色板
          Wrap(
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
          ),

          const SizedBox(height: 16),

          // 自定义颜色选择器
          ElevatedButton.icon(
            onPressed: () => _showColorPickerDialog(context, settingsProvider),
            icon: const Icon(Icons.color_lens),
            label: const Text('自定义颜色'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          const SizedBox(height: 8),

          // 当前颜色预览
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: settingsProvider.settings.primaryColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                '当前主题色: RGB(${settingsProvider.settings.primaryColor.red}, ${settingsProvider.settings.primaryColor.green}, ${settingsProvider.settings.primaryColor.blue})',
                style: TextStyle(
                  color:
                      settingsProvider.settings.primaryColor
                              .computeLuminance() >
                          0.5
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: settingsProvider.settings.primaryColor,
        onColorChanged: (color) {
          settingsProvider.setPrimaryColor(color);
        },
      ),
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '字体大小: ${settingsProvider.settings.fontSize.toInt()}px',
                  style: TextStyle(
                    fontSize: settingsProvider.settings.fontSize,
                  ),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('小', style: TextStyle(fontSize: 10)),
              Text('标准', style: TextStyle(fontSize: 14)),
              Text('大', style: TextStyle(fontSize: 18)),
              Text('特大', style: TextStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }
}
