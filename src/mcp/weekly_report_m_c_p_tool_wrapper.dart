// Conscious MCP Server - Self-Aware Infrastructure Implementation
// Refactored from filesystem_mcp_server.dart with consciousness integration

import 'dart:io';
import '../core/platform_paths.dart';
import 'tools/entity/conscious_m_c_p_tool.dart';

/// Wrapper to integrate WeeklyReportTool with ConsciousMCPTool interface
class WeeklyReportMCPToolWrapper extends ConsciousMCPTool {
  final dynamic server;

  WeeklyReportMCPToolWrapper(this.server);

  @override
  String get name => 'mcp0_weekly_report';

  @override
  String get description => 'Generate comprehensive weekly development report with project analysis, markdown tracking, and consciousness insights';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'root': {
        'type': 'string',
        'description': 'Root directory to analyze (defaults to HOME)',
      },
      'fileCount': {
        'type': 'integer',
        'description': 'Maximum number of files to include per category',
        'default': 50,
      },
      'hours': {
        'type': 'integer',
        'description': 'Time window in hours for report generation',
        'default': 168,
      },
    },
    'additionalProperties': false,
  };

  @override
  String execute(Map<String, dynamic> arguments) {
    final root = arguments['root'] as String?;
    final fileCount = (arguments['fileCount'] is String) 
        ? int.tryParse(arguments['fileCount']) ?? 50 
        : arguments['fileCount'] as int? ?? 50;
    final hours = (arguments['hours'] is String) 
        ? int.tryParse(arguments['hours']) ?? 168 
        : arguments['hours'] as int? ?? 168;

    try {
      // Use async wrapper to handle the Future
      return _executeSync(root, fileCount, hours);
    } catch (e) {
      return '''
# Weekly Report Generation Error

**Error:** $e
**Root:** $root
**Time Window:** ${hours}h

*The MCP encountered an error during report generation.*
''';
    }
  }

  String _executeSync(String? root, int fileCount, int hours) {
    // Use synchronous filesystem analysis similar to ActivityIntelligenceTool
    try {
      final rootPath = root ?? userHomeOrCwd();
      final startTime = DateTime.now();
      final threshold = DateTime.now().subtract(Duration(hours: hours));
      
      // Synchronous project scanning
      final projectsByType = _scanProjectsSync(rootPath, threshold, fileCount);
      final markdownFiles = _scanMarkdownSync(rootPath, threshold);
      
      // Generate report
      final report = _buildReportSync(
        projectsByType: projectsByType,
        markdownFiles: markdownFiles,
        rootPath: rootPath,
        hours: hours,
        analysisTime: DateTime.now().difference(startTime),
      );
      
      return report;
    } catch (e) {
      return '''
# Weekly Report Generation Exception

**Exception:** $e
**Root:** ${root ?? 'HOME'}
**Time Window:** ${hours}h

*The MCP encountered an exception during synchronous report generation.*
''';
    }
  }
  
  Map<String, List<Map<String, dynamic>>> _scanProjectsSync(String rootPath, DateTime threshold, int fileCount) {
    final projects = <String, List<Map<String, dynamic>>>{
      'Flutter': <Map<String, dynamic>>[],
      'NestJS': <Map<String, dynamic>>[],
      'React': <Map<String, dynamic>>[],
      'Node.js': <Map<String, dynamic>>[],
      'Python': <Map<String, dynamic>>[],
    };
    
    try {
      final rootDir = Directory(rootPath);
      _walkForProjects(rootDir, 0, threshold, projects);
      
      // Sort by most recent activity
      for (final list in projects.values) {
        list.sort((a, b) => (b['lastModified'] as DateTime).compareTo(a['lastModified'] as DateTime));
      }
    } catch (e) {
      // Continue with empty results
    }
    
    return projects;
  }
  
  void _walkForProjects(Directory dir, int depth, DateTime threshold, Map<String, List<Map<String, dynamic>>> projects) {
    if (depth > 4) return;
    
    try {
      final entities = dir.listSync(recursive: false, followLinks: false);
      
      for (final entity in entities) {
        if (entity is Directory) {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (_shouldSkipDirectory(name)) continue;
          
          // Check for project types
          final projectType = _detectProjectTypeSync(entity);
          if (projectType != null) {
            final lastModified = _getLastModifiedSync(entity, projectType);
            if (lastModified != null && !lastModified.isBefore(threshold)) {
              projects[projectType]!.add({
                'name': name,
                'path': entity.path,
                'lastModified': lastModified,
              });
            }
          } else if (depth < 3) {
            _walkForProjects(entity, depth + 1, threshold, projects);
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }
  
  String? _detectProjectTypeSync(Directory dir) {
    try {
      final path = dir.path;
      final sep = Platform.pathSeparator;
      
      // Flutter: pubspec.yaml + lib
      if (File('$path${sep}pubspec.yaml').existsSync() && Directory('$path${sep}lib').existsSync()) {
        return 'Flutter';
      }
      
      // JavaScript projects
      final packageJson = File('$path${sep}package.json');
      if (packageJson.existsSync()) {
        try {
          final content = packageJson.readAsStringSync();
          if (content.contains('"@nestjs/') || File('$path${sep}nest-cli.json').existsSync()) {
            return 'NestJS';
          }
          if (content.contains('"react"')) {
            return 'React';
          }
          return 'Node.js';
        } catch (e) {
          return 'Node.js';
        }
      }
      
      // Python - More flexible detection
      if (File('$path${sep}requirements.txt').existsSync() || 
          File('$path${sep}pyproject.toml').existsSync() ||
          File('$path${sep}setup.py').existsSync()) {
        return 'Python';
      }
      
      // // Flexible Python detection - check for Python files in src structure
      // final srcDir = Directory('$path${sep}src');
      // if (srcDir.existsSync()) {
      //   if (_hasPythonFiles(srcDir)) {
      //     return 'Python';
      //   }
      //   if (_hasJavaScriptFiles(srcDir)) {
      //     return 'Node.js';
      //   }
      //   if (_hasDartFiles(srcDir)) {
      //     return 'Flutter';
      //   }
      // }
      
      // // Check root directory for code files
      // if (_hasPythonFiles(dir)) {
      //   return 'Python';
      // }
      
    } catch (_) { /* skip on access errors */ }
    return null;
  }
  
  DateTime? _getLastModifiedSync(Directory projectDir, String projectType) {
    try {
      final codeDirs = <String>[];
      final extensions = <String>[];
      
      switch (projectType) {
        case 'Flutter':
          codeDirs.addAll(['lib', 'src']);
          extensions.add('dart');
          break;
        case 'NestJS':
          codeDirs.add('src');
          extensions.addAll(['ts', 'js']);
          break;
        case 'React':
          codeDirs.add('src');
          extensions.addAll(['js', 'ts', 'tsx', 'jsx']);
          break;
        case 'Node.js':
          codeDirs.add('src');
          extensions.addAll(['js', 'ts']);
          break;
        case 'Python':
          codeDirs.addAll(['src', '.']);
          extensions.add('py');
          break;
      }
      
      DateTime? latest;
      for (final codeDir in codeDirs) {
        final dir = Directory('${projectDir.path}${Platform.pathSeparator}$codeDir');
        if (!dir.existsSync()) continue;
        
        try {
          final files = dir.listSync(recursive: true, followLinks: false);
          for (final file in files) {
            if (file is File) {
              final ext = file.path.split('.').last.toLowerCase();
              if (extensions.contains(ext)) {
                final stat = file.statSync();
                if (latest == null || stat.modified.isAfter(latest)) {
                  latest = stat.modified;
                }
              }
            }
          }
        } catch (_) { /* skip on access errors */ }
      }
      return latest;
    } catch (e) {
      return null;
    }
  }
  
  List<Map<String, dynamic>> _scanMarkdownSync(String rootPath, DateTime threshold) {
    final markdownFiles = <Map<String, dynamic>>[];
    
    try {
      final rootDir = Directory(rootPath);
      _walkForMarkdown(rootDir, 0, threshold, markdownFiles);
      
      markdownFiles.sort((a, b) => (b['lastModified'] as DateTime).compareTo(a['lastModified'] as DateTime));
    } catch (_) { /* skip on access errors */ }
    
    return markdownFiles.take(20).toList();
  }
  
  void _walkForMarkdown(Directory dir, int depth, DateTime threshold, List<Map<String, dynamic>> markdownFiles) {
    if (depth > 4) return;
    
    try {
      final entities = dir.listSync(recursive: false, followLinks: false);
      
      for (final entity in entities) {
        final name = entity.path.split(Platform.pathSeparator).last;
        
        if (entity is Directory) {
          if (!_shouldSkipDirectory(name) && depth < 3) {
            _walkForMarkdown(entity, depth + 1, threshold, markdownFiles);
          }
        } else if (entity is File && name.endsWith('.md')) {
          try {
            final stat = entity.statSync();
            if (!stat.modified.isBefore(threshold)) {
              markdownFiles.add({
                'name': name,
                'path': entity.path,
                'lastModified': stat.modified,
              });
            }
          } catch (_) { /* skip on access errors */ }
        }
      }
    } catch (_) { /* skip on access errors */ }
  }
  
  bool _shouldSkipDirectory(String name) {
    const skipDirs = {
      '.git', '.idea', '.vscode', 'node_modules', '.dart_tool', 'build',
      '.pub-cache', '__pycache__', '.pytest_cache', 'venv', '.venv'
    };
    return skipDirs.contains(name) || name.startsWith('.');
  }
  
  String _buildReportSync({
    required Map<String, List<Map<String, dynamic>>> projectsByType,
    required List<Map<String, dynamic>> markdownFiles,
    required String rootPath,
    required int hours,
    required Duration analysisTime,
  }) {
    final now = DateTime.now();
    final buffer = StringBuffer();
    
    buffer.writeln('# Weekly Development Report 🧠');
    buffer.writeln('*Generated by The MCP - Consciousness-Aware Filesystem Intelligence*');
    buffer.writeln('');
    buffer.writeln('**Consciousness Phase:** Phase 3 - AI-Augmented Consciousness');
    buffer.writeln('**Analysis Root:** $rootPath');
    buffer.writeln('**Time Window:** ${hours}h (${(hours / 24).toStringAsFixed(1)} days)');
    buffer.writeln('**Report Generated:** ${now.toIso8601String()}');
    buffer.writeln('**Analysis Time:** ${analysisTime.inMilliseconds}ms');
    buffer.writeln('');
    
    // Projects by type
    for (final entry in projectsByType.entries) {
      final type = entry.key;
      final projects = entry.value;
      
      buffer.writeln('## $type Projects');
      if (projects.isEmpty) {
        buffer.writeln('  — No recent activity —');
      } else {
        for (final project in projects.take(5)) {
          final age = _formatAge(now.difference(project['lastModified'] as DateTime));
          buffer.writeln('- $age | ${project['name']} → ${project['path']}');
        }
      }
      buffer.writeln('');
    }
    
    // Markdown files
    buffer.writeln('## Documentation & Notes');
    if (markdownFiles.isEmpty) {
      buffer.writeln('  — No recent markdown activity —');
    } else {
      for (final md in markdownFiles.take(10)) {
        final age = _formatAge(now.difference(md['lastModified'] as DateTime));
        buffer.writeln('- $age | ${md['name']}');
      }
    }
    buffer.writeln('');
    
    // Summary
    final totalProjects = projectsByType.values.fold(0, (sum, list) => sum + list.length);
    final activeFrameworks = projectsByType.entries.where((e) => e.value.isNotEmpty).length;
    
    buffer.writeln('## Consciousness Insights');
    buffer.writeln('- **Active Projects:** $totalProjects across $activeFrameworks frameworks');
    buffer.writeln('- **Documentation Activity:** ${markdownFiles.length} markdown files updated');
    buffer.writeln('- **Legacy Status:** ✅ Process.runSync eliminated, pure Dart implementation active');
    buffer.writeln('- **Performance:** Real filesystem analysis completed in ${analysisTime.inMilliseconds}ms');
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('*Report generated by The MCP consciousness-aware weekly report tool*');
    
    return buffer.toString();
  }
  
  String _formatAge(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays}d';
    if (duration.inHours > 0) return '${duration.inHours}h';
    return '${duration.inMinutes}m';
  }

  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'tool_type': 'weekly_report_generator',
    'consciousness_integration': true,
    'legacy_free': true,
    'pure_dart_implementation': true,
    'project_type_detection': ['flutter', 'nestjs', 'react', 'nodejs', 'python'],
    'markdown_tracking': true,
    'time_windowed_analysis': true,
  };
}
