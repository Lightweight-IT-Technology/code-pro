import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<TerminalLine> _outputLines = [];
  Process? _currentProcess;
  bool _isRunning = false;
  String _currentDirectory = '';

  @override
  void initState() {
    super.initState();
    _initializeTerminal();
  }

  @override
  void dispose() {
    _currentProcess?.kill();
    super.dispose();
  }

  void _initializeTerminal() async {
    try {
      final currentDir = Directory.current.path;
      setState(() {
        _currentDirectory = currentDir;
        _addOutputLine('终端已启动 - 当前目录: $currentDir', TerminalLineType.info);
        _addOutputLine('输入 "help" 查看可用命令', TerminalLineType.info);
        _addPrompt();
      });
    } catch (e) {
      _addOutputLine('初始化终端失败: $e', TerminalLineType.error);
    }
  }

  void _addOutputLine(String text, TerminalLineType type) {
    setState(() {
      _outputLines.add(TerminalLine(text: text, type: type));
    });
    _scrollToBottom();
  }

  void _addPrompt() {
    final prompt = '\$_currentDirectory> ';
    _addOutputLine(prompt, TerminalLineType.prompt);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _executeCommand(String command) async {
    if (command.trim().isEmpty) {
      _addPrompt();
      return;
    }

    setState(() {
      _isRunning = true;
    });

    try {
      // 处理内置命令
      if (_handleBuiltinCommands(command)) {
        return;
      }

      // 执行系统命令
      final process = await Process.start(
        Platform.isWindows ? 'cmd' : '/bin/sh',
        Platform.isWindows ? ['/c', command] : ['-c', command],
        workingDirectory: _currentDirectory.isNotEmpty
            ? _currentDirectory
            : null,
      );

      _currentProcess = process;

      // 读取标准输出
      process.stdout.transform(const Utf8Decoder()).listen((data) {
        _addOutputLine(data, TerminalLineType.output);
      });

      // 读取标准错误
      process.stderr.transform(const Utf8Decoder()).listen((data) {
        _addOutputLine(data, TerminalLineType.error);
      });

      // 等待命令完成
      final exitCode = await process.exitCode;

      setState(() {
        _isRunning = false;
        _currentProcess = null;
      });

      _addOutputLine('命令执行完成，退出码: $exitCode', TerminalLineType.info);
      _addPrompt();
    } catch (e) {
      setState(() {
        _isRunning = false;
      });
      _addOutputLine('执行命令失败: $e', TerminalLineType.error);
      _addPrompt();
    }
  }

  bool _handleBuiltinCommands(String command) {
    final parts = command.trim().split(' ');
    final cmd = parts[0].toLowerCase();
    final args = parts.sublist(1);

    switch (cmd) {
      case 'clear':
        setState(() {
          _outputLines.clear();
        });
        _addPrompt();
        return true;

      case 'cd':
        if (args.isEmpty) {
          _addOutputLine('当前目录: $_currentDirectory', TerminalLineType.info);
        } else {
          final newDir = args[0];
          try {
            final targetDir = Directory(newDir);
            if (targetDir.existsSync()) {
              setState(() {
                _currentDirectory = targetDir.absolute.path;
              });
              _addOutputLine(
                '目录已切换到: $_currentDirectory',
                TerminalLineType.info,
              );
            } else {
              _addOutputLine('目录不存在: $newDir', TerminalLineType.error);
            }
          } catch (e) {
            _addOutputLine('切换目录失败: $e', TerminalLineType.error);
          }
        }
        _addPrompt();
        return true;

      case 'pwd':
        _addOutputLine(_currentDirectory, TerminalLineType.output);
        _addPrompt();
        return true;

      case 'ls':
      case 'dir':
        _listDirectory(args);
        return true;

      case 'help':
        _showHelp();
        return true;

      default:
        return false;
    }
  }

  void _listDirectory(List<String> args) async {
    try {
      final dir = Directory(_currentDirectory);
      final entities = dir.listSync();

      for (final entity in entities) {
        final type = entity is Directory ? 'DIR' : 'FILE';
        final size = entity is File ? '${entity.lengthSync()} bytes' : '';
        final modified = entity.statSync().modified.toString().substring(0, 19);

        _addOutputLine(
          '$type\t$modified\t$size\t${entity.path.split(Platform.pathSeparator).last}',
          TerminalLineType.output,
        );
      }
    } catch (e) {
      _addOutputLine('列出目录失败: $e', TerminalLineType.error);
    }
    _addPrompt();
  }

  void _showHelp() {
    _addOutputLine('可用命令:', TerminalLineType.info);
    _addOutputLine('  clear     - 清空终端', TerminalLineType.output);
    _addOutputLine('  cd <dir>  - 切换目录', TerminalLineType.output);
    _addOutputLine('  pwd       - 显示当前目录', TerminalLineType.output);
    _addOutputLine('  ls/dir    - 列出目录内容', TerminalLineType.output);
    _addOutputLine('  help      - 显示此帮助', TerminalLineType.output);
    _addOutputLine('其他命令将作为系统命令执行', TerminalLineType.info);
    _addPrompt();
  }

  void _onCommandSubmitted(String command) {
    _commandController.clear();
    _executeCommand(command);
  }

  void _stopCurrentCommand() {
    if (_currentProcess != null) {
      _currentProcess!.kill();
      setState(() {
        _isRunning = false;
        _currentProcess = null;
      });
      _addOutputLine('命令已停止', TerminalLineType.info);
      _addPrompt();
    }
  }

  void _clearTerminal() {
    setState(() {
      _outputLines.clear();
    });
    _addPrompt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('终端模拟器'),
        actions: [
          if (_isRunning) ...[
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopCurrentCommand,
              tooltip: '停止当前命令',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearTerminal,
            tooltip: '清空终端',
          ),
        ],
      ),
      body: Column(
        children: [
          // 终端输出区域
          Expanded(
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _outputLines.length,
                itemBuilder: (context, index) {
                  final line = _outputLines[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2.0,
                    ),
                    child: SelectableText(
                      line.text,
                      style: TextStyle(
                        color: _getTextColor(line.type),
                        fontFamily: 'Courier New',
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 命令输入区域
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    decoration: InputDecoration(
                      hintText: _isRunning ? '命令执行中...' : '输入命令...',
                      border: const OutlineInputBorder(),
                      suffixIcon: _isRunning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    onSubmitted: _isRunning ? null : _onCommandSubmitted,
                    enabled: !_isRunning,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isRunning
                      ? null
                      : () => _onCommandSubmitted(_commandController.text),
                  child: const Text('执行'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(TerminalLineType type) {
    switch (type) {
      case TerminalLineType.prompt:
        return Colors.green;
      case TerminalLineType.output:
        return Colors.white;
      case TerminalLineType.error:
        return Colors.red;
      case TerminalLineType.info:
        return Colors.cyan;
      default:
        return Colors.white;
    }
  }
}

class TerminalLine {
  final String text;
  final TerminalLineType type;

  TerminalLine({required this.text, required this.type});
}

enum TerminalLineType { prompt, output, error, info }
