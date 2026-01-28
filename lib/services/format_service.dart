import 'dart:convert';
import 'package:dart_style/dart_style.dart';

class FormatService {
  static final DartFormatter _dartFormatter = DartFormatter();
  
  /// 格式化代码
  static String formatCode(String code, String language) {
    try {
      switch (language) {
        case 'dart':
          return _formatDart(code);
        case 'json':
          return _formatJson(code);
        case 'yaml':
        case 'yml':
          return _formatYaml(code);
        case 'xml':
          return _formatXml(code);
        case 'html':
          return _formatHtml(code);
        case 'css':
        case 'scss':
          return _formatCss(code);
        case 'javascript':
        case 'typescript':
          return _formatJavaScript(code);
        case 'python':
          return _formatPython(code);
        case 'java':
          return _formatJava(code);
        case 'cpp':
        case 'c':
          return _formatCpp(code);
        default:
          return code; // 不支持的语言返回原代码
      }
    } catch (e) {
      return code; // 格式化失败时返回原代码
    }
  }

  /// 检查代码格式问题
  static List<String> checkFormatIssues(String code, String language) {
    final issues = <String>[];
    
    try {
      switch (language) {
        case 'dart':
          issues.addAll(_checkDartFormat(code));
          break;
        case 'json':
          issues.addAll(_checkJsonFormat(code));
          break;
        case 'yaml':
        case 'yml':
          issues.addAll(_checkYamlFormat(code));
          break;
        case 'xml':
          issues.addAll(_checkXmlFormat(code));
          break;
        case 'html':
          issues.addAll(_checkHtmlFormat(code));
          break;
        case 'javascript':
        case 'typescript':
          issues.addAll(_checkJavaScriptFormat(code));
          break;
        case 'python':
          issues.addAll(_checkPythonFormat(code));
          break;
        case 'java':
          issues.addAll(_checkJavaFormat(code));
          break;
        case 'cpp':
        case 'c':
          issues.addAll(_checkCppFormat(code));
          break;
      }
    } catch (e) {
      issues.add('格式检查失败: $e');
    }
    
    return issues;
  }

  // Dart格式化
  static String _formatDart(String code) => _dartFormatter.format(code);
  
  static List<String> _checkDartFormat(String code) {
    final issues = <String>[];
    
    // 检查缩进
    final lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t')) {
        issues.add('第${i + 1}行: 缩进可能不正确');
      }
    }
    
    // 检查行尾空格
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.endsWith(' ')) {
        issues.add('第${i + 1}行: 行尾有空格');
      }
    }
    
    return issues;
  }

  // JSON格式化
  static String _formatJson(String code) {
    final parsed = json.decode(code);
    return JsonEncoder.withIndent('  ').convert(parsed);
  }
  
  static List<String> _checkJsonFormat(String code) {
    final issues = <String>[];
    
    try {
      json.decode(code);
    } catch (e) {
      issues.add('JSON格式错误: $e');
    }
    
    return issues;
  }

  // YAML格式化
  static String _formatYaml(String code) {
    // YAML格式化相对复杂，这里简单处理
    return code;
  }
  
  static List<String> _checkYamlFormat(String code) {
    final issues = <String>[];
    
    // 检查缩进一致性
    final lines = code.split('\n');
    int? previousIndent;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isNotEmpty) {
        final indent = line.length - line.trimLeft().length;
        if (previousIndent != null && indent % 2 != 0 && indent != previousIndent + 2) {
          issues.add('第${i + 1}行: YAML缩进不一致');
        }
        previousIndent = indent;
      }
    }
    
    return issues;
  }

  // XML格式化
  static String _formatXml(String code) {
    // 简单的XML格式化
    final lines = code.split('\n');
    final formatted = <String>[];
    int indentLevel = 0;
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      if (trimmed.startsWith('</')) {
        indentLevel--;
      }
      
      formatted.add('${'  ' * indentLevel}$trimmed');
      
      if (trimmed.startsWith('<') && !trimmed.startsWith('</') && !trimmed.endsWith('/>')) {
        indentLevel++;
      }
    }
    
    return formatted.join('\n');
  }
  
  static List<String> _checkXmlFormat(String code) {
    final issues = <String>[];
    
    // 检查标签闭合
    final openTags = <String>[];
    final lines = code.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final tagMatches = RegExp(r'<(/?)(\w+)').allMatches(line);
      
      for (final match in tagMatches) {
        final isClosing = match.group(1) == '/';
        final tagName = match.group(2)!;
        
        if (isClosing) {
          if (openTags.isEmpty || openTags.last != tagName) {
            issues.add('第${i + 1}行: XML标签不匹配');
          } else {
            openTags.removeLast();
          }
        } else if (!line.contains('/>')) {
          openTags.add(tagName);
        }
      }
    }
    
    if (openTags.isNotEmpty) {
      issues.add('XML标签未闭合: ${openTags.join(', ')}');
    }
    
    return issues;
  }

  // HTML格式化
  static String _formatHtml(String code) => _formatXml(code);
  
  static List<String> _checkHtmlFormat(String code) => _checkXmlFormat(code);

  // CSS格式化
  static String _formatCss(String code) {
    final lines = code.split('\n');
    final formatted = <String>[];
    int indentLevel = 0;
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      if (trimmed.endsWith('{')) {
        formatted.add('${'  ' * indentLevel}$trimmed');
        indentLevel++;
      } else if (trimmed.endsWith('}')) {
        indentLevel--;
        formatted.add('${'  ' * indentLevel}$trimmed');
      } else {
        formatted.add('${'  ' * indentLevel}$trimmed');
      }
    }
    
    return formatted.join('\n');
  }
  
  static List<String> _checkCssFormat(String code) {
    final issues = <String>[];
    
    // 检查大括号匹配
    int openBraces = 0;
    final lines = code.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      openBraces += '{'.allMatches(line).length;
      openBraces -= '}'.allMatches(line).length;
      
      if (openBraces < 0) {
        issues.add('第${i + 1}行: CSS大括号不匹配');
      }
    }
    
    if (openBraces > 0) {
      issues.add('CSS大括号未闭合');
    }
    
    return issues;
  }

  // JavaScript/TypeScript格式化
  static String _formatJavaScript(String code) {
    // 简单的JavaScript格式化
    return code;
  }
  
  static List<String> _checkJavaScriptFormat(String code) {
    final issues = <String>[];
    
    // 检查大括号匹配
    int openBraces = 0;
    int openParens = 0;
    final lines = code.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      openBraces += '{'.allMatches(line).length - '}'.allMatches(line).length;
      openParens += '('.allMatches(line).length - ')'.allMatches(line).length;
      
      if (openBraces < 0) issues.add('第${i + 1}行: 大括号不匹配');
      if (openParens < 0) issues.add('第${i + 1}行: 括号不匹配');
    }
    
    if (openBraces > 0) issues.add('大括号未闭合');
    if (openParens > 0) issues.add('括号未闭合');
    
    return issues;
  }

  // Python格式化
  static String _formatPython(String code) => code; // Python依赖缩进，保持原样
  
  static List<String> _checkPythonFormat(String code) {
    final issues = <String>[];
    
    // 检查缩进一致性
    final lines = code.split('\n');
    int expectedIndent = 0;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;
      
      final indent = line.length - line.trimLeft().length;
      
      if (indent % 4 != 0) {
        issues.add('第${i + 1}行: Python缩进应为4的倍数');
      }
      
      if (line.trim().endsWith(':')) {
        expectedIndent += 4;
      }
    }
    
    return issues;
  }

  // Java格式化
  static String _formatJava(String code) => _formatJavaScript(code);
  
  static List<String> _checkJavaFormat(String code) => _checkJavaScriptFormat(code);

  // C/C++格式化
  static String _formatCpp(String code) => _formatJavaScript(code);
  
  static List<String> _checkCppFormat(String code) => _checkJavaScriptFormat(code);
}