import 'package:flutter/material.dart';
import '../models/file_tree_model.dart';

class FileTreeView extends StatefulWidget {
  final List<FileTreeItem> treeItems;
  final Function(FileTreeItem) onFileTap;
  final Function(FileTreeItem) onFolderTap;
  final Function(FileTreeItem) onDelete;

  const FileTreeView({
    super.key,
    required this.treeItems,
    required this.onFileTap,
    required this.onFolderTap,
    required this.onDelete,
  });

  @override
  State<FileTreeView> createState() => _FileTreeViewState();
}

class _FileTreeViewState extends State<FileTreeView> {
  @override
  Widget build(BuildContext context) {
    final flattenedTree = _flattenTree(widget.treeItems);

    return ListView.builder(
      itemCount: flattenedTree.length,
      itemBuilder: (context, index) {
        final treeItem = flattenedTree[index];
        return _FileTreeItemWidget(
          item: treeItem.item,
          level: treeItem.level,
          onTap: () {
            if (treeItem.item.isDirectory) {
              setState(() {
                treeItem.item.isExpanded = !treeItem.item.isExpanded;
              });
              widget.onFolderTap(treeItem.item);
            } else {
              widget.onFileTap(treeItem.item);
            }
          },
          onDelete: () => widget.onDelete(treeItem.item),
        );
      },
    );
  }

  List<_FlattenedTreeItem> _flattenTree(List<FileTreeItem> tree) {
    final List<_FlattenedTreeItem> result = [];

    void traverse(List<FileTreeItem> items, int level) {
      for (final item in items) {
        result.add(_FlattenedTreeItem(item: item, level: level));
        if (item.isDirectory && item.isExpanded) {
          traverse(item.children, level + 1);
        }
      }
    }

    traverse(tree, 0);
    return result;
  }
}

class _FlattenedTreeItem {
  final FileTreeItem item;
  final int level;

  _FlattenedTreeItem({required this.item, required this.level});
}

class _FileTreeItemWidget extends StatelessWidget {
  final FileTreeItem item;
  final int level;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FileTreeItemWidget({
    required this.item,
    required this.level,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final indent = level * 20.0;

    return Container(
      padding: EdgeInsets.only(left: indent),
      child: ListTile(
        leading: _buildLeadingIcon(context),
        title: Text(
          item.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: item.isDirectory ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: !item.isDirectory
            ? Text(
                '${_formatFileSize(item.size)} • ${_formatDate(item.modifiedDate)}',
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: onDelete,
          tooltip: '删除',
        ),
        onTap: onTap,
        dense: true,
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    if (item.isDirectory) {
      return Icon(
        item.isExpanded ? Icons.folder_open : Icons.folder,
        color: Colors.amber[700],
        size: 20,
      );
    } else {
      return Icon(
        _getFileIcon(item.name),
        color: Theme.of(context).colorScheme.onSurface,
        size: 20,
      );
    }
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'dart':
      case 'java':
      case 'cpp':
      case 'c':
      case 'h':
      case 'cs':
      case 'py':
      case 'js':
      case 'ts':
      case 'html':
      case 'css':
      case 'php':
      case 'rb':
      case 'go':
      case 'rs':
      case 'swift':
      case 'kt':
        return Icons.code;
      case 'txt':
      case 'md':
      case 'rtf':
        return Icons.description;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'svg':
        return Icons.image;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return Icons.audiotrack;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
        return Icons.videocam;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Icons.archive;
      case 'xml':
      case 'json':
      case 'yaml':
      case 'yml':
      case 'ini':
      case 'cfg':
      case 'conf':
        return Icons.settings;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365}年前';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
