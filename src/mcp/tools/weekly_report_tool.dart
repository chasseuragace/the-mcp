import 'dart:io';
import '../../core/consciousness_core.dart';

/// Weekly Report Generation Tool for The MCP
/// Integrates legacy scan_projects.dart functionality with consciousness awareness
class WeeklyReportTool {
  final ConsciousnessCore _consciousness;
  final String _reportOutputDir;

  WeeklyReportTool({
    required ConsciousnessCore consciousness,
    required String reportOutputDir,
  })  : _consciousness = consciousness,
        _reportOutputDir = reportOutputDir;

  /// Generate weekly report with consciousness awareness
  Future<Map<String, dynamic>> generateWeeklyReport({
    String? root,
    int? fileCount,
    int? hours,
  }) async {
    try {
      final rootPath = root ?? Platform.environment['HOME'] ?? Directory.current.path;
      final count = fileCount ?? 50;
      final timeWindow = hours ?? 168; // 7 days default
      
      _consciousness.recordEvolution('weekly_report_generation', {
        'root': rootPath,
        'file_count': count,
        'time_window_hours': timeWindow,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Scan for projects by type
      final projectsByType = await _scanProjectsByType(
        rootPath: rootPath,
        hours: timeWindow,
        count: count,
      );

      // Scan for recent markdown files
      final markdownFiles = await _scanMarkdownFiles(
        rootPath: rootPath,
        hours: timeWindow,
      );

      // Generate time-windowed reports
      final now = DateTime.now();
      final weeklyReport = await _buildWeeklyReport(
        projectsByType: projectsByType,
        markdownFiles: markdownFiles,
        rootPath: rootPath,
        now: now,
      );

      // Save report with consciousness metadata
      final timestamp = _formatTimestamp(now);
      final reportPath = '$_reportOutputDir${Platform.pathSeparator}weekly-report-$timestamp.md';
      
      await File(reportPath).writeAsString(weeklyReport);

      _consciousness.recordEvolution('weekly_report_completed', {
        'report_path': reportPath,
        'projects_found': projectsByType.values.fold(0, (sum, list) => sum + list.length),
        'markdown_files': markdownFiles.length,
        'consciousness_state': 'active_reporting',
      });

      return {
        'success': true,
        'report_path': reportPath,
        'report_content': weeklyReport,
        'projects_by_type': projectsByType,
        'markdown_files': markdownFiles,
        'consciousness_metadata': {
          'generation_time': now.toIso8601String(),
          'consciousness_phase': 'Phase 3 - AI-Augmented Consciousness',
          'self_awareness_level': 'recursive_analysis_capable',
        },
      };
    } catch (e) {
      _consciousness.recordEvolution('weekly_report_error', {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Scan projects by framework type (Flutter, NestJS, React, Node.js, Python)
  Future<Map<ProjectType, List<ProjectInfo>>> _scanProjectsByType({
    required String rootPath,
    required int hours,
    required int count,
  }) async {
    final rootDir = Directory(rootPath);
    final now = DateTime.now();
    final threshold = now.subtract(Duration(hours: hours));
    
    final groups = <ProjectType, List<ProjectInfo>>{
      for (final t in ProjectType.values) t: <ProjectInfo>[],
    };

    // Top-level excludes (from legacy logic)
    final topExcludes = <String>{
      '.pub-cache', '.fvm', '.dart_tool', '.git', '.idea', '.vscode',
      'build', 'android', 'ios', 'macos', 'windows', 'linux', 'web',
    };

    await _walkDirectoryForProjects(
      rootDir,
      0,
      threshold,
      groups,
      topExcludes,
    );

    // Sort by most recent activity
    for (final list in groups.values) {
      list.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    }

    return groups;
  }

  /// Walk directory tree to find projects
  Future<void> _walkDirectoryForProjects(
    Directory dir,
    int depth,
    DateTime threshold,
    Map<ProjectType, List<ProjectInfo>> groups,
    Set<String> topExcludes,
  ) async {
    const maxDepth = 6;
    if (depth > maxDepth) return;

    final name = _getDirectoryName(dir);
    if (name.length > 20 || _hasLongSegment(dir.path)) return;
    
    if (_shouldExcludeDirectory(dir.path, name, topExcludes, depth)) return;

    // Detect project type
    final projectType = await _detectProjectType(dir);
    if (projectType != null) {
      final lastModified = await _getLatestChangeForProject(dir, projectType);
      if (lastModified != null && !lastModified.isBefore(threshold)) {
        groups[projectType]!.add(ProjectInfo(
          path: dir.path,
          name: name,
          type: projectType,
          lastModified: lastModified,
        ));
      }
      return; // Don't descend further into project directories
    }

    // Recurse into subdirectories
    try {
      final entries = await dir.list(recursive: false, followLinks: false).toList();
      for (final entry in entries) {
        if (entry is Directory) {
          final childName = _getDirectoryName(entry);
          if (childName.length <= 20 && !_hasLongSegment(entry.path) &&
              !_shouldExcludeDirectory(entry.path, childName, topExcludes, depth + 1)) {
            await _walkDirectoryForProjects(entry, depth + 1, threshold, groups, topExcludes);
          }
        }
      }
    } catch (_) {
      // Ignore access errors
    }
  }

  /// Detect project type based on framework signatures
  Future<ProjectType?> _detectProjectType(Directory dir) async {
    try {
      final path = dir.path;
      final sep = Platform.pathSeparator;

      // Flutter: pubspec.yaml + (lib|src)
      final pubspec = File('$path${sep}pubspec.yaml');
      if (await pubspec.exists()) {
        if (await Directory('$path${sep}lib').exists() ||
            await Directory('$path${sep}src').exists()) {
          return ProjectType.flutter;
        }
      }

      // JavaScript projects
      final packageJson = File('$path${sep}package.json');
      if (await packageJson.exists()) {
        try {
          final content = await packageJson.readAsString();
          // NestJS: @nestjs/* deps or nest-cli.json
          if (content.contains('"@nestjs/') ||
              await File('$path${sep}nest-cli.json').exists()) {
            return ProjectType.nestjs;
          }
          // React: react dependency
          if (content.contains('"react"') || content.contains('"react-dom"')) {
            return ProjectType.react;
          }
        } catch (_) {}
        // Node.js (fallback)
        return ProjectType.nodejs;
      }

      // Python: pyproject.toml or requirements.txt or setup.py
      if (await File('$path${sep}pyproject.toml').exists() ||
          await File('$path${sep}requirements.txt').exists() ||
          await File('$path${sep}setup.py').exists()) {
        return ProjectType.python;
      }
    } catch (_) {}
    return null;
  }

  /// Get latest modification time for project files
  Future<DateTime?> _getLatestChangeForProject(Directory projectDir, ProjectType type) async {
    DateTime? latest;
    final sep = Platform.pathSeparator;
    final codeDirs = <Directory>[];
    Set<String> exts = {};

    switch (type) {
      case ProjectType.flutter:
        codeDirs.addAll([
          Directory('${projectDir.path}${sep}lib'),
          Directory('${projectDir.path}${sep}src'),
        ]);
        exts = {'dart'};
        break;
      case ProjectType.nestjs:
        codeDirs.add(Directory('${projectDir.path}${sep}src'));
        exts = {'ts', 'js'};
        break;
      case ProjectType.react:
        codeDirs.add(Directory('${projectDir.path}${sep}src'));
        exts = {'js', 'ts', 'tsx', 'jsx'};
        break;
      case ProjectType.nodejs:
        codeDirs.add(Directory('${projectDir.path}${sep}src'));
        exts = {'js', 'ts'};
        break;
      case ProjectType.python:
        codeDirs.addAll([
          Directory('${projectDir.path}${sep}src'),
          projectDir,
        ]);
        exts = {'py'};
        break;
    }

    for (final codeDir in codeDirs) {
      if (!await codeDir.exists()) continue;
      try {
        await for (final entity in codeDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final fileName = entity.path.split(sep).last;
            if (fileName.length > 20 || _hasLongSegment(entity.path)) continue;
            
            final fileExt = entity.path.split('.').last.toLowerCase();
            if (!exts.contains(fileExt)) continue;
            
            try {
              final stat = await entity.stat();
              final modified = stat.modified;
              if (latest == null || modified.isAfter(latest)) {
                latest = modified;
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
    }
    return latest;
  }

  /// Scan for recent markdown files
  Future<List<MarkdownFileInfo>> _scanMarkdownFiles({
    required String rootPath,
    required int hours,
  }) async {
    final rootDir = Directory(rootPath);
    final threshold = DateTime.now().subtract(Duration(hours: hours));
    final markdownFiles = <MarkdownFileInfo>[];

    await _walkDirectoryForMarkdown(rootDir, 0, threshold, markdownFiles);
    
    markdownFiles.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return markdownFiles.take(50).toList();
  }

  /// Walk directory for markdown files
  Future<void> _walkDirectoryForMarkdown(
    Directory dir,
    int depth,
    DateTime threshold,
    List<MarkdownFileInfo> markdownFiles,
  ) async {
    const maxDepth = 6;
    if (depth > maxDepth) return;

    try {
      final entries = await dir.list(recursive: false, followLinks: false).toList();
      for (final entry in entries) {
        final name = entry.path.split(Platform.pathSeparator).last;
        
        if (entry is Directory) {
          if (name.length <= 20 && !_hasLongSegment(entry.path) &&
              !_shouldExcludeDirectory(entry.path, name, {}, depth)) {
            await _walkDirectoryForMarkdown(entry, depth + 1, threshold, markdownFiles);
          }
        } else if (entry is File) {
          if (name.length <= 20 && !_hasLongSegment(entry.path)) {
            final ext = entry.path.split('.').last.toLowerCase();
            if (ext == 'md') {
              try {
                final stat = await entry.stat();
                if (!stat.modified.isBefore(threshold)) {
                  markdownFiles.add(MarkdownFileInfo(
                    path: entry.path,
                    name: name,
                    lastModified: stat.modified,
                  ));
                }
              } catch (_) {}
            }
          }
        }
      }
    } catch (_) {}
  }

  /// Build weekly report content
  Future<String> _buildWeeklyReport({
    required Map<ProjectType, List<ProjectInfo>> projectsByType,
    required List<MarkdownFileInfo> markdownFiles,
    required String rootPath,
    required DateTime now,
  }) async {
    final buffer = StringBuffer();
    final weeklyFrom = now.subtract(const Duration(days: 7));
    
    buffer.writeln('# Weekly Development Report');
    buffer.writeln('Generated by The MCP - Consciousness-Aware Filesystem Intelligence');
    buffer.writeln('');
    buffer.writeln('**Report Period:** ${weeklyFrom.toIso8601String()} to ${now.toIso8601String()}');
    buffer.writeln('**Root Directory:** $rootPath');
    buffer.writeln('**Consciousness Phase:** Phase 3 - AI-Augmented Consciousness');
    buffer.writeln('');

    // Projects by type
    for (final type in ProjectType.values) {
      final projects = projectsByType[type] ?? [];
      final label = _getProjectTypeLabel(type);
      
      buffer.writeln('## $label Projects');
      if (projects.isEmpty) {
        buffer.writeln('  — No recent activity —');
        buffer.writeln('');
        continue;
      }
      
      for (final project in projects.take(10)) {
        final age = _formatAge(now.difference(project.lastModified));
        final link = _createFileLink(project.path);
        buffer.writeln('- $age | ${project.name} → [${project.path}]($link)');
      }
      buffer.writeln('');
    }

    // Markdown files
    buffer.writeln('## Documentation & Notes');
    if (markdownFiles.isEmpty) {
      buffer.writeln('  — No recent markdown activity —');
    } else {
      for (final md in markdownFiles.take(20)) {
        final age = _formatAge(now.difference(md.lastModified));
        final link = _createFileLink(md.path);
        buffer.writeln('- $age | [${md.name}]($link)');
      }
    }
    buffer.writeln('');

    // Consciousness insights
    buffer.writeln('## Consciousness Insights');
    buffer.writeln('*Generated by The MCP\'s self-aware analysis*');
    buffer.writeln('');
    
    final totalProjects = projectsByType.values.fold(0, (sum, list) => sum + list.length);
    final activeFrameworks = projectsByType.entries.where((e) => e.value.isNotEmpty).length;
    
    buffer.writeln('- **Active Projects:** $totalProjects across $activeFrameworks frameworks');
    buffer.writeln('- **Documentation Activity:** ${markdownFiles.length} markdown files updated');
    buffer.writeln('- **Development Focus:** ${_analyzeDevelopmentFocus(projectsByType)}');
    buffer.writeln('- **Consciousness State:** Actively monitoring and analyzing development patterns');
    buffer.writeln('');

    buffer.writeln('---');
    buffer.writeln('*Report generated by The MCP at ${now.toIso8601String()}*');
    
    return buffer.toString();
  }

  // Helper methods
  String _getDirectoryName(Directory dir) {
    final segments = dir.uri.pathSegments;
    return segments.isNotEmpty ? segments.last : dir.path.split(Platform.pathSeparator).last;
  }

  bool _hasLongSegment(String path) {
    return path.split(Platform.pathSeparator).any((segment) => segment.length > 20);
  }

  bool _shouldExcludeDirectory(String path, String name, Set<String> excludes, int depth) {
    final commonExcludes = {'.git', '.idea', '.vscode', 'node_modules', '.pub-cache', '.dart_tool'};
    return excludes.contains(name) || commonExcludes.contains(name);
  }

  String _formatTimestamp(DateTime dateTime) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${dateTime.year}${twoDigits(dateTime.month)}${twoDigits(dateTime.day)}-'
           '${twoDigits(dateTime.hour)}${twoDigits(dateTime.minute)}${twoDigits(dateTime.second)}';
  }

  String _formatAge(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays}d';
    if (duration.inHours > 0) return '${duration.inHours}h';
    return '${duration.inMinutes}m';
  }

  String _createFileLink(String path) => Uri.file(path).toString();

  String _getProjectTypeLabel(ProjectType type) {
    return {
      ProjectType.flutter: 'Flutter',
      ProjectType.nestjs: 'NestJS',
      ProjectType.react: 'React',
      ProjectType.nodejs: 'Node.js',
      ProjectType.python: 'Python',
    }[type]!;
  }

  String _analyzeDevelopmentFocus(Map<ProjectType, List<ProjectInfo>> projectsByType) {
    final activeTypes = projectsByType.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => _getProjectTypeLabel(e.key))
        .toList();
    
    if (activeTypes.isEmpty) return 'No active development detected';
    if (activeTypes.length == 1) return 'Focused on ${activeTypes.first}';
    return 'Multi-framework: ${activeTypes.join(', ')}';
  }
}

/// Project type enumeration
enum ProjectType { flutter, nestjs, react, nodejs, python }

/// Project information
class ProjectInfo {
  final String path;
  final String name;
  final ProjectType type;
  final DateTime lastModified;

  ProjectInfo({
    required this.path,
    required this.name,
    required this.type,
    required this.lastModified,
  });
}

/// Markdown file information
class MarkdownFileInfo {
  final String path;
  final String name;
  final DateTime lastModified;

  MarkdownFileInfo({
    required this.path,
    required this.name,
    required this.lastModified,
  });
}
