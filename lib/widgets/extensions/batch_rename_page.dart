import 'package:flutter/material.dart';

class BatchRenamePage extends StatefulWidget {
  const BatchRenamePage({super.key});

  @override
  State<BatchRenamePage> createState() => _BatchRenamePageState();
}

class _BatchRenamePageState extends State<BatchRenamePage> {
  final List<FileItem> _files = [
    FileItem(name: 'document1.txt', newName: 'document1.txt'),
    FileItem(name: 'image.png', newName: 'image.png'),
    FileItem(name: 'data.json', newName: 'data.json'),
    FileItem(name: 'script.py', newName: 'script.py'),
    FileItem(name: 'config.yaml', newName: 'config.yaml'),
  ];

  String _pattern = '{name}';
  String _prefix = '';
  String _suffix = '';
  int _startNumber = 1;
  bool _includeExtension = true;

  void _applyRenamePattern() {
    setState(() {
      for (int i = 0; i < _files.length; i++) {
        final file = _files[i];
        final nameWithoutExt = file.name.replaceAll(RegExp(r'\.[^.]*\'), '');
        final extension = file.name.substring(file.name.lastIndexOf('.') + 1);

        String newName = _pattern
            .replaceAll('{name}', nameWithoutExt)
            .replaceAll('{prefix}', _prefix)
            .replaceAll('{suffix}', _suffix)
            .replaceAll('{number}', (_startNumber + i).toString())
            .replaceAll('{ext}', extension);

        if (_includeExtension) {
          newName += '.$extension';
        }

        _files[i] = FileItem(name: file.name, newName: newName);
      }
    });
  }

  void _previewRename() {
    _applyRenamePattern();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('预览已更新')));
  }

  void _executeRename() {
    // 模拟重命名操作
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('批量重命名完成')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('批量重命名')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 重命名规则设置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '重命名规则',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 模式设置
                    TextField(
                      decoration: const InputDecoration(
                        labelText: '命名模式',
                        hintText: '例如: {prefix}_{name}_{suffix}_{number}',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => _pattern = value),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '可用变量: {name}, {prefix}, {suffix}, {number}, {ext}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 16),

                    // 前缀后缀设置
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: '前缀',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                setState(() => _prefix = value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: '后缀',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                setState(() => _suffix = value),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 数字和扩展名设置
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: '起始数字',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(
                              () => _startNumber = int.tryParse(value) ?? 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('包含扩展名'),
                            value: _includeExtension,
                            onChanged: (value) => setState(
                              () => _includeExtension = value ?? true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 操作按钮
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _previewRename,
                          icon: const Icon(Icons.preview),
                          label: const Text('预览'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _executeRename,
                          icon: const Icon(Icons.done),
                          label: const Text('执行重命名'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 文件列表
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text(
                            '文件列表',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text('共 ${_files.length} 个文件'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          final isChanged = file.name != file.newName;

                          return ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file.name,
                                  style: TextStyle(
                                    decoration: isChanged
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isChanged ? Colors.grey : null,
                                  ),
                                ),
                                if (isChanged)
                                  Text(
                                    file.newName,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: isChanged
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(Icons.close, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileItem {
  final String name;
  final String newName;

  FileItem({required this.name, required this.newName});
}
