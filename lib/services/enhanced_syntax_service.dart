import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:highlight/languages/plaintext.dart';
import 'package:highlight/languages/sql.dart';
import 'package:highlight/languages/bash.dart';

class EnhancedSyntaxService {
  static final Map<String, Mode> _languageModes = {
    'python': python,
    'c': cpp, // C语言使用C++的语法高亮
    'cpp': cpp,
    'dart': dart,
    'java': java,
    'javascript': javascript,
    'typescript': typescript,
    'css': css,
    'json': json,
    'xml': xml,
    'yaml': yaml,
    'markdown': markdown,
    'plaintext': plaintext,
    'sql': sql,
    'bash': bash,
  };

  static final Map<String, String> _languageMap = {
    '.dart': 'dart',
    '.java': 'java',
    '.py': 'python',
    '.js': 'javascript',
    '.ts': 'typescript',
    '.css': 'css',
    '.json': 'json',
    '.xml': 'xml',
    '.yaml': 'yaml',
    '.yml': 'yaml',
    '.md': 'markdown',
    '.txt': 'plaintext',
    '.c': 'c',
    '.cpp': 'cpp',
    '.h': 'cpp',
    '.sql': 'sql',
    '.sh': 'bash',
  };

  static Mode getLanguageMode(String language) {
    return _languageModes[language] ?? plaintext;
  }

  static String getLanguageFromExtension(String extension) {
    return _languageMap[extension.toLowerCase()] ?? 'plaintext';
  }

  static String getLanguageFromFileName(String fileName) {
    final extension = fileName.toLowerCase();
    for (final entry in _languageMap.entries) {
      if (extension.endsWith(entry.key)) {
        return entry.value;
      }
    }
    return 'plaintext';
  }

  static CodeController createCodeController({
    required String text,
    required String language,
  }) {
    final mode = getLanguageMode(language);

    return CodeController(text: text, language: mode);
  }

  static List<String> getSupportedLanguages() {
    return _languageMap.values.toSet().toList()..sort();
  }

  static List<String> getSupportedExtensions() {
    return _languageMap.keys.toList()..sort();
  }

  static bool isLanguageSupported(String language) {
    return _languageMap.containsValue(language);
  }

  static bool isExtensionSupported(String extension) {
    return _languageMap.containsKey(extension.toLowerCase());
  }

  static Map<String, List<String>> getLanguageKeywords() {
    return {
      'python': [
        'False',
        'None',
        'True',
        'and',
        'as',
        'assert',
        'async',
        'await',
        'break',
        'class',
        'continue',
        'def',
        'del',
        'elif',
        'else',
        'except',
        'finally',
        'for',
        'from',
        'global',
        'if',
        'import',
        'in',
        'is',
        'lambda',
        'nonlocal',
        'not',
        'or',
        'pass',
        'raise',
        'return',
        'try',
        'while',
        'with',
        'yield',
      ],
      'c': [
        'auto',
        'break',
        'case',
        'char',
        'const',
        'continue',
        'default',
        'do',
        'double',
        'else',
        'enum',
        'extern',
        'float',
        'for',
        'goto',
        'if',
        'int',
        'long',
        'register',
        'return',
        'short',
        'signed',
        'sizeof',
        'static',
        'struct',
        'switch',
        'typedef',
        'union',
        'unsigned',
        'void',
        'volatile',
        'while',
      ],
      'cpp': [
        'alignas',
        'alignof',
        'and',
        'and_eq',
        'asm',
        'atomic_cancel',
        'atomic_commit',
        'atomic_noexcept',
        'auto',
        'bitand',
        'bitor',
        'bool',
        'break',
        'case',
        'catch',
        'char',
        'char8_t',
        'char16_t',
        'char32_t',
        'class',
        'compl',
        'concept',
        'const',
        'const_cast',
        'consteval',
        'constexpr',
        'constinit',
        'continue',
        'co_await',
        'co_return',
        'co_yield',
        'decltype',
        'default',
        'delete',
        'do',
        'double',
        'dynamic_cast',
        'else',
        'enum',
        'explicit',
        'export',
        'extern',
        'false',
        'float',
        'for',
        'friend',
        'goto',
        'if',
        'inline',
        'int',
        'long',
        'mutable',
        'namespace',
        'new',
        'noexcept',
        'not',
        'not_eq',
        'nullptr',
        'operator',
        'or',
        'or_eq',
        'private',
        'protected',
        'public',
        'register',
        'reinterpret_cast',
        'requires',
        'return',
        'short',
        'signed',
        'sizeof',
        'static',
        'static_assert',
        'static_cast',
        'struct',
        'switch',
        'template',
        'this',
        'thread_local',
        'throw',
        'true',
        'try',
        'typedef',
        'typeid',
        'typename',
        'union',
        'unsigned',
        'using',
        'virtual',
        'void',
        'volatile',
        'wchar_t',
        'while',
        'xor',
        'xor_eq',
      ],
      'dart': [
        'abstract',
        'as',
        'assert',
        'async',
        'await',
        'break',
        'case',
        'catch',
        'class',
        'const',
        'continue',
        'covariant',
        'default',
        'deferred',
        'do',
        'dynamic',
        'else',
        'enum',
        'export',
        'extends',
        'extension',
        'external',
        'factory',
        'false',
        'final',
        'finally',
        'for',
        'Function',
        'get',
        'hide',
        'if',
        'implements',
        'import',
        'in',
        'interface',
        'is',
        'late',
        'library',
        'mixin',
        'new',
        'null',
        'on',
        'operator',
        'part',
        'rethrow',
        'return',
        'set',
        'show',
        'static',
        'super',
        'switch',
        'sync',
        'this',
        'throw',
        'true',
        'try',
        'typedef',
        'var',
        'void',
        'while',
        'with',
        'yield',
      ],
    };
  }
}
