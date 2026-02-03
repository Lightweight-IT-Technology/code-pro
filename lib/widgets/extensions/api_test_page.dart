import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _headersController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  
  String _selectedMethod = 'GET';
  String _selectedContentType = 'application/json';
  bool _isLoading = false;
  int _responseStatus = 0;
  String _responseTime = '';
  
  final List<String> _httpMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];
  final List<String> _contentTypes = [
    'application/json',
    'application/x-www-form-urlencoded',
    'multipart/form-data',
    'text/plain',
    'application/xml',
  ];

  @override
  void initState() {
    super.initState();
    _headersController.text = '{\n  "Content-Type": "application/json"\n}';
  }

  void _sendRequest() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入API地址')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _responseController.clear();
      _responseStatus = 0;
      _responseTime = '';
    });

    try {
      final startTime = DateTime.now();
      
      final uri = Uri.parse(_urlController.text);
      final headers = _parseHeaders();
      final body = _parseBody();

      http.Response response;
      
      switch (_selectedMethod) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: body);
          break;
        default:
          throw Exception('不支持的HTTP方法');
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      setState(() {
        _isLoading = false;
        _responseStatus = response.statusCode;
        _responseTime = '${duration.inMilliseconds}ms';
        _responseController.text = _formatResponse(response);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请求完成: ${response.statusCode}')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseController.text = '错误: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请求失败: $e')),
      );
    }
  }

  Map<String, String> _parseHeaders() {
    final headers = <String, String>{};
    
    try {
      final headerText = _headersController.text.trim();
      if (headerText.isNotEmpty) {
        final jsonMap = json.decode(headerText);
        if (jsonMap is Map<String, dynamic>) {
          jsonMap.forEach((key, value) {
            headers[key] = value.toString();
          });
        }
      }
    } catch (e) {
      // 如果JSON解析失败，使用简单格式
      final lines = _headersController.text.split('\n');
      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim();
          headers[key] = value;
        }
      }
    }
    
    // 确保Content-Type存在
    if (!headers.containsKey('Content-Type')) {
      headers['Content-Type'] = _selectedContentType;
    }
    
    return headers;
  }

  String _parseBody() {
    final bodyText = _bodyController.text.trim();
    if (bodyText.isEmpty) return '';
    
    try {
      // 如果是JSON格式，验证并格式化
      if (_selectedContentType == 'application/json') {
        final jsonData = json.decode(bodyText);
        return json.encode(jsonData);
      }
      return bodyText;
    } catch (e) {
      return bodyText;
    }
  }

  String _formatResponse(http.Response response) {
    final responseData = {
      'status': response.statusCode,
      'headers': response.headers,
      'body': _tryParseJson(response.body),
    };
    
    return const JsonEncoder.withIndent('  ').convert(responseData);
  }

  dynamic _tryParseJson(String text) {
    try {
      return json.decode(text);
    } catch (e) {
      return text;
    }
  }

  void _clearAll() {
    setState(() {
      _urlController.clear();
      _headersController.text = '{\n  "Content-Type": "application/json"\n}';
      _bodyController.clear();
      _responseController.clear();
      _responseStatus = 0;
      _responseTime = '';
    });
  }

  void _loadExample() {
    setState(() {
      _urlController.text = 'https://jsonplaceholder.typicode.com/posts';
      _headersController.text = '{\n  "Content-Type": "application/json"\n}';
      _bodyController.text = '{\n  "title": "foo",\n  "body": "bar",\n  "userId": 1\n}';
      _selectedMethod = 'POST';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API测试工具'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _loadExample,
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
          // 请求配置
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('请求配置:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // URL和HTTP方法
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'API地址',
                            hintText: 'https://api.example.com/endpoint',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedMethod,
                        items: _httpMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMethod = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Content-Type
                  Row(
                    children: [
                      const Text('Content-Type:', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedContentType,
                        items: _contentTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedContentType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 请求头和请求体
          Expanded(
            child: Row(
              children: [
                // 请求头
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('请求头:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _headersController,
                                maxLines: null,
                                expands: true,
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
                
                // 请求体
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.only(left: 8, right: 16, bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('请求体:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _bodyController,
                                maxLines: null,
                                expands: true,
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
          
          // 发送按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendRequest,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isLoading ? '发送中...' : '发送请求'),
                  ),
                ),
              ],
            ),
          ),
          
          // 响应信息
          if (_responseStatus > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text('状态: $_responseStatus'),
                    backgroundColor: _getStatusColor(_responseStatus),
                  ),
                  Chip(
                    label: Text('时间: $_responseTime'),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
          
          // 响应内容
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('响应内容:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextField(
                          controller: _responseController,
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
    );
  }

  Color _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.blue;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.orange;
    } else if (statusCode >= 500) {
      return Colors.red;
    }
    return Colors.grey;
  }
}