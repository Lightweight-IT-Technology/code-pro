import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/settings_provider.dart';
import 'services/file_service.dart';
import 'widgets/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化应用目录
  final appDir = await FileService.getApplicationDocumentsDirectory();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: CodeEditorApp(initialDirectory: appDir),
    ),
  );
}

class CodeEditorApp extends StatefulWidget {
  final String initialDirectory;

  const CodeEditorApp({super.key, required this.initialDirectory});

  @override
  State<CodeEditorApp> createState() => _CodeEditorAppState();
}

class _CodeEditorAppState extends State<CodeEditorApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    try {
      // 检查目录是否存在，如果不存在则使用用户主目录
      String directory = widget.initialDirectory;
      if (!await FileService.directoryExists(directory)) {
        directory = await FileService.getUserHomeDirectory();
      }

      // 设置初始目录
      appState.setCurrentDirectory(directory);

      // 加载文件列表
      final files = await FileService.listFiles(directory);
      appState.setFiles(files);
    } catch (e) {
      appState.setErrorMessage('初始化失败: $e');
      // 设置默认目录
      try {
        final homeDir = await FileService.getUserHomeDirectory();
        appState.setCurrentDirectory(homeDir);
        final files = await FileService.listFiles(homeDir);
        appState.setFiles(files);
      } catch (fallbackError) {
        // 如果连主目录都无法访问，显示错误界面
        appState.setErrorMessage('无法访问任何目录: $fallbackError');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: '代码编辑器 Pro',
          theme: settingsProvider.getCurrentTheme(),
          themeMode: settingsProvider.settings.flutterThemeMode,
          home: const MainLayout(),
        );
      },
    );
  }
}
