// Conscious MCP Server - Self-Aware Infrastructure Implementation
// Refactored to use core ActivityIntelligence engine with synchronous wrapper

import 'dart:convert';
import 'dart:io';
import '../../intelligence/activity_intelligence_config.dart';
import '../../intelligence/models.dart';
import '../../intelligence/git_activity_tracker.dart';
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
      // Use consciousness-aware ActivityIntelligence core engine (synchronous wrapper)
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
      
      // Run synchronous analysis
      final report = _runSynchronousAnalysis(config);
      
      // Convert to MCP tool format
      return _convertReportToJson(report, root, hours);
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
  
  /// Run synchronous analysis using the core engine's proven algorithms
  /// This is a sync wrapper that directly calls the filesystem operations
  ActivityIntelligenceReport _runSynchronousAnalysis(ActivityIntelligenceConfig config) {
    final startTime = DateTime.now();
    final threshold = DateTime.now().subtract(Duration(hours: config.hours));
    
    // Filesystem analysis (synchronous)
    final files = <ActivityFile>[];
    final directories = <ActivityDirectory>[];
    
    try {
      final rootDir = Directory(config.root);
      if (!rootDir.existsSync()) {
        throw Exception('Root directory not found: ${config.root}');
      }
      
      // Walk filesystem synchronously
      _walkFilesystemSync(rootDir, threshold, files, directories, config, 0);
      
      // Sort by modification time
      files.sort((a, b) => b.modified.compareTo(a.modified));
      directories.sort((a, b) => b.created.compareTo(a.created));
      
      // Limit results
      final limitedFiles = files.take(config.fileCount).toList();
      final limitedDirs = directories.take(config.dirCount).toList();
      
      // Git analysis (synchronous)
      final gitReport = _analyzeGitSync(config);
      
      // Generate patterns
      final patterns = _detectPatterns(limitedFiles, limitedDirs, gitReport);
      
      // Generate consciousness markers
      final consciousnessMarkers = _generateConsciousnessMarkers(limitedFiles, limitedDirs, gitReport);
      
      return ActivityIntelligenceReport(
        timestamp: DateTime.now(),
        analysisTime: DateTime.now().difference(startTime),
        root: config.root,
        timeWindow: Duration(hours: config.hours),
        files: limitedFiles,
        directories: limitedDirs,
        patterns: patterns,
        consciousnessMarkers: consciousnessMarkers,
        gitActivity: gitReport,
      );
    } catch (e) {
      throw Exception('Synchronous analysis failed: $e');
    }
  }
  
  /// Walk filesystem synchronously
  void _walkFilesystemSync(Directory dir, DateTime threshold, List<ActivityFile> files,
      List<ActivityDirectory> directories, ActivityIntelligenceConfig config, int depth) {
    if (depth > 6) return;
    
    try {
      final entities = dir.listSync(recursive: false, followLinks: false);
      
      for (final entity in entities) {
        final name = entity.uri.pathSegments.isNotEmpty
            ? entity.uri.pathSegments.last
            : entity.path.split(Platform.pathSeparator).last;
        
        if (entity is Directory) {
          if (name.length > 100) continue;
          if (_shouldExcludeDirectory(name, depth)) continue;
          
          final stat = entity.statSync();
          if (!stat.changed.isBefore(threshold)) {
            directories.add(ActivityDirectory(
              path: entity.path,
              name: name,
              created: stat.changed,
            ));
          }
          
          if (depth < 4) {
            _walkFilesystemSync(entity, threshold, files, directories, config, depth + 1);
          }
        } else if (entity is File) {
          if (name.length > 100) continue;
          final ext = entity.path.split('.').last.toLowerCase();
          if (!config.includeExtensions.contains(ext)) continue;
          
          final stat = entity.statSync();
          if (!stat.modified.isBefore(threshold)) {
            files.add(ActivityFile(
              path: entity.path,
              name: name,
              size: stat.size,
              modified: stat.modified,
              extension: ext,
            ));
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }
  
  bool _shouldExcludeDirectory(String name, int depth) {
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
  
  /// Analyze git activity using full GitActivityTracker (synchronous wrapper)
  /// Discovers ALL git repos under root and provides detailed commit analysis
  GitActivityReport? _analyzeGitSync(ActivityIntelligenceConfig config) {
    try {
      // Get user email
      final result = Process.runSync('git', ['config', '--global', 'user.email']);
      if (result.exitCode != 0) return null;
      
      final userEmail = (result.stdout as String).trim();
      if (userEmail.isEmpty) return null;
      
      // Create GitActivityTracker config
      final gitConfig = GitActivityConfig(
        rootPath: config.root,
        userEmail: userEmail,
        hours: config.hours,
        maxRepos: 20, // Discover up to 20 repos
      );
      
      final tracker = GitActivityTracker(gitConfig);
      
      // Run synchronous git analysis
      return _generateGitReportSync(tracker);
    } catch (e) {
      return null;
    }
  }
  
  /// Generate git activity report synchronously
  /// This is a sync wrapper around GitActivityTracker's async methods
  GitActivityReport? _generateGitReportSync(GitActivityTracker tracker) {
    try {
      final startTime = DateTime.now();
      
      // Find all git repositories synchronously
      final repoPaths = _findGitRepositoriesSync(tracker);
      
      if (repoPaths.isEmpty) return null;
      
      final repositories = <GitRepo>[];
      
      // Analyze each repository
      for (final repoPath in repoPaths) {
        final repo = _analyzeRepositorySync(repoPath, tracker.config);
        if (repo != null && repo.recentCommits.isNotEmpty) {
          repositories.add(repo);
        }
      }
      
      if (repositories.isEmpty) return null;
      
      // Sort by last activity (most recent first)
      repositories.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      
      // Limit to top repositories
      final topRepos = repositories.take(tracker.config.maxRepos).toList();
      
      // Generate summary
      final summary = _generateGitSummary(topRepos);
      
      final analysisTime = DateTime.now().difference(startTime);
      
      return GitActivityReport(
        timestamp: DateTime.now(),
        analysisTime: analysisTime,
        rootPath: tracker.config.rootPath,
        userEmail: tracker.config.userEmail,
        hoursAnalyzed: tracker.config.hours,
        repositories: topRepos,
        summary: summary,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Find all git repositories synchronously
  List<String> _findGitRepositoriesSync(GitActivityTracker tracker) {
    final gitRepos = <String>[];
    final rootDir = Directory(tracker.config.rootPath);
    
    if (!rootDir.existsSync()) return gitRepos;
    
    _findGitReposRecursiveSync(rootDir, gitRepos, tracker, 0);
    return gitRepos;
  }
  
  /// Recursively find .git directories synchronously
  void _findGitReposRecursiveSync(Directory dir, List<String> gitRepos, GitActivityTracker tracker, int depth) {
    if (depth > 8) return; // Max depth limit
    
    try {
      final entities = dir.listSync(recursive: false, followLinks: false);
      
      for (final entity in entities) {
        if (entity is Directory) {
          final name = entity.path.split(Platform.pathSeparator).last;
          
          // Found a .git directory - this is a git repo
          if (name == '.git') {
            final repoPath = entity.parent.path;
            gitRepos.add(repoPath);
            continue; // Don't recurse into .git directory
          }
          
          // Skip excluded directories
          if (tracker.shouldExcludeDirectory(entity.path)) continue;
          
          // Recurse into subdirectories
          if (depth < 6) {
            _findGitReposRecursiveSync(entity, gitRepos, tracker, depth + 1);
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }
  
  /// Analyze a single repository synchronously
  GitRepo? _analyzeRepositorySync(String repoPath, GitActivityConfig config) {
    try {
      final repoDir = Directory(repoPath);
      if (!repoDir.existsSync()) return null;
      
      final gitDir = Directory('$repoPath/.git');
      if (!gitDir.existsSync()) return null;
      
      // Get repository name
      final repoName = repoPath.split(Platform.pathSeparator).last;
      
      // Get recent commits by user
      final commits = _getRecentCommitsByUserSync(repoPath, config);
      
      if (commits.isEmpty) return null;
      
      // Calculate repository stats
      final stats = _calculateRepoStats(commits);
      
      // Get last activity date
      final lastActivity = commits.isNotEmpty ? commits.first.date : DateTime.now();
      
      return GitRepo(
        path: repoPath,
        name: repoName,
        lastActivity: lastActivity,
        recentCommits: commits,
        stats: stats,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get recent commits by specific user synchronously
  List<GitCommit> _getRecentCommitsByUserSync(String repoPath, GitActivityConfig config) {
    final commits = <GitCommit>[];
    
    try {
      // Calculate date threshold
      final threshold = DateTime.now().subtract(Duration(hours: config.hours));
      final thresholdStr = threshold.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      // Git log command to get commits by user since threshold
      final result = Process.runSync(
        'git',
        [
          'log',
          '--author=${config.userEmail}',
          '--since=$thresholdStr',
          '--pretty=format:%H|%an|%ae|%ai|%s',
          '--numstat',
        ],
        workingDirectory: repoPath,
      );
      
      if (result.exitCode != 0) return commits;
      
      final output = result.stdout as String;
      if (output.trim().isEmpty) return commits;
      
      // Parse git log output
      final lines = output.split('\n');
      GitCommit? currentCommit;
      final filesChanged = <String>[];
      int insertions = 0;
      int deletions = 0;
      
      for (final line in lines) {
        if (line.contains('|') && line.split('|').length == 5) {
          // This is a commit header line
          if (currentCommit != null) {
            // Save previous commit
            commits.add(GitCommit(
              hash: currentCommit.hash,
              author: currentCommit.author,
              email: currentCommit.email,
              date: currentCommit.date,
              message: currentCommit.message,
              filesChanged: List.from(filesChanged),
              insertions: insertions,
              deletions: deletions,
            ));
          }
          
          // Parse new commit
          final parts = line.split('|');
          currentCommit = GitCommit(
            hash: parts[0],
            author: parts[1],
            email: parts[2],
            date: DateTime.parse(parts[3]),
            message: parts[4],
            filesChanged: [],
            insertions: 0,
            deletions: 0,
          );
          
          // Reset file stats
          filesChanged.clear();
          insertions = 0;
          deletions = 0;
        } else if (line.trim().isNotEmpty && currentCommit != null) {
          // This is a file change line (numstat format)
          final parts = line.split('\t');
          if (parts.length >= 3) {
            final addStr = parts[0];
            final delStr = parts[1];
            final fileName = parts[2];
            
            filesChanged.add(fileName);
            
            if (addStr != '-') {
              insertions += int.tryParse(addStr) ?? 0;
            }
            if (delStr != '-') {
              deletions += int.tryParse(delStr) ?? 0;
            }
          }
        }
      }
      
      // Add the last commit
      if (currentCommit != null) {
        commits.add(GitCommit(
          hash: currentCommit.hash,
          author: currentCommit.author,
          email: currentCommit.email,
          date: currentCommit.date,
          message: currentCommit.message,
          filesChanged: List.from(filesChanged),
          insertions: insertions,
          deletions: deletions,
        ));
      }
      
    } catch (e) {
      // Error getting commits
    }
    
    return commits;
  }
  
  /// Calculate repository statistics
  Map<String, dynamic> _calculateRepoStats(List<GitCommit> commits) {
    if (commits.isEmpty) {
      return {
        'total_commits': 0,
        'total_insertions': 0,
        'total_deletions': 0,
        'files_changed': 0,
        'avg_commit_size': 0,
        'most_active_day': null,
      };
    }
    
    final totalCommits = commits.length;
    final totalInsertions = commits.fold<int>(0, (sum, c) => sum + c.insertions);
    final totalDeletions = commits.fold<int>(0, (sum, c) => sum + c.deletions);
    
    final allFiles = <String>{};
    for (final commit in commits) {
      allFiles.addAll(commit.filesChanged);
    }
    
    // Find most active day
    final dayActivity = <String, int>{};
    for (final commit in commits) {
      final day = commit.date.toIso8601String().split('T')[0];
      dayActivity[day] = (dayActivity[day] ?? 0) + 1;
    }
    
    final mostActiveDay = dayActivity.isNotEmpty
        ? dayActivity.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;
    
    return {
      'total_commits': totalCommits,
      'total_insertions': totalInsertions,
      'total_deletions': totalDeletions,
      'files_changed': allFiles.length,
      'avg_commit_size': totalCommits > 0 ? (totalInsertions + totalDeletions) / totalCommits : 0,
      'most_active_day': mostActiveDay,
    };
  }
  
  /// Generate activity summary
  Map<String, dynamic> _generateGitSummary(List<GitRepo> repositories) {
    if (repositories.isEmpty) {
      return {
        'total_repositories': 0,
        'total_commits': 0,
        'total_insertions': 0,
        'total_deletions': 0,
        'most_active_repo': null,
        'development_pattern': 'No recent activity',
      };
    }
    
    final totalCommits = repositories.fold<int>(0, (sum, r) => sum + r.stats['total_commits'] as int);
    final totalInsertions = repositories.fold<int>(0, (sum, r) => sum + r.stats['total_insertions'] as int);
    final totalDeletions = repositories.fold<int>(0, (sum, r) => sum + r.stats['total_deletions'] as int);
    
    final mostActiveRepo = repositories.isNotEmpty ? repositories.first : null;
    
    // Determine development pattern
    String developmentPattern;
    if (totalCommits >= 20) {
      developmentPattern = 'High activity - Active development phase';
    } else if (totalCommits >= 5) {
      developmentPattern = 'Moderate activity - Steady development';
    } else {
      developmentPattern = 'Light activity - Maintenance mode';
    }
    
    return {
      'total_repositories': repositories.length,
      'total_commits': totalCommits,
      'total_insertions': totalInsertions,
      'total_deletions': totalDeletions,
      'most_active_repo': mostActiveRepo?.name,
      'development_pattern': developmentPattern,
    };
  }
  
  /// Detect development patterns with enhanced git analysis
  List<DevelopmentPattern> _detectPatterns(
      List<ActivityFile> files, List<ActivityDirectory> directories, GitActivityReport? gitReport) {
    final patterns = <DevelopmentPattern>[];
    
    // Language detection from filesystem
    final extensions = <String, int>{};
    for (final file in files) {
      extensions[file.extension] = (extensions[file.extension] ?? 0) + 1;
    }
    
    if (extensions.isNotEmpty) {
      final sortedExts = extensions.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      patterns.add(DevelopmentPattern(
        type: 'primary_language',
        description: 'Most active file type: ${sortedExts.first.key}',
        confidence: sortedExts.first.value / files.length,
        metadata: {'extension': sortedExts.first.key, 'count': sortedExts.first.value},
      ));
    }
    
    // Development rhythm from filesystem
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
    
    // Enhanced git patterns using GitActivityReport
    if (gitReport != null && gitReport.repositories.isNotEmpty) {
      final summary = gitReport.summary;
      final totalCommits = summary['total_commits'] as int;
      
      // Development intensity pattern
      if (totalCommits > 0) {
        patterns.add(DevelopmentPattern(
          type: 'git_development_intensity',
          description: 'Git activity: ${summary['development_pattern']}',
          confidence: 1.0,
          metadata: {
            'total_commits': totalCommits,
            'total_repositories': summary['total_repositories'],
            'total_insertions': summary['total_insertions'],
            'total_deletions': summary['total_deletions'],
            'pattern': summary['development_pattern'],
          },
        ));
      }
      
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
            'insertions': mostActive.stats['total_insertions'],
            'deletions': mostActive.stats['total_deletions'],
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
      
      // Multi-repo diversity pattern
      if (gitReport.repositories.length > 1) {
        patterns.add(DevelopmentPattern(
          type: 'project_diversity',
          description: 'Working across ${gitReport.repositories.length} repositories',
          confidence: 0.85,
          metadata: {
            'repository_count': gitReport.repositories.length,
            'repositories': gitReport.repositories.map((r) => r.name).toList(),
          },
        ));
      }
    }
    
    return patterns;
  }
  
  /// Generate consciousness markers with enhanced git metrics
  Map<String, dynamic> _generateConsciousnessMarkers(
      List<ActivityFile> files, List<ActivityDirectory> directories, GitActivityReport? gitReport) {
    final baseHealth = files.length + directories.length;
    final gitCommits = gitReport?.summary['total_commits'] ?? 0;
    final gitRepos = gitReport?.repositories.length ?? 0;
    final totalInsertions = gitReport?.summary['total_insertions'] ?? 0;
    final totalDeletions = gitReport?.summary['total_deletions'] ?? 0;
    
    return {
      'temporal_awareness': files.isNotEmpty || directories.isNotEmpty,
      'pattern_recognition': true,
      'ecosystem_health': baseHealth + (gitCommits * 10) + (gitRepos * 20),
      'consciousness_amplification': true,
      'git_integration': gitReport != null,
      'git_multi_repo_discovery': gitRepos > 1,
      'development_velocity': gitCommits,
      'project_diversity': gitRepos,
      'code_churn': totalInsertions + totalDeletions,
      'analysis_depth': gitReport != null ? 'full_git_tracking' : 'filesystem_only',
    };
  }
  
  /// Convert ActivityIntelligenceReport to MCP JSON format
  String _convertReportToJson(ActivityIntelligenceReport report, String root, int hours) {
    // Convert files with time_ago format
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
        'size': file.size,
        'extension': file.extension,
      };
    }).toList();
    
    // Convert directories with time_ago format
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
    
    // Convert patterns
    final patterns = report.patterns.map((p) => {
      'type': p.type,
      'description': p.description,
      'confidence': p.confidence,
      'metadata': p.metadata,
    }).toList();
    
    // Build result
    final result = {
      'analysis_type': 'activity_intelligence',
      'timestamp': report.timestamp.toIso8601String(),
      'root': root,
      'time_window': '${hours}h',
      'files_found': allItems.length,
      'consciousness_level': 'phase_3_functional',
      'files': allItems,
      'consciousness_markers': report.consciousnessMarkers,
      'patterns': patterns,
      'meta_analysis': {
        'algorithm_source': 'core_activity_intelligence_engine',
        'integration_method': 'synchronous_wrapper',
        'consciousness_enhancement': 'Phase 3 functional consciousness',
        'analysis_time_ms': report.analysisTime.inMilliseconds,
      },
    };
    
    // Add enhanced git activity data if available
    if (report.gitActivity != null) {
      result['git_activity'] = _convertGitActivityToJson(report.gitActivity as GitActivityReport);
    }
    
    return json.encode(result);
  }
  
  /// Convert GitActivityReport to JSON format with full details
  Map<String, dynamic> _convertGitActivityToJson(GitActivityReport gitReport) {
    final repositories = gitReport.repositories.map((repo) {
      return {
        'name': repo.name,
        'path': repo.path,
        'last_activity': repo.lastActivity.toIso8601String(),
        'commits': repo.recentCommits.length,
        'stats': repo.stats,
        'recent_commits': repo.recentCommits.take(10).map((commit) => {
          'hash': commit.hash.substring(0, 8),
          'author': commit.author,
          'email': commit.email,
          'date': commit.date.toIso8601String(),
          'message': commit.message,
          'files_changed': commit.filesChanged,
          'insertions': commit.insertions,
          'deletions': commit.deletions,
        }).toList(),
      };
    }).toList();
    
    return {
      'timestamp': gitReport.timestamp.toIso8601String(),
      'analysis_time_ms': gitReport.analysisTime.inMilliseconds,
      'root_path': gitReport.rootPath,
      'user_email': gitReport.userEmail,
      'hours_analyzed': gitReport.hoursAnalyzed,
      'totalCommits': gitReport.summary['total_commits'],
      'totalRepos': gitReport.summary['total_repositories'],
      'totalInsertions': gitReport.summary['total_insertions'],
      'totalDeletions': gitReport.summary['total_deletions'],
      'repositories': repositories,
      'summary': gitReport.summary,
    };
  }
  
  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'consciousness_aware': true,
    'pattern_recognition': true,
    'temporal_analysis': true,
    'filesystem_integration': true,
    'core_engine_integration': true,
    'git_multi_repo_discovery': true,
    'detailed_commit_tracking': true,
    'file_change_analysis': true,
    'insertion_deletion_metrics': true,
    'phase_3_functional': true,
  };
}
