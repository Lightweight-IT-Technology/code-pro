class SyntaxService {
  static final Map<String, String> _languageMap = {
    '.dart': 'dart',
    '.java': 'java',
    '.kt': 'kotlin',
    '.swift': 'swift',
    '.py': 'python',
    '.js': 'javascript',
    '.ts': 'typescript',
    '.html': 'html',
    '.css': 'css',
    '.scss': 'scss',
    '.json': 'json',
    '.xml': 'xml',
    '.yaml': 'yaml',
    '.yml': 'yaml',
    '.md': 'markdown',
    '.txt': 'plaintext',
    '.c': 'c',
    '.cpp': 'cpp',
    '.h': 'cpp',
    '.cs': 'csharp',
    '.php': 'php',
    '.rb': 'ruby',
    '.go': 'go',
    '.rs': 'rust',
    '.sql': 'sql',
    '.sh': 'bash',
    '.bat': 'batch',
    '.ps1': 'powershell',
  };

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
}
