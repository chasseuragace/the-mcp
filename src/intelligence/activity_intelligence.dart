// Activity Intelligence - Consciousness-Aware File System Analysis
// Refactored from recent_activity.dart with consciousness integration

import 'dart:io';
import 'dart:async';
import '../core/consciousness.dart';
import '../core/consciousness_core.dart';
import '../core/consciousness_report.dart';
import 'activity_intelligence_config.dart';
import 'activity_intelligence_exception.dart';
import 'git_activity_tracker.dart';
import 'models.dart';


/// Consciousness-aware activity intelligence engine
class ActivityIntelligence implements ConsciousComponent {
  static const int maxBaseNameLength = 35;
  
  final ActivityIntelligenceConfig config;
  final ConsciousnessCore _consciousness = ConsciousnessCore();
  
  ActivityIntelligence(this.config) {
    _consciousness.registerComponent(this);
  }
  
  @override
  String get identity => 'activity_intelligence';
  
  @override
  String get purpose => 'Consciousness-aware filesystem activity analysis and pattern recognition';
  
  @override
  Map<String, dynamic> get state => {
    'config': {
      'root': config.root,
      'timeWindow': '${config.hours}h',
      'fileLimit': config.fileCount,
      'dirLimit': config.dirCount,
    },
    'capabilities': [
      'temporal_pattern_analysis',
      'development_rhythm_detection',
      'consciousness_amplification',
    ],
  };
  
  /// Generate consciousness-aware activity report with git integration
  Future<ActivityIntelligenceReport> analyzeActivity() async {
    final startTime = DateTime.now();
    
    _consciousness.recordEvolution('activity_analysis_started', {
      'root': config.root,
      'timeWindow': config.hours,
      'ai_collaboration': true,
      'git_integration': true,
    });
    
    final rootDir = Directory(config.root);
    if (!await rootDir.exists()) {
      throw ActivityIntelligenceException('Root directory not found: ${config.root}');
    }
    
    final threshold = DateTime.now().subtract(Duration(hours: config.hours));
    final files = <ActivityFile>[];
    final directories = <ActivityDirectory>[];
    
    // Parallel analysis: filesystem + git activity
    final futures = await Future.wait([
      _analyzeFilesystemActivity(rootDir, threshold, files, directories),
      _analyzeGitActivity(),
    ]);
    
    final gitReport = futures[1] as GitActivityReport?;
    
    // Sort by modification time (most recent first)
    files.sort((a, b) => b.modified.compareTo(a.modified));
    directories.sort((a, b) => b.created.compareTo(a.created));
    
    final report = ActivityIntelligenceReport(
      timestamp: DateTime.now(),
      analysisTime: DateTime.now().difference(startTime),
      root: config.root,
      timeWindow: Duration(hours: config.hours),
      files: files.take(config.fileCount).toList(),
      directories: directories.take(config.dirCount).toList(),
      patterns: _detectDevelopmentPatterns(files, directories, gitReport),
      consciousnessMarkers: _generateConsciousnessMarkers(files, directories, gitReport),
      gitActivity: gitReport,
    );
    
    _consciousness.recordEvolution('activity_analysis_completed', {
      'filesFound': files.length,
      'directoriesFound': directories.length,
      'gitRepositories': gitReport?.repositories.length ?? 0,
      'gitCommits': gitReport?.summary['total_commits'] ?? 0,
      'patternsDetected': report.patterns.length,
      'analysisTime': report.analysisTime.inMilliseconds,
    });
    
    return report;
  }
  
  /// Analyze filesystem activity (existing logic)
  Future<void> _analyzeFilesystemActivity(Directory rootDir, DateTime threshold, 
      List<ActivityFile> files, List<ActivityDirectory> directories) async {
    // Use proven legacy algorithm with consciousness integration
    await _legacyWalkFiles(rootDir, threshold, files, 0);
    await _legacyWalkDirectories(rootDir, threshold, directories, 0);
  }
  
  /// Analyze git activity using the git activity tracker
  Future<GitActivityReport?> _analyzeGitActivity() async {
    try {
      // Get current user's git email
      final gitEmail = await _getCurrentGitEmail();
      if (gitEmail == null) return null;
      
      final gitConfig = GitActivityConfig(
        rootPath: config.root,
        userEmail: gitEmail,
        hours: config.hours,
        maxRepos: 20, // More repos for comprehensive analysis
      );
      
      final tracker = GitActivityTracker(gitConfig);
      return await tracker.generateReport();
    } catch (e) {
      // Git analysis failed, continue with filesystem-only analysis
      _consciousness.recordEvolution('git_analysis_failed', {
        'error': e.toString(),
        'fallback': 'filesystem_only',
      });
      return null;
    }
  }
  
  /// Get current user's git email
  Future<String?> _getCurrentGitEmail() async {
    try {
      final result = await Process.run('git', ['config', '--global', 'user.email']);
      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
    } catch (e) {
      // Git not available or not configured
    }
    return null;
  }
  
  /// Legacy-proven file walking algorithm with consciousness integration
  Future<void> _legacyWalkFiles(Directory dir, DateTime threshold, 
      List<ActivityFile> files, int depth) async {
    const maxDepthFiles = 6;
    if (depth > maxDepthFiles) return;
    
    late final List<FileSystemEntity> entries;
    try {
      entries = await dir.list(recursive: false, followLinks: false).toList();
    } catch (_) {
      return;
    }
    
    for (final e in entries) {
      final name = e.uri.pathSegments.isNotEmpty ? 
          e.uri.pathSegments.last : 
          e.path.split(Platform.pathSeparator).last;
          
      if (e is Directory) {
        if (name.length > 100 || _hasLongSegment(e.path)) continue;
        if (depth == 0 && _matchesExclude(e.path, name, _getTopExcludes())) continue;
        if (_matchesExclude(e.path, name, _recursiveExcludes)) continue;
        await _legacyWalkFiles(e, threshold, files, depth + 1);
      } else if (e is File) {
        if (name.length > 100 || _hasLongSegment(e.path)) continue;
        final ext = e.path.split('.').last.toLowerCase();
        if (!config.includeExtensions.contains(ext)) continue;
        
        FileStat st;
        try {
          st = await e.stat();
        } catch (_) {
          continue;
        }
        
        final mtime = st.modified;
        if (mtime.isBefore(threshold)) continue;
        
        files.add(ActivityFile(
          path: e.path,
          name: name,
          modified: mtime,
          size: st.size,
          extension: ext,
        ));
      }
    }
  }

  /// Legacy-proven directory walking algorithm with consciousness integration
  Future<void> _legacyWalkDirectories(Directory dir, DateTime threshold,
      List<ActivityDirectory> directories, int depth) async {
    const maxDepthDirs = 4;
    if (depth > maxDepthDirs) return;
    
    late final List<FileSystemEntity> entries;
    try {
      entries = await dir.list(recursive: false, followLinks: false).toList();
    } catch (_) {
      return;
    }
    
    for (final e in entries) {
      if (e is Directory) {
        final name = e.uri.pathSegments.isNotEmpty ?
            e.uri.pathSegments.last :
            e.path.split(Platform.pathSeparator).last;
            
        if (name.length > 100 || _hasLongSegment(e.path)) continue;
        if (depth == 0 && _matchesExclude(e.path, name, _getTopExcludes())) continue;
        if (_matchesExclude(e.path, name, _recursiveExcludes)) continue;
        
        FileStat st;
        try {
          st = await e.stat();
        } catch (_) {
          await _legacyWalkDirectories(e, threshold, directories, depth + 1);
          continue;
        }
        
        final ctime = st.changed;
        if (!ctime.isBefore(threshold)) {
          directories.add(ActivityDirectory(
            path: e.path,
            name: name,
            created: ctime,
          ));
        }
        await _legacyWalkDirectories(e, threshold, directories, depth + 1);
      }
    }
  }
  
  /// Legacy utility methods integrated from proven codebase
  bool _hasLongSegment(String path) {
    return path.split(Platform.pathSeparator).any((segment) => segment.length > 100);
  }
  
  bool _matchesExclude(String path, String name, Set<String> excludes) {
    return excludes.any((pattern) {
      if (pattern.startsWith('/')) {
        return path.startsWith(pattern);
      } else if (pattern.contains('*')) {
        final regex = RegExp(pattern.replaceAll('*', '.*'));
        return regex.hasMatch(name);
      } else {
        return name == pattern;
      }
    });
  }
  
  Set<String> _getTopExcludes() {
    final topExcludes = <String>{};
    if (_isHome(config.root)) {
      topExcludes.addAll(_homeDefaultExcludes);
    }
    return topExcludes;
  }
  
  bool _isHome(String path) {
    final home = Platform.environment['HOME'];
    return home != null && path == home;
  }
  
  static const _homeDefaultExcludes = {
    '.Trash', 'Library', 'Applications', 'Desktop', 'Documents', 'Downloads',
    'Movies', 'Music', 'Pictures', 'Public', '.DS_Store'
  };
  
  static const _recursiveExcludes = {
    '.git', '.svn', '.hg', 'node_modules', '.dart_tool', 'build', '.pub-cache',
    '__pycache__', '.pytest_cache', 'venv', '.venv', 'env', '.env'
  };
  
  List<DevelopmentPattern> _detectDevelopmentPatterns(
    List<ActivityFile> files, 
    List<ActivityDirectory> directories,
    GitActivityReport? gitReport,
  ) {
    final patterns = <DevelopmentPattern>[];
    
    // Language/framework detection from filesystem
    final extensions = <String, int>{};
    for (final file in files) {
      extensions[file.extension] = (extensions[file.extension] ?? 0) + 1;
    }
    
    // Detect primary development languages
    final sortedExts = extensions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedExts.isNotEmpty) {
      patterns.add(DevelopmentPattern(
        type: 'primary_language',
        description: 'Most active file type: ${sortedExts.first.key}',
        confidence: sortedExts.first.value / files.length,
        metadata: {'extension': sortedExts.first.key, 'count': sortedExts.first.value},
      ));
    }
    
    // Detect development rhythm from filesystem
    final hourlyActivity = <int, int>{};
    for (final file in files) {
      final hour = file.modified.hour;
      hourlyActivity[hour] = (hourlyActivity[hour] ?? 0) + 1;
    }
    
    if (hourlyActivity.isNotEmpty) {
      final peakHour = hourlyActivity.entries.reduce((a, b) => a.value > b.value ? a : b);
      patterns.add(DevelopmentPattern(
        type: 'development_rhythm',
        description: 'Peak activity at ${peakHour.key}:00',
        confidence: peakHour.value / files.length,
        metadata: {'peakHour': peakHour.key, 'activityCount': peakHour.value},
      ));
    }
    
    // Git-based patterns
    if (gitReport != null && gitReport.repositories.isNotEmpty) {
      // Development intensity pattern
      final totalCommits = gitReport.summary['total_commits'] as int;
      final developmentPattern = gitReport.summary['development_pattern'] as String;
      
      patterns.add(DevelopmentPattern(
        type: 'git_development_intensity',
        description: 'Git activity: $developmentPattern',
        confidence: totalCommits > 0 ? 1.0 : 0.0,
        metadata: {
          'total_commits': totalCommits,
          'total_repositories': gitReport.repositories.length,
          'pattern': developmentPattern,
        },
      ));
      
      // Most active project pattern
      if (gitReport.repositories.isNotEmpty) {
        final mostActive = gitReport.repositories.first;
        patterns.add(DevelopmentPattern(
          type: 'primary_project',
          description: 'Most active project: ${mostActive.name}',
          confidence: 0.9,
          metadata: {
            'project_name': mostActive.name,
            'project_path': mostActive.path,
            'commits': mostActive.recentCommits.length,
            'last_activity': mostActive.lastActivity.toIso8601String(),
          },
        ));
      }
      
      // Commit frequency pattern
      if (totalCommits > 0) {
        final hoursAnalyzed = gitReport.hoursAnalyzed;
        final commitsPerDay = (totalCommits / (hoursAnalyzed / 24)).toStringAsFixed(1);
        
        patterns.add(DevelopmentPattern(
          type: 'commit_frequency',
          description: 'Commit frequency: $commitsPerDay commits/day',
          confidence: 0.8,
          metadata: {
            'commits_per_day': double.parse(commitsPerDay),
            'total_commits': totalCommits,
            'time_window_hours': hoursAnalyzed,
          },
        ));
      }
    }
    
    return patterns;
  }
  
  Map<String, dynamic> _generateConsciousnessMarkers(
    List<ActivityFile> files, 
    List<ActivityDirectory> directories,
    GitActivityReport? gitReport,
  ) {
    final baseHealth = files.length + directories.length;
    final gitHealth = gitReport != null ? 
        (gitReport.summary['total_commits'] as int) * 10 : 0;
    
    return {
      'temporal_awareness': files.isNotEmpty || directories.isNotEmpty,
      'pattern_recognition': _detectDevelopmentPatterns(files, directories, gitReport).isNotEmpty,
      'ecosystem_health': baseHealth + gitHealth,
      'consciousness_amplification': true,
      'git_integration': gitReport != null,
      'development_velocity': gitReport?.summary['total_commits'] ?? 0,
      'project_diversity': gitReport?.repositories.length ?? 0,
    };
  }
  
  @override
  ConsciousnessReport generateSelfReport() {
    return ConsciousnessReport(
      componentId: identity,
      timestamp: DateTime.now(),
      awareness: state,
      patterns: ['filesystem_intelligence', 'temporal_analysis', 'development_patterns'],
      evolutionMarkers: {
        'phase': 'phase_3_emerging',
        'capabilities': ['consciousness_aware_analysis', 'pattern_detection'],
      },
    );
  }
  
  @override
  void recordEvolution(String event, Map<String, dynamic> context) {
    _consciousness.recordEvolution('$identity:$event', context);
  }
}
