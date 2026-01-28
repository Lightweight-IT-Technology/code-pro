
import 'package:flutter/material.dart';
import '../models/simple_file_tree_model.dart';

class SimpleFileTreeView extends StatefulWidget {
  final List<SimpleFileTreeItem> treeItems;
  final Function(SimpleFileTreeItem) onFileTap;
  final Function(SimpleFileTreeItem) onFolderTap;
  final Function(SimpleFileTreeItem) onDelete;

  const SimpleFileTreeView({
    super.key,
    required this.treeItems,
    required this.onFileTap,
    required this.onFolderTap,
    required this.onDelete,
  });

  @override
  State<SimpleFileTreeView> createState() => _SimpleFileTreeViewState();
}

class _SimpleFileTreeViewState extends State<SimpleFileTreeView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.treeItems.length,
      itemBuilder: (context, index) {
        return _buildTreeItem(widget.treeItems[index], 0);
      },
    );
  }

  Widget _buildTreeItem(SimpleFileTreeItem item, int level) {
    final indent = level * 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: indent),
          child: ListTile(
            leading: _buildLeadingIcon(item),
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
              onPressed: () => widget.onDelete(item),
              tooltip: '删除',
            ),
            onTap: () async {
              if (item.isDirectory) {
                // 处理文件夹点击
                if (item.isExpanded) {
                  // 收起文件夹
                  setState(() {
                    SimpleFileTreeManager.collapseFolder(item);
                  });
                } else {
                  // 展开文件夹
                  await SimpleFileTreeManager.expandFolder(item);
                  setState(() {});
                }
                widget.onFolderTap(item);
              } else {
                // 处理文件点击
                widget.onFileTap(item);
              }
            },
            dense: true,
          ),
        ),
        // 递归显示子项
        if (item.isDirectory && item.isExpanded)
          ...item.children.map((child) => _buildTreeItem(child, level + 1)),
      ],
    );
  }

  Widget _buildLeadingIcon(SimpleFileTreeItem item) {
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
        return Icons.data_object;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int size) {
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
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