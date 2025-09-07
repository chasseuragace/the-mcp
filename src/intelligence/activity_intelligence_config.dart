// Activity Intelligence - Consciousness-Aware File System Analysis
// Refactored from recent_activity.dart with consciousness integration

import 'dart:io';

/// Consciousness-aware activity analysis configuration
class ActivityIntelligenceConfig {
  final String root;
  final int hours;
  final int fileCount;
  final int dirCount;
  final int maxDepth;
  final Set<String> includeExtensions;
  final Set<String> extraExcludes;

  const ActivityIntelligenceConfig({
    required this.root,
    this.hours = 24,
    this.fileCount = 20,
    this.dirCount = 10,
    this.maxDepth = 5,
    this.includeExtensions = const {
      'dart', 'js', 'ts', 'py', 'java', 'kt', 'swift', 'go', 'rs', 'cpp', 'c', 'h',
      'html', 'css', 'scss', 'vue', 'jsx', 'tsx', 'php', 'rb', 'sh', 'yaml', 'yml',
      'json', 'xml', 'md', 'txt', 'sql', 'dockerfile', 'makefile', 'gradle'
    },
    this.extraExcludes = const <String>{},
  });

  /// Create config from legacy command-line arguments (backward compatibility)
  factory ActivityIntelligenceConfig.fromLegacyArgs(List<String> args) {
    String root = Platform.environment['HOME'] ?? '/';
    int hours = 24;
    int fileCount = 20;
    int dirCount = 10;
    final extraExcludes = <String>{};
    final includeExts = <String>{'dart', 'js', 'ts', 'py', 'java', 'kt', 'swift', 'go', 'rs', 'cpp', 'c', 'h', 'html', 'css', 'scss', 'vue', 'jsx', 'tsx', 'php', 'rb', 'sh', 'yaml', 'yml', 'json', 'xml', 'md', 'txt', 'sql'};

    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--root':
        case '-r':
          if (i + 1 < args.length) root = args[++i];
          break;
        case '--hours':
        case '-h':
          if (i + 1 < args.length) hours = int.tryParse(args[++i]) ?? 24;
          break;
        case '--files':
        case '-f':
          if (i + 1 < args.length) fileCount = int.tryParse(args[++i]) ?? 20;
          break;
        case '--dirs':
        case '-d':
          if (i + 1 < args.length) dirCount = int.tryParse(args[++i]) ?? 10;
          break;
        case '--exclude':
        case '-e':
          if (i + 1 < args.length) extraExcludes.add(args[++i]);
          break;
        case '--ext':
          if (i + 1 < args.length) {
            includeExts.clear();
            includeExts.addAll(args[++i].split(','));
          }
          break;
      }
    }

    return ActivityIntelligenceConfig(
      root: root,
      hours: hours,
      fileCount: fileCount,
      dirCount: dirCount,
      includeExtensions: includeExts,
      extraExcludes: extraExcludes,
    );
  }

  factory ActivityIntelligenceConfig.fromArgs(List<String> args) {
    String root = Platform.environment['HOME'] ?? Directory.current.path;
    int fileCount = 50;
    int dirCount = 50;
    int hours = 1440;
    bool verbose = false;
    bool summarize = false;
    bool quick = false;
    bool onlyUserExts = false;
    final extraExcludes = <String>[];
    final userExts = <String>{};

    for (int i = 0; i < args.length; i++) {
      final arg = args[i];
      switch (arg) {
        case '-r': root = _getNextArg(args, i++); break;
        case '-n': fileCount = int.tryParse(_getNextArg(args, i++)) ?? fileCount; break;
        case '-d': dirCount = int.tryParse(_getNextArg(args, i++)) ?? dirCount; break;
        case '-x': extraExcludes.add(_getNextArg(args, i++)); break;
        case '-e': userExts.add(_getNextArg(args, i++).toLowerCase()); break;
        case '-t': hours = int.tryParse(_getNextArg(args, i++)) ?? hours; break;
        case '-v': verbose = true; break;
        case '-s': summarize = true; break;
        case '-q': quick = true; break;
        case '-O': case '--only-exts': onlyUserExts = true; break;
      }
    }

    return ActivityIntelligenceConfig(
      root: root,
      fileCount: fileCount,
      dirCount: dirCount,
      hours: hours,
      extraExcludes: extraExcludes.toSet(),
      includeExtensions: userExts.isNotEmpty ? userExts : const {
        'dart', 'js', 'ts', 'py', 'java', 'kt', 'swift', 'go', 'rs', 'cpp', 'c', 'h',
        'html', 'css', 'scss', 'vue', 'jsx', 'tsx', 'php', 'rb', 'sh', 'yaml', 'yml',
        'json', 'xml', 'md', 'txt', 'sql'
      },
    );
  }
  
  static String _getNextArg(List<String> args, int index) {
    if (index >= args.length) {
      stderr.writeln('Error: Missing argument');
      exit(2);
    }
    return args[index];
  }
}
