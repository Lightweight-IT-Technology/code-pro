import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'file_bar.dart';
import 'code_editor.dart';
import 'function_bar.dart';
import 'enhanced_extension_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final double _minFileBarWidth = 250;
  final double _maxFileBarWidth = 400;
  double _fileBarWidth = 300;
  bool _isResizing = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;
        final appState = Provider.of<AppStateProvider>(context);

        // 根据屏幕宽度决定是否显示文件栏
        // 在大屏幕上，文件栏默认显示但可以隐藏；在小屏幕上，文件栏默认隐藏但可以显示
        final shouldShowFileBar = appState.isFileBarVisible;

        return Scaffold(
          body: Row(
            children: [
              // 功能栏
              FunctionBar(
                width: 60,
                onToggleFileBar: () {
                  appState.setFileBarVisible(!appState.isFileBarVisible);
                },
                onToggleExtensionBar: () {
                  appState.setExtensionBarVisible(
                    !appState.isExtensionBarVisible,
                  );
                },
              ),

              // 文件栏（带动画效果）
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: shouldShowFileBar
                    ? _buildFileBar(appState, isLargeScreen)
                    : const SizedBox.shrink(),
              ),

              // 拓展栏（带动画效果）
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: appState.isExtensionBarVisible
                    ? _buildExtensionBar(appState, isLargeScreen)
                    : const SizedBox.shrink(),
              ),

              // 编辑器区域
              Expanded(
                child: Column(
                  children: [
                    // 顶部工具栏（仅在小屏幕上显示文件栏切换按钮）
                    if (!isLargeScreen)
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                appState.isFileBarVisible
                                    ? Icons.chevron_left
                                    : Icons.chevron_right,
                              ),
                              onPressed: () {
                                appState.setFileBarVisible(
                                  !appState.isFileBarVisible,
                                );
                              },
                              tooltip: appState.isFileBarVisible
                                  ? '隐藏文件栏'
                                  : '显示文件栏',
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '代码编辑器',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 编辑器内容
                    Expanded(child: CodeEditor()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileBar(AppStateProvider appState, bool isLargeScreen) {
    return MouseRegion(
      cursor: isLargeScreen
          ? SystemMouseCursors.resizeLeftRight
          : MouseCursor.defer,
      child: GestureDetector(
        onHorizontalDragStart: isLargeScreen
            ? (_) => setState(() => _isResizing = true)
            : null,
        onHorizontalDragUpdate: isLargeScreen
            ? (details) {
                setState(() {
                  _fileBarWidth = (_fileBarWidth + details.delta.dx).clamp(
                    _minFileBarWidth,
                    _maxFileBarWidth,
                  );
                });
              }
            : null,
        onHorizontalDragEnd: isLargeScreen
            ? (_) => setState(() => _isResizing = false)
            : null,
        child: Stack(
          children: [
            // 文件栏内容
            FileBar(width: _fileBarWidth),

            // 调整大小的手柄（仅在大屏幕上显示）
            if (isLargeScreen)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  color: _isResizing
                      ? Theme.of(context).colorScheme.primary.withAlpha(128)
                      : Colors.transparent,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: Container(),
                  ),
                ),
              ),

            // 关闭按钮（仅在小屏幕上显示）
            if (!isLargeScreen)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => appState.setFileBarVisible(false),
                  tooltip: '关闭文件栏',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionBar(AppStateProvider appState, bool isLargeScreen) {
    return AnimatedContainer(
      key: const ValueKey('extension_bar'),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _fileBarWidth,
      child: Stack(
        children: [
          // 增强版拓展栏内容
          EnhancedExtensionBar(
            width: _fileBarWidth,
            minWidth: _minFileBarWidth,
            maxWidth: _maxFileBarWidth,
          ),

          // 调整大小手柄（仅在大屏幕上显示）
          if (isLargeScreen)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _fileBarWidth = (_fileBarWidth - details.delta.dx).clamp(
                        _minFileBarWidth,
                        _maxFileBarWidth,
                      );
                    });
                  },
                  child: Container(width: 8, color: Colors.transparent),
                ),
              ),
            ),

          // 关闭按钮（仅在小屏幕上显示）
          if (!isLargeScreen)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => appState.setExtensionBarVisible(false),
                tooltip: '关闭拓展栏',
              ),
            ),
        ],
      ),
    );
  }
}
