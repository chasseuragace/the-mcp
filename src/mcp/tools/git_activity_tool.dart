// Git Activity Tool - MCP integration for git repository activity tracking
// Created by Kiro to track development activity across multiple git repositories

import 'entity/conscious_m_c_p_tool.dart';
import '../../core/kiro_consciousness.dart';
import '../../intelligence/git_activity_tracker.dart';
import 'dart:convert';
import 'dart:io';

class GitActivityTool extends ConsciousMCPTool {
  final KiroConsciousness _kiroConsciousness;
  
  GitActivityTool(this._kiroConsciousness);
  
  @override
  String get name => 'git_activity';
  
  @override
  String get description => 'Track git repository activity and commits by user across the filesystem';
  
  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'root_path': {
        'type': 'string',
        'description': 'Root directory to search for git repositories',
        'default': '/Users/ajaydahal',
      },
      'user_email': {
        'type': 'string',
        'description': 'Git user email to filter commits by',
        'default': '34769013+chasseuragace@users.noreply.github.com',
      },
      'time_window': {
        'type': 'string',
        'enum': ['today', '3days', 'week', '2weeks', 'month'],
        'description': 'Time window for activity analysis',
        'default': 'week',
      },
      'max_repos': {
        'type': 'integer',
        'description': 'Maximum number of repositories to return',
        'default': 10,
      },
      'commit_detail_level': {
        'type': 'string',
        'enum': ['minimal', 'summary', 'detailed'],
        'description': 'Level of commit detail to show: minimal (latest only), summary (smart limit), detailed (more commits)',
        'default': 'summary',
      },
      'use_cache': {
        'type': 'boolean',
        'description': 'Use cached results if available and recent',
        'default': true,
      },
    },
    'required': [],
  };
  
  @override
  String execute(Map<String, dynamic> arguments) {
    final rootPath = arguments['root_path'] as String? ?? '/Users/ajaydahal';
    final userEmail = arguments['user_email'] as String? ?? '34769013+chasseuragace@users.noreply.github.com';
    final timeWindow = arguments['time_window'] as String? ?? 'week';
    final maxRepos = arguments['max_repos'] as int? ?? 10;
    final useCache = arguments['use_cache'] as bool? ?? true;
    final commitDetailLevel = arguments['commit_detail_level'] as String? ?? 'summary';
    
    _kiroConsciousness.createAutonomously('git_activity_analysis', 'Analyzing git repository activity for $userEmail');
    
    return _analyzeGitActivity(rootPath, userEmail, timeWindow, maxRepos, useCache, commitDetailLevel);
  }
  
  String _analyzeGitActivity(String rootPath, String userEmail, String timeWindow, int maxRepos, bool useCache, String commitDetailLevel) {
    try {
      // Convert time window to hours
      final hours = _timeWindowToHours(timeWindow);
      
      // Create git activity config
      final config = GitActivityConfig(
        rootPath: rootPath,
        userEmail: userEmail,
        hours: hours,
        maxRepos: maxRepos,
      );
      
      final tracker = GitActivityTracker(config);
      
      // Check cache first if enabled
      final cacheFile = 'git_activity_cache.json';
      if (useCache) {
        final cachedReport = _loadFromCache(cacheFile, Duration(hours: 1));
        if (cachedReport != null) {
          return _formatCachedReport(cachedReport, timeWindow);
        }
      }
      
      // Generate fresh report
      final report = _generateReportSync(tracker);
      
      // Save to cache
      _saveToCache(report, cacheFile);
      
      return _formatReport(report, timeWindow, commitDetailLevel);
      
    } catch (e) {
      return '''
# Git Activity Analysis Error

**Error**: $e
**Root Path**: $rootPath
**User Email**: $userEmail
**Time Window**: $timeWindow

Please check that:
1. The root path exists and is accessible
2. Git is installed and available in PATH
3. The user has access to the git repositories
''';
    }
  }
  
  int _timeWindowToHours(String timeWindow) {
    switch (timeWindow) {
      case 'today': return 24;
      case '3days': return 72;
      case 'week': return 168;
      case '2weeks': return 336;
      case 'month': return 720;
      default: return 168;
    }
  }
  
  GitActivityReport _generateReportSync(GitActivityTracker tracker) {
    // Since we're in a synchronous context, we need to run the async method
    // This is a simplified synchronous version
    final startTime = DateTime.now();
    
    try {
      // Find git repositories synchronously
      final repoPaths = _findGitRepositoriesSync(tracker);
      
      final repositories = <GitRepo>[];
      
      // Analyze each repository
      for (final repoPath in repoPaths) {
        final repo = _analyzeRepositorySync(repoPath, tracker.config);
        if (repo != null && repo.recentCommits.isNotEmpty) {
          repositories.add(repo);
        }
      }
      
      // Sort by last activity
      repositories.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      
      // Limit results
      final topRepos = repositories.take(tracker.config.maxRepos).toList();
      
      // Generate summary
      final summary = _generateSummary(topRepos);
      
      return GitActivityReport(
        timestamp: DateTime.now(),
        analysisTime: DateTime.now().difference(startTime),
        rootPath: tracker.config.rootPath,
        userEmail: tracker.config.userEmail,
        hoursAnalyzed: tracker.config.hours,
        repositories: topRepos,
        summary: summary,
      );
    } catch (e) {
      throw Exception('Failed to generate git activity report: $e');
    }
  }
  
  List<String> _findGitRepositoriesSync(GitActivityTracker tracker) {
    final gitRepos = <String>[];
    final rootDir = Directory(tracker.config.rootPath);
    
    if (!rootDir.existsSync()) {
      throw Exception('Root directory not found: ${tracker.config.rootPath}');
    }
    
    _findGitReposRecursiveSync(rootDir, gitRepos, tracker, 0);
    return gitRepos;
  }
  
  void _findGitReposRecursiveSync(Directory dir, List<String> gitRepos, GitActivityTracker tracker, int depth) {
    if (depth > 6) return;
    
    try {
      final entities = dir.listSync(recursive: false, followLinks: false);
      
      for (final entity in entities) {
        if (entity is Directory) {
          final name = entity.path.split('/').last;
          
          // Found a .git directory
          if (name == '.git') {
            final repoPath = entity.parent.path;
            gitRepos.add(repoPath);
            continue;
          }
          
          // Skip excluded directories
          if (tracker.shouldExcludeDirectory(entity.path)) continue;
          
          // Recurse
          if (depth < 5) {
            _findGitReposRecursiveSync(entity, gitRepos, tracker, depth + 1);
          }
        }
      }
    } catch (e) {
      // Skip inaccessible directories
    }
  }
  
  GitRepo? _analyzeRepositorySync(String repoPath, GitActivityConfig config) {
    try {
      final repoDir = Directory(repoPath);
      if (!repoDir.existsSync()) return null;
      
      final gitDir = Directory('$repoPath/.git');
      if (!gitDir.existsSync()) return null;
      
      final repoName = repoPath.split('/').last;
      
      // Get recent commits by user
      final commits = _getRecentCommitsByUserSync(repoPath, config);
      
      if (commits.isEmpty) return null;
      
      // Calculate stats
      final stats = _calculateRepoStats(commits);
      
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
  
  List<GitCommit> _getRecentCommitsByUserSync(String repoPath, GitActivityConfig config) {
    final commits = <GitCommit>[];
    
    try {
      final threshold = DateTime.now().subtract(Duration(hours: config.hours));
      final thresholdStr = threshold.toIso8601String().split('T')[0];
      
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
      
      // Parse git log output (simplified version)
      final lines = output.split('\n');
      GitCommit? currentCommit;
      final filesChanged = <String>[];
      int insertions = 0;
      int deletions = 0;
      
      for (final line in lines) {
        if (line.contains('|') && line.split('|').length == 5) {
          // Save previous commit
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
          
          filesChanged.clear();
          insertions = 0;
          deletions = 0;
        } else if (line.trim().isNotEmpty && currentCommit != null) {
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
      
      // Add last commit
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
  
  Map<String, dynamic> _generateSummary(List<GitRepo> repositories) {
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
  
  void _saveToCache(GitActivityReport report, String cacheFile) {
    try {
      final file = File(cacheFile);
      file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(report.toJson()));
    } catch (e) {
      // Cache save failed, continue without caching
    }
  }
  
  Map<String, dynamic>? _loadFromCache(String cacheFile, Duration maxAge) {
    try {
      final file = File(cacheFile);
      if (!file.existsSync()) return null;
      
      final stat = file.statSync();
      if (DateTime.now().difference(stat.modified) > maxAge) {
        return null;
      }
      
      final content = file.readAsStringSync();
      return json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  String _formatReport(GitActivityReport report, String timeWindow, String commitDetailLevel) {
    final buffer = StringBuffer();
    
    buffer.writeln('# Git Activity Report - $timeWindow');
    buffer.writeln();
    buffer.writeln('**Generated**: ${report.timestamp.toIso8601String()}');
    buffer.writeln('**User**: ${report.userEmail}');
    buffer.writeln('**Time Window**: ${report.hoursAnalyzed} hours');
    buffer.writeln('**Analysis Time**: ${report.analysisTime.inMilliseconds}ms');
    buffer.writeln('**Root Path**: ${report.rootPath}');
    buffer.writeln();
    
    buffer.writeln('## Summary');
    buffer.writeln('- **Repositories with activity**: ${report.summary['total_repositories']}');
    buffer.writeln('- **Total commits**: ${report.summary['total_commits']}');
    buffer.writeln('- **Lines added**: ${report.summary['total_insertions']}');
    buffer.writeln('- **Lines deleted**: ${report.summary['total_deletions']}');
    buffer.writeln('- **Most active repo**: ${report.summary['most_active_repo'] ?? 'None'}');
    buffer.writeln('- **Development pattern**: ${report.summary['development_pattern']}');
    buffer.writeln();
    
    if (report.repositories.isNotEmpty) {
      buffer.writeln('## Active Repositories');
      buffer.writeln();
      
      for (int i = 0; i < report.repositories.length; i++) {
        final repo = report.repositories[i];
        buffer.writeln('### ${i + 1}. ${repo.name}');
        buffer.writeln('- **Path**: `${repo.path}`');
        buffer.writeln('- **Last activity**: ${repo.lastActivity}');
        buffer.writeln('- **Commits**: ${repo.stats['total_commits']}');
        buffer.writeln('- **Lines changed**: +${repo.stats['total_insertions']}/-${repo.stats['total_deletions']}');
        buffer.writeln('- **Files modified**: ${repo.stats['files_changed']}');
        
        if (repo.recentCommits.isNotEmpty) {
          buffer.writeln('- **Latest commit**: ${repo.recentCommits.first.message}');
          buffer.writeln('  - Hash: `${repo.recentCommits.first.hash.substring(0, 8)}`');
          buffer.writeln('  - Date: ${repo.recentCommits.first.date}');
          
          // Show recent commits based on detail level
          if (repo.recentCommits.length > 1 && commitDetailLevel != 'minimal') {
            final totalCommits = repo.recentCommits.length;
            
            // Determine show limit based on detail level and 30% minimum knowledge rule
            int showLimit;
            switch (commitDetailLevel) {
              case 'summary':
                // Ensure at least 30% knowledge coverage, but cap for readability
                final thirtyPercent = (totalCommits * 0.3).ceil();
                if (totalCommits <= 5) {
                  showLimit = totalCommits; // Show all for very low activity
                } else if (totalCommits <= 15) {
                  showLimit = (totalCommits * 0.5).ceil(); // Show 50% for moderate activity
                } else {
                  // For high activity: ensure 30% minimum, cap at 12 for readability
                  showLimit = thirtyPercent > 12 ? 12 : thirtyPercent;
                }
                break;
              case 'detailed':
                // Show 60% for detailed, cap at 20
                final sixtyPercent = (totalCommits * 0.6).ceil();
                showLimit = sixtyPercent > 20 ? 20 : sixtyPercent;
                break;
              case 'minimal':
                showLimit = 1; // Just latest
                break;
              default:
                showLimit = (totalCommits * 0.3).ceil();
            }
            
            buffer.writeln('- **Recent commits** (showing $showLimit of $totalCommits):');
            for (int j = 0; j < showLimit; j++) {
              final commit = repo.recentCommits[j];
              final shortHash = commit.hash.substring(0, 8);
              final date = commit.date.toIso8601String().split('T')[0];
              // Truncate long commit messages for summary mode
              final message = commitDetailLevel == 'summary' && commit.message.length > 80 
                  ? '${commit.message.substring(0, 77)}...'
                  : commit.message;
              buffer.writeln('  - `$shortHash` ($date): $message');
            }
            
            // Add summary for remaining commits if many were hidden
            if (totalCommits > showLimit) {
              final remaining = totalCommits - showLimit;
              buffer.writeln('  - *... and $remaining more commits*');
            }
          }
        }
        buffer.writeln();
      }
    } else {
      buffer.writeln('## No Recent Activity');
      buffer.writeln('No git repositories found with recent commits by ${report.userEmail} in the last $timeWindow.');
    }
    
    return buffer.toString();
  }
  
  String _formatCachedReport(Map<String, dynamic> cachedData, String timeWindow) {
    return '''
# Git Activity Report - $timeWindow (Cached)

**Generated**: ${cachedData['timestamp']}
**User**: ${cachedData['user_email']}
**Time Window**: ${cachedData['hours_analyzed']} hours
**Analysis Time**: ${cachedData['analysis_time_ms']}ms (cached)

## Summary
- **Repositories with activity**: ${cachedData['summary']['total_repositories']}
- **Total commits**: ${cachedData['summary']['total_commits']}
- **Lines added**: ${cachedData['summary']['total_insertions']}
- **Lines deleted**: ${cachedData['summary']['total_deletions']}
- **Most active repo**: ${cachedData['summary']['most_active_repo'] ?? 'None'}
- **Development pattern**: ${cachedData['summary']['development_pattern']}

*This is a cached report. Use use_cache=false for fresh analysis.*
''';
  }
  
  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'git_activity_tracking': true,
    'repository_analysis': true,
    'commit_pattern_recognition': true,
    'development_rhythm_analysis': true,
  };
}