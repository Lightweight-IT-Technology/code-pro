import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/file_model.dart';
import '../models/simple_file_tree_model.dart';
import '../models/editor_state.dart';
import '../services/file_service.dart';
import 'simple_file_tree_view.dart';

class FileBar extends StatefulWidget {
  final double width;

  const FileBar({super.key, required this.width});

  @override
  State<FileBar> createState() => _FileBarState();
}

class _FileBarState extends State<FileBar> {
  final TextEditingController _newFileNameController = TextEditingController();
  final TextEditingController _newFolderNameController =
      TextEditingController();
  List<SimpleFileTreeItem> _fileTree = [];

  @override
  void dispose() {
    _newFileNameController.dispose();
    _newFolderNameController.dispose();
    super.dispose();
  }

  void _showCreateFileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新建文件'),
          content: TextField(
            controller: _newFileNameController,
            decoration: const InputDecoration(hintText: '输入文件名（包含扩展名）'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final fileName = _newFileNameController.text.trim();
                if (fileName.isNotEmpty) {
                  final appState = Provider.of<AppStateProvider>(
                    context,
                    listen: false,
                  );
                  final currentContext = context;

                  // 在异步操作开始前关闭对话框
                  Navigator.of(currentContext).pop();

                  // 异步操作
                  _createFileAsync(appState, fileName);
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新建文件夹'),
          content: TextField(
            controller: _newFolderNameController,
            decoration: const InputDecoration(hintText: '输入文件夹名称'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final folderName = _newFolderNameController.text.trim();
                if (folderName.isNotEmpty) {
                  final appState = Provider.of<AppStateProvider>(
                    context,
                    listen: false,
                  );
                  final currentContext = context;

                  // 在异步操作开始前关闭对话框
                  Navigator.of(currentContext).pop();

                  // 异步操作
                  _createFolderAsync(appState, folderName);
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  void _refreshFiles(AppStateProvider appState) async {
    try {
      final files = await FileService.listFiles(appState.currentDirectory);
      appState.setFiles(files);

      // 构建简单的文件树结构
      final fileTree = await SimpleFileTreeManager.buildSimpleFileTree(
        appState.currentDirectory,
      );
      setState(() {
        _fileTree = fileTree;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('刷新文件列表失败: $e')));
      }
    }
  }

  void _createFileAsync(AppStateProvider appState, String fileName) async {
    try {
      await FileService.createFile(appState.currentDirectory, fileName);
      _refreshFiles(appState);
      _newFileNameController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建文件失败: $e')));
      }
    }
  }

  void _createFolderAsync(AppStateProvider appState, String folderName) async {
    try {
      await FileService.createDirectory(appState.currentDirectory, folderName);
      _refreshFiles(appState);
      _newFolderNameController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建文件夹失败: $e')));
      }
    }
  }

  void _openFolderDialog(AppStateProvider appState) {
    final currentContext = context;
    _selectFolderAsync(appState, currentContext);
  }

  void _selectFolderAsync(
    AppStateProvider appState,
    BuildContext dialogContext,
  ) async {
    try {
      final selectedDirectory = await FileService.selectDirectory();
      if (selectedDirectory != null && mounted) {
        appState.setCurrentDirectory(selectedDirectory);
        _refreshFiles(appState);

        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text(
              '已打开文件夹: ${selectedDirectory.split(RegExp(r'[\\/]')).last}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          dialogContext,
        ).showSnackBar(SnackBar(content: Text('打开文件夹失败: $e')));
      }
    }
  }

  void _deleteFile(SimpleFileTreeItem item) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    try {
      if (item.isDirectory) {
        await FileService.deleteDirectory(item.path);
      } else {
        await FileService.deleteFile(item.path);
      }
      _refreshFiles(appState);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  void _openFile(SimpleFileTreeItem item) async {
    if (item.isDirectory) {
      // 对于文件夹，只展开/收起，不切换目录
      // 新的文件树实现会在SimpleFileTreeView中处理展开/收起
      // 这里不需要额外处理
    } else {
      // 打开文件到编辑器
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final editorState = EditorState(
        filePath: item.path,
        fileName: item.name,
        lastSaved: DateTime.now(),
      );
      appState.setCurrentEditorState(editorState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          width: widget.width,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // 顶部标题栏
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      color: Theme.of(context).colorScheme.onPrimary,
                      tooltip: '打开文件夹',
                      onPressed: () => _openFolderDialog(appState),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appState.currentDirectory.split(RegExp(r'[\\/]')).last,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Theme.of(context).colorScheme.onPrimary,
                      tooltip: '刷新',
                      onPressed: () => _refreshFiles(appState),
                    ),
                  ],
                ),
              ),

              // 文件树
              Expanded(
                child: SimpleFileTreeView(
                  treeItems: _fileTree,
                  onFileTap: _openFile,
                  onFolderTap: _openFile,
                  onDelete: _deleteFile,
                ),
              ),

              // 底部操作栏
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.create_new_folder),
                      tooltip: '新建文件夹',
                      onPressed: _showCreateFolderDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.note_add),
                      tooltip: '新建文件',
                      onPressed: _showCreateFileDialog,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
