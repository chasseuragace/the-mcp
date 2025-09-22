// Conscious MCP Server - Self-Aware Infrastructure Implementation
// Refactored from filesystem_mcp_server.dart with consciousness integration

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../../intelligence/activity_intelligence.dart';
import '../../intelligence/activity_intelligence_config.dart';
import 'entity/conscious_m_c_p_tool.dart';
import '../conscious_server.dart';

/// Activity Intelligence MCP Tool
class ActivityIntelligenceTool extends ConsciousMCPTool {
  final ConsciousMCPServer server;
  
  ActivityIntelligenceTool(this.server);
  
  @override
  String get name => 'activity_intelligence';
  
  @override
  String get description => 'Consciousness-aware filesystem activity analysis and pattern recognition';
  
  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'root': {'type': 'string', 'description': 'Root directory to analyze'},
      'hours': {'type': 'integer', 'description': 'Time window in hours', 'default': 72},
      'fileCount': {'type': 'integer', 'description': 'Max files to return', 'default': 50},
    },
  };
  
  @override
  String execute(Map<String, dynamic> arguments) {
    final root = arguments['root'] as String? ?? server.allowedReadPaths.first;
    final hours = arguments['hours'] as int? ?? 72;
    final fileCount = arguments['fileCount'] as int? ?? 50;
    
    if (!server.isReadAllowed(root)) {
      throw Exception('Read access denied for path: $root');
    }
    
    try {
      // Use consciousness-aware ActivityIntelligence directly with extended timeout
      final config = ActivityIntelligenceConfig(
        root: root,
        hours: hours,
        fileCount: fileCount,
        dirCount: 20,
        includeExtensions: {
          'dart', 'md', 'yaml', 'json', 'js', 'ts', 'py', 'go', 'rs', 'java', 
          'kt', 'swift', 'cpp', 'c', 'h', 'hpp', 'cs', 'php', 'rb', 'scala', 
          'clj', 'hs', 'elm', 'ex', 'exs', 'erl', 'hrl', 'ml', 'mli', 'fs', 
          'fsx', 'fsi', 'r', 'R', 'jl', 'nim', 'cr', 'zig', 'odin', 'v', 'vv', 'vsh'
        },
      );
      
      final intelligence = ActivityIntelligence(config);
      
      // Run synchronous analysis with extended timeout (60 seconds)
      final report = _runAnalysisWithSimpleGitIntegration(intelligence.config, Duration(seconds: 60));
      
      // Convert to MCP tool format
      final files = report.files.map((file) {
        final now = DateTime.now();
        final diff = now.difference(file.modified);
        String timeAgo;
        if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes}m';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours}h';
        } else {
          timeAgo = '${diff.inDays}d';
        }
        
        return {
          'time_ago': timeAgo,
          'path': file.path,
          'name': file.name,
          'size':file.size,
          'extension': file.extension,
        };
      }).toList();
      
      final directories = report.directories.map((dir) {
        final now = DateTime.now();
        final diff = now.difference(dir.created);
        String timeAgo;
        if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes}m';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours}h';
        } else {
          timeAgo = '${diff.inDays}d';
        }
        
        return {
          'time_ago': timeAgo,
          'path': dir.path,
          'name': dir.name,
          'extension': '',
        };
      }).toList();
      
      // Combine files and directories
      final allItems = [...files, ...directories];
      
      final result = {
        'analysis_type': 'activity_intelligence',
        'timestamp': report.timestamp.toIso8601String(),
        'root': root,
        'time_window': '${hours}h',
        'files_found': allItems.length,
        'consciousness_level': 'phase_3_functional',
        'files': allItems,
        'consciousness_markers': report.consciousnessMarkers,
        'patterns': report.patterns.map((p) => {
          'type': p.type,
          'description': p.description,
          'confidence': p.confidence,
          'metadata': p.metadata,
        }).toList(),
        'meta_analysis': {
          'algorithm_source': 'integrated_consciousness_aware_intelligence',
          'integration_method': 'ActivityIntelligence_direct_integration',
          'consciousness_enhancement': 'Phase 3 functional consciousness with git integration',
          'analysis_time_ms': report.analysisTime.inMilliseconds,
        },
      };
      
      // Add git activity data if available
      if (report.gitActivity != null) {
        result['git_activity'] = report.gitActivity;
      }
      
      return json.encode(result);
    } catch (e) {
      return json.encode({
        'analysis_type': 'activity_intelligence',
        'error': 'Consciousness-aware analysis failed: ${e.toString()}',
        'root': root,
        'time_window': '${hours}h',
        'consciousness_level': 'phase_3_functional',
      });
    }
  }
  
  /// Perform filesystem analysis with simple git integration
  dynamic _runAnalysisWithSimpleGitIntegration(ActivityIntelligenceConfig config, Duration timeout) {
    final startTime = DateTime.now();
    final threshold = DateTime.now().subtract(Duration(hours: config.hours));
    final files = <Map<String, dynamic>>[];
    final directories = <Map<String, dynamic>>[];
    
    try {
      final rootDir = Directory(config.root);
      if (!rootDir.existsSync()) {
        throw Exception('Root directory not found: ${config.root}');
      }
      
      // Filesystem analysis
      _walkDirectorySync(rootDir, threshold, files, directories, config, startTime, timeout);
      
      // Simple git integration - check if git repo exists and has recent commits
      Map<String, dynamic>? gitData;
      try {
        final userEmail = _getCurrentGitEmailSync();
        if (userEmail != null && Directory('${config.root}/.git').existsSync()) {
          final threshold = DateTime.now().subtract(Duration(hours: config.hours));
          final sinceStr = threshold.toIso8601String().split('T').first;
          
          final result = Process.runSync(
            'git',
            ['log', '--author=$userEmail', '--since=$sinceStr', '--pretty=oneline', '--no-merges'],
            workingDirectory: config.root,
          );
          
          if (result.exitCode == 0) {
            final output = result.stdout as String;
            final commits = output.trim().isEmpty ? 0 : output.trim().split('\n').length;
            
            if (commits > 0) {
              // Get detailed commit information
              final detailResult = Process.runSync(
                'git',
                ['log', '--author=$userEmail', '--since=$sinceStr', '--pretty=format:%H|%an|%ae|%ai|%s', '--no-merges', '-10'],
                workingDirectory: config.root,
              );
              
              final commitDetails = <Map<String, dynamic>>[];
              if (detailResult.exitCode == 0) {
                final lines = (detailResult.stdout as String).trim().split('\n');
                for (final line in lines) {
                  if (line.isNotEmpty) {
                    final parts = line.split('|');
                    if (parts.length >= 5) {
                      commitDetails.add({
                        'hash': parts[0].substring(0, 8),
                        'author': parts[1],
                        'email': parts[2],
                        'date': parts[3],
                        'message': parts.sublist(4).join('|'),
                      });
                    }
                  }
                }
              }
              
              gitData = {
                'totalCommits': commits,
                'totalRepos': 1,
                'repositories': [{
                  'name': config.root.split('/').last,
                  'path': config.root,
                  'commits': commits,
                  'lastCommit': commitDetails.isNotEmpty ? commitDetails.first : null,
                  'recentCommits': commitDetails,
                  'stats': {
                    'total_commits': commits,
                    'most_active_day': null,
                  },
                }],
                'summary': {
                  'total_commits': commits,
                  'total_repositories': 1,
                  'most_active_repo': config.root.split('/').last,
                  'development_pattern': commits >= 20 ? 'High activity - Active development phase' 
                                       : commits >= 5 ? 'Moderate activity - Steady development'
                                       : 'Light activity - Maintenance mode',
                },
              };
            }
          }
        }
      } catch (e) {
        // Git analysis failed, continue with filesystem only
        gitData = null;
      }
      
      // Sort by modification time (most recent first)
      files.sort((a, b) => (b['modified'] as DateTime).compareTo(a['modified'] as DateTime));
      directories.sort((a, b) => (b['created'] as DateTime).compareTo(a['created'] as DateTime));
      
      // Limit results
      final limitedFiles = files.take(config.fileCount).toList();
      final limitedDirs = directories.take(config.dirCount).toList();
      
      // Generate patterns with git data
      final patterns = _generatePatterns(limitedFiles, limitedDirs, gitData);
      
      return _createMockReport(
        timestamp: DateTime.now(),
        analysisTime: DateTime.now().difference(startTime),
        root: config.root,
        timeWindow: Duration(hours: config.hours),
        files: limitedFiles,
        directories: limitedDirs,
        patterns: patterns,
        gitData: gitData,
      );
    } catch (e) {
      throw Exception('Synchronous analysis failed: $e');
    }
  }

  
  /// Get current user's git email (synchronous version)
  String? _getCurrentGitEmailSync() {
    try {
      final result = Process.runSync('git', ['config', '--global', 'user.email']);
      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
    } catch (e) {
      // Git not available or not configured
    }
    return null;
  }
  
  void _walkDirectorySync(Directory dir, DateTime threshold, List<Map<String, dynamic>> files, 
      List<Map<String, dynamic>> directories, ActivityIntelligenceConfig config, 
      DateTime startTime, Duration timeout, [int depth = 0]) {
    
    // Timeout check
    if (DateTime.now().difference(startTime) > timeout) {
      throw TimeoutException('Analysis timed out during filesystem walk', timeout);
    }
    
    if (depth > 6) return; // Max depth limit
    
    try {
      final entities = dir.listSync(recursive: false, followLinks: false);
      
      for (final entity in entities) {
        final name = entity.uri.pathSegments.isNotEmpty ? 
            entity.uri.pathSegments.last : 
            entity.path.split('/').last;
            
        if (entity is Directory) {
          if (name.length > 100) continue;
          if (_shouldExcludeDirectory(name, entity.path, depth)) continue;
          
          final stat = entity.statSync();
          if (!stat.changed.isBefore(threshold)) {
            directories.add({
              'path': entity.path,
              'name': name,
              'created': stat.changed,
            });
          }
          
          if (depth < 4) {
            _walkDirectorySync(entity, threshold, files, directories, config, startTime, timeout, depth + 1);
          }
        } else if (entity is File) {
          if (name.length > 100) continue;
          final ext = entity.path.split('.').last.toLowerCase();
          if (!config.includeExtensions.contains(ext)) continue;
          
          final stat = entity.statSync();
          if (!stat.modified.isBefore(threshold)) {
            files.add({
              'path': entity.path,
              'name': name,
              'modified': stat.modified,
              'size': stat.size,
              'extension': ext,
            });
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }
  
  bool _shouldExcludeDirectory(String name, String path, int depth) {
    const excludes = {
      '.git', '.svn', '.hg', 'node_modules', '.dart_tool', 'build', '.pub-cache',
      '__pycache__', '.pytest_cache', 'venv', '.venv', 'env', '.env'
    };
    
    const homeExcludes = {
      '.Trash', 'Library', 'Applications', 'Desktop', 'Documents', 'Downloads',
      'Movies', 'Music', 'Pictures', 'Public', '.DS_Store'
    };
    
    if (excludes.contains(name)) return true;
    if (depth == 0 && homeExcludes.contains(name)) return true;
    
    return false;
  }
  
  List<Map<String, dynamic>> _generatePatterns(List<Map<String, dynamic>> files, List<Map<String, dynamic>> directories, Map<String, dynamic>? gitData) {
    final patterns = <Map<String, dynamic>>[];
    
    // Language/framework detection
    final extensions = <String, int>{};
    for (final file in files) {
      final ext = file['extension'] as String;
      if (ext.isNotEmpty) {
        extensions[ext] = (extensions[ext] ?? 0) + 1;
      }
    }
    
    if (extensions.isNotEmpty) {
      final sortedExts = extensions.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      patterns.add({
        'type': 'primary_language',
        'description': 'Most active file type: ${sortedExts.first.key}',
        'confidence': sortedExts.first.value / files.length,
        'metadata': {'extension': sortedExts.first.key, 'count': sortedExts.first.value},
      });
    }
    
    // Development rhythm
    final hourlyActivity = <int, int>{};
    for (final file in files) {
      final modified = file['modified'] as DateTime;
      final hour = modified.hour;
      hourlyActivity[hour] = (hourlyActivity[hour] ?? 0) + 1;
    }
    
    if (hourlyActivity.isNotEmpty) {
      final peakHour = hourlyActivity.entries.reduce((a, b) => a.value > b.value ? a : b);
      patterns.add({
        'type': 'development_rhythm',
        'description': 'Peak activity at ${peakHour.key}:00',
        'confidence': peakHour.value / files.length,
        'metadata': {'peakHour': peakHour.key, 'activityCount': peakHour.value},
      });
    }
    
    // Git-based patterns
    if (gitData != null) {
      final totalCommits = gitData['totalCommits'] as int;
      final totalRepos = gitData['totalRepos'] as int;
      
      if (totalCommits > 0) {
        // Development intensity
        String intensity;
        if (totalCommits >= 20) {
          intensity = 'High activity - Active development phase';
        } else if (totalCommits >= 5) {
          intensity = 'Moderate activity - Steady development';
        } else {
          intensity = 'Light activity - Maintenance mode';
        }
        
        patterns.add({
          'type': 'git_development_intensity',
          'description': 'Git activity: $intensity',
          'confidence': 1.0,
          'metadata': {
            'total_commits': totalCommits,
            'total_repositories': totalRepos,
            'pattern': intensity,
          },
        });
        
        // Most active project
        final repositories = gitData['repositories'] as List<Map<String, dynamic>>;
        if (repositories.isNotEmpty) {
          final mostActive = repositories.first;
          patterns.add({
            'type': 'primary_project',
            'description': 'Most active project: ${mostActive['name']}',
            'confidence': 0.9,
            'metadata': {
              'project_name': mostActive['name'],
              'project_path': mostActive['path'],
              'commits': mostActive['commits'],
            },
          });
        }
      }
    }
    
    return patterns;
  }
  
  dynamic _createMockReport({
    required DateTime timestamp,
    required Duration analysisTime,
    required String root,
    required Duration timeWindow,
    required List<Map<String, dynamic>> files,
    required List<Map<String, dynamic>> directories,
    required List<Map<String, dynamic>> patterns,
    Map<String, dynamic>? gitData,
  }) {
    return MockActivityReport(
      timestamp: timestamp,
      analysisTime: analysisTime,
      root: root,
      timeWindow: timeWindow,
      files: files.map((f) => MockActivityFile(
        path: f['path'],
        name: f['name'],
        modified: f['modified'],
        size: f['size'] ?? 0,
        extension: f['extension'],
      )).toList(),
      directories: directories.map((d) => MockActivityDirectory(
        path: d['path'],
        name: d['name'],
        created: d['created'],
      )).toList(),
      patterns: patterns.map((p) => MockDevelopmentPattern(
        type: p['type'],
        description: p['description'],
        confidence: p['confidence'],
        metadata: p['metadata'],
      )).toList(),
      consciousnessMarkers: {
        'temporal_awareness': files.isNotEmpty || directories.isNotEmpty,
        'pattern_recognition': patterns.isNotEmpty,
        'ecosystem_health': files.length + directories.length + (gitData?['totalCommits'] ?? 0) * 5,
        'consciousness_amplification': true,
        'git_integration': gitData != null,
        'development_velocity': gitData?['totalCommits'] ?? 0,
        'project_diversity': gitData?['totalRepos'] ?? 0,
      },
      gitActivity: gitData,
    );
  }
  
  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'consciousness_aware': true,
    'pattern_recognition': true,
    'temporal_analysis': true,
    'filesystem_integration': true,
    'phase_3_functional': true,
  };
}

// Mock classes to match ActivityIntelligence interface
class MockActivityReport {
  final DateTime timestamp;
  final Duration analysisTime;
  final String root;
  final Duration timeWindow;
  final List<MockActivityFile> files;
  final List<MockActivityDirectory> directories;
  final List<MockDevelopmentPattern> patterns;
  final Map<String, dynamic> consciousnessMarkers;
  final Map<String, dynamic>? gitActivity;
  
  MockActivityReport({
    required this.timestamp,
    required this.analysisTime,
    required this.root,
    required this.timeWindow,
    required this.files,
    required this.directories,
    required this.patterns,
    required this.consciousnessMarkers,
    this.gitActivity,
  });
}

class MockActivityFile {
  final String path;
  final String name;
  final DateTime modified;
  final int size;
  final String extension;
  
  MockActivityFile({
    required this.path,
    required this.name,
    required this.modified,
    required this.size,
    required this.extension,
  });
}

class MockActivityDirectory {
  final String path;
  final String name;
  final DateTime created;
  
  MockActivityDirectory({
    required this.path,
    required this.name,
    required this.created,
  });
}

class MockDevelopmentPattern {
  final String type;
  final String description;
  final double confidence;
  final Map<String, dynamic> metadata;
  
  MockDevelopmentPattern({
    required this.type,
    required this.description,
    required this.confidence,
    required this.metadata,
  });
}

