import 'package:flutter/material.dart';
import 'dart:convert';

class DatabaseManagerPage extends StatefulWidget {
  const DatabaseManagerPage({super.key});

  @override
  State<DatabaseManagerPage> createState() => _DatabaseManagerPageState();
}

class _DatabaseManagerPageState extends State<DatabaseManagerPage> {
  final TextEditingController _connectionController = TextEditingController();
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  
  String _selectedDatabaseType = 'sqlite';
  String _connectionStatus = '未连接';
  bool _isConnected = false;
  bool _isExecuting = false;
  List<Map<String, dynamic>> _queryResults = [];
  List<String> _tables = [];
  
  final List<String> _databaseTypes = ['sqlite', 'mysql', 'postgresql'];
  final List<String> _sampleQueries = [
    'SELECT * FROM users',
    'SELECT name, email FROM users WHERE active = 1',
    'INSERT INTO users (name, email) VALUES (\'John\', \'john@example.com\')',
    'UPDATE users SET active = 0 WHERE id = 1',
    'DELETE FROM users WHERE id = 1',
  ];

  @override
  void initState() {
    super.initState();
    _connectionController.text = '数据库连接字符串';
    _queryController.text = 'SELECT * FROM users';
  }

  void _connectToDatabase() async {
    if (_connectionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入数据库连接信息')),
      );
      return;
    }

    setState(() {
      _isConnected = true;
      _connectionStatus = '已连接';
    });

    try {
      // 模拟数据库连接
      await Future.delayed(const Duration(seconds: 2));
      
      // 模拟获取表列表
      _tables = ['users', 'products', 'orders', 'categories'];
      
      setState(() {
        _connectionStatus = '已连接 - ${_tables.length} 个表';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据库连接成功')),
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = '连接失败';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('连接失败: $e')),
      );
    }
  }

  void _disconnectFromDatabase() {
    setState(() {
      _isConnected = false;
      _connectionStatus = '未连接';
      _tables.clear();
      _queryResults.clear();
      _resultController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已断开数据库连接')),
    );
  }

  void _executeQuery() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先连接数据库')),
      );
      return;
    }

    if (_queryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入SQL查询语句')),
      );
      return;
    }

    setState(() {
      _isExecuting = true;
      _queryResults.clear();
      _resultController.clear();
    });

    try {
      // 模拟查询执行
      await Future.delayed(const Duration(seconds: 1));
      
      final query = _queryController.text.trim().toLowerCase();
      
      if (query.startsWith('select')) {
        // 模拟SELECT查询结果
        _queryResults = [
          {
            'id': 1,
            'name': '张三',
            'email': 'zhangsan@example.com',
            'active': true,
            'created_at': '2024-01-15 10:30:00',
          },
          {
            'id': 2,
            'name': '李四',
            'email': 'lisi@example.com',
            'active': false,
            'created_at': '2024-01-16 14:20:00',
          },
          {
            'id': 3,
            'name': '王五',
            'email': 'wangwu@example.com',
            'active': true,
            'created_at': '2024-01-17 09:15:00',
          },
        ];
        
        _resultController.text = const JsonEncoder.withIndent('  ').convert(_queryResults);
      } else if (query.startsWith('insert') || query.startsWith('update') || query.startsWith('delete')) {
        // 模拟DML操作结果
        final affectedRows = 1;
        _resultController.text = '操作成功，影响行数: $affectedRows';
      } else {
        // 其他查询类型
        _resultController.text = '查询执行完成';
      }

      setState(() {
        _isExecuting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('查询执行完成')),
      );
    } catch (e) {
      setState(() {
        _isExecuting = false;
        _resultController.text = '错误: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('查询失败: $e')),
      );
    }
  }

  void _loadSampleQuery(String query) {
    setState(() {
      _queryController.text = query;
    });
  }

  void _clearAll() {
    setState(() {
      _queryController.clear();
      _resultController.clear();
      _queryResults.clear();
    });
  }

  void _exportResults() {
    if (_queryResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有结果可导出')),
      );
      return;
    }

    // 模拟导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('结果已导出')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据库管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _loadSampleQuery(_sampleQueries.first),
            tooltip: '加载示例',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAll,
            tooltip: '清空所有',
          ),
        ],
      ),
      body: Column(
        children: [
          // 数据库连接配置
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('数据库连接:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      const Text('数据库类型:', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedDatabaseType,
                        items: _databaseTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDatabaseType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _connectionController,
                    decoration: const InputDecoration(
                      labelText: '连接字符串',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('状态: $_connectionStatus', style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                      Row(
                        children: [
                          if (!_isConnected) ...[
                            ElevatedButton.icon(
                              onPressed: _connectToDatabase,
                              icon: const Icon(Icons.link),
                              label: const Text('连接'),
                            ),
                          ] else ...[
                            ElevatedButton.icon(
                              onPressed: _disconnectFromDatabase,
                              icon: const Icon(Icons.link_off),
                              label: const Text('断开'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 数据库表列表
          if (_isConnected && _tables.isNotEmpty) ...[
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('数据库表:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _tables.map((table) {
                        return Chip(
                          label: Text(table),
                          onDeleted: () {
                            // 模拟表操作
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('点击了表: $table')),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // 查询区域
          Expanded(
            child: Row(
              children: [
                // 查询输入区域
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SQL查询:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          
                          // 示例查询
                          if (_sampleQueries.isNotEmpty) ...[
                            SizedBox(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _sampleQueries.length,
                                itemBuilder: (context, index) {
                                  final query = _sampleQueries[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () => _loadSampleQuery(query),
                                      child: Text('示例 ${index + 1}'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _queryController,
                                maxLines: null,
                                expands: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isExecuting || !_isConnected ? null : _executeQuery,
                                icon: _isExecuting 
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.play_arrow),
                                label: Text(_isExecuting ? '执行中...' : '执行查询'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _queryResults.isEmpty ? null : _exportResults,
                                icon: const Icon(Icons.download),
                                label: const Text('导出结果'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // 查询结果区域
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.only(left: 8, right: 16, bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('查询结果:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          
                          if (_queryResults.isNotEmpty) ...[
                            Text('结果数量: ${_queryResults.length} 行', style: const TextStyle(color: Colors.green)),
                            const SizedBox(height: 8),
                          ],
                          
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _resultController,
                                maxLines: null,
                                expands: true,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}