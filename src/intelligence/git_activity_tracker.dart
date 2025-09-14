#!/usr/bin/env dart
import 'dart:io';
import 'dart:convert';

/// Git Activity Tracker - Find git repos and analyze commit activity by user
/// Created by Kiro for tracking development activity across multiple repositories

/// Configuration for git activity analysis
class GitActivityConfig {
  final String rootPath;
  final String userEmail;
  final int hours;
  final int maxRepos;
  
  GitActivityConfig({
    required this.rootPath,
    required this.userEmail,
    this.hours = 168, // 1 week default
    this.maxRepos = 10,
  });
}

/// Git repository information
class GitRepo {
  final String path;
  final String name;
  final DateTime lastActivity;
  final List<GitCommit> recentCommits;
  final Map<String, dynamic> stats;
  
  GitRepo({
    required this.path,
    required this.name,
    required this.lastActivity,
    required this.recentCommits,
    required this.stats,
  });
  
  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    'last_activity': lastActivity.toIso8601String(),
    'recent_commits': recentCommits.map((c) => c.toJson()).toList(),
    'stats': stats,
  };
}

/// Git commit information
class GitCommit {
  final String hash;
  final String author;
  final String email;
  final DateTime date;
  final String message;
  final List<String> filesChanged;
  final int insertions;
  final int deletions;
  
  GitCommit({
    required this.hash,
    required this.author,
    required this.email,
    required this.date,
    required this.message,
    required this.filesChanged,
    required this.insertions,
    required this.deletions,
  });
  
  Map<String, dynamic> toJson() => {
    'hash': hash,
    'author': author,
    'email': email,
    'date': date.toIso8601String(),
    'message': message,
    'files_changed': filesChanged,
    'insertions': insertions,
    'deletions': deletions,
  };
}

/// Git activity analysis report
class GitActivityReport {
  final DateTime timestamp;
  final Duration analysisTime;
  final String rootPath;
  final String userEmail;
  final int hoursAnalyzed;
  final List<GitRepo> repositories;
  final Map<String, dynamic> summary;
  
  GitActivityReport({
    required this.timestamp,
    required this.analysisTime,
    required this.rootPath,
    required this.userEmail,
    required this.hoursAnalyzed,
    required this.repositories,
    required this.summary,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'analysis_time_ms': analysisTime.inMilliseconds,
    'root_path': rootPath,
    'user_email': userEmail,
    'hours_analyzed': hoursAnalyzed,
    'repositories': repositories.map((r) => r.toJson()).toList(),
    'summary': summary,
  };
}

/// Main git activity tracker class
class GitActivityTracker {
  final GitActivityConfig config;
  
  GitActivityTracker(this.config);
  
  /// Directory exclusion patterns (adapted from activity_intelligence_tool.dart)
  static final List<RegExp> excludePatterns = [
    // System directories
    RegExp(r'(^|/)\.Trash/'),
    RegExp(r'(^|/)Library/'),
    RegExp(r'(^|/)Applications/'),
    RegExp(r'(^|/)Desktop/'),
    RegExp(r'(^|/)Documents/'),
    RegExp(r'(^|/)Downloads/'),
    RegExp(r'(^|/)Movies/'),
    RegExp(r'(^|/)Music/'),
    RegExp(r'(^|/)Pictures/'),
    RegExp(r'(^|/)Public/'),
    
    // Development exclusions (but NOT .git - we want to find those!)
    RegExp(r'(^|/)node_modules/'),
    RegExp(r'(^|/)\.dart_tool/'),
    RegExp(r'(^|/)build/'),
    RegExp(r'(^|/)\.pub-cache/'),
    RegExp(r'(^|/)__pycache__/'),
    RegExp(r'(^|/)\.pytest_cache/'),
    RegExp(r'(^|/)venv/'),
    RegExp(r'(^|/)\.venv/'),
    RegExp(r'(^|/)env/'),
    RegExp(r'(^|/)\.env/'),
    
    // Cache and temp directories
    RegExp(r'(^|/)\.cache/'),
    RegExp(r'(^|/)\.npm/'),
    RegExp(r'(^|/)\.gems/'),
    RegExp(r'(^|/)\.nvm/'),
    RegExp(r'(^|/)\.gem/'),
    RegExp(r'(^|/)\.cursor/'),
    RegExp(r'(^|/)\.codeium/'),
    RegExp(r'(^|/)\.windsurf/'),
    RegExp(r'(^|/)\.kiro/'),
    
    // Large directories
    RegExp(r'(^|/)ActivityWatchSync/'),
    RegExp(r'(^|/)Chrome Apps\.localized/'),
    RegExp(r'(^|/)chrome-dev-data/'),
    RegExp(r'(^|/)fvm/'),
    RegExp(r'(^|/)mechvibes_custom/'),
    RegExp(r'(^|/)Parallels/'),
  ];
  
  /// Check if directory should be excluded from search
  bool shouldExcludeDirectory(String path) {
    for (final pattern in excludePatterns) {
      if (pattern.hasMatch(path)) return true;
    }
    return false;
  }
  
  /// Find all git repositories in the root path
  Future<List<String>> findGitRepositories() async {
    final gitRepos = <String>[];
    final rootDir = Directory(config.rootPath);
    
    if (!rootDir.existsSync()) {
      throw Exception('Root directory not found: ${config.rootPath}');
    }
    
    await _findGitReposRecursive(rootDir, gitRepos, 0);
    return gitRepos;
  }
  
  /// Recursively find .git directories
  Future<void> _findGitReposRecursive(Directory dir, List<String> gitRepos, int depth) async {
    if (depth > 8) return; // Max depth limit
    
    try {
      final entities = dir.listSync(recursive: false, followLinks: false);
      
      for (final entity in entities) {
        if (entity is Directory) {
          final name = entity.path.split('/').last;
          
          // Found a .git directory - this is a git repo
          if (name == '.git') {
            final repoPath = entity.parent.path;
            gitRepos.add(repoPath);
            continue; // Don't recurse into .git directory
          }
          
          // Skip excluded directories
          if (shouldExcludeDirectory(entity.path)) continue;
          
          // Recurse into subdirectories
          if (depth < 6) {
            await _findGitReposRecursive(entity, gitRepos, depth + 1);
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }
  
  /// Analyze git activity for a specific repository
  Future<GitRepo?> analyzeRepository(String repoPath) async {
    try {
      final repoDir = Directory(repoPath);
      if (!repoDir.existsSync()) return null;
      
      final gitDir = Directory('$repoPath/.git');
      if (!gitDir.existsSync()) return null;
      
      // Get repository name
      final repoName = repoPath.split('/').last;
      
      // Get recent commits by user
      final commits = await _getRecentCommitsByUser(repoPath);
      
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
      print('Error analyzing repository $repoPath: $e');
      return null;
    }
  }
  
  /// Get recent commits by specific user
  Future<List<GitCommit>> _getRecentCommitsByUser(String repoPath) async {
    final commits = <GitCommit>[];
    
    try {
      // Calculate date threshold
      final threshold = DateTime.now().subtract(Duration(hours: config.hours));
      final thresholdStr = threshold.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      // Git log command to get commits by user since threshold
      final result = await Process.run(
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
      
      if (result.exitCode != 0) {
        print('Git log failed for $repoPath: ${result.stderr}');
        return commits;
      }
      
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
      print('Error getting commits for $repoPath: $e');
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
  
  /// Generate comprehensive git activity report
  Future<GitActivityReport> generateReport() async {
    final startTime = DateTime.now();
    
    print('🔍 Finding git repositories in ${config.rootPath}...');
    final repoPaths = await findGitRepositories();
    print('📁 Found ${repoPaths.length} git repositories');
    
    final repositories = <GitRepo>[];
    
    print('📊 Analyzing git activity for ${config.userEmail}...');
    for (final repoPath in repoPaths) {
      final repo = await analyzeRepository(repoPath);
      if (repo != null && repo.recentCommits.isNotEmpty) {
        repositories.add(repo);
      }
    }
    
    // Sort by last activity (most recent first)
    repositories.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    
    // Limit to top repositories
    final topRepos = repositories.take(config.maxRepos).toList();
    
    // Generate summary
    final summary = _generateSummary(topRepos);
    
    final analysisTime = DateTime.now().difference(startTime);
    
    return GitActivityReport(
      timestamp: DateTime.now(),
      analysisTime: analysisTime,
      rootPath: config.rootPath,
      userEmail: config.userEmail,
      hoursAnalyzed: config.hours,
      repositories: topRepos,
      summary: summary,
    );
  }
  
  /// Generate activity summary
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
  
  /// Save report to JSON file for caching
  Future<void> saveReportToCache(GitActivityReport report, String cacheFile) async {
    try {
      final file = File(cacheFile);
      await file.writeAsString(JsonEncoder.withIndent('  ').convert(report.toJson()));
      print('💾 Report cached to $cacheFile');
    } catch (e) {
      print('❌ Failed to save cache: $e');
    }
  }
  
  /// Load report from cache if available and recent
  Future<GitActivityReport?> loadReportFromCache(String cacheFile, Duration maxAge) async {
    try {
      final file = File(cacheFile);
      if (!file.existsSync()) return null;
      
      final stat = file.statSync();
      if (DateTime.now().difference(stat.modified) > maxAge) {
        return null; // Cache too old
      }
      
      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;
      
      // Reconstruct report from JSON (simplified version)
      return GitActivityReport(
        timestamp: DateTime.parse(data['timestamp']),
        analysisTime: Duration(milliseconds: data['analysis_time_ms']),
        rootPath: data['root_path'],
        userEmail: data['user_email'],
        hoursAnalyzed: data['hours_analyzed'],
        repositories: [], // Would need full reconstruction for complete cache
        summary: data['summary'],
      );
    } catch (e) {
      print('❌ Failed to load cache: $e');
      return null;
    }
  }
}

/// Command-line interface for git activity tracker
void main(List<String> args) async {
  final rootPath = args.isNotEmpty ? args[0] : Directory.current.path;
  final userEmail = args.length > 1 ? args[1] : '34769013+chasseuragace@users.noreply.github.com';
  final hours = args.length > 2 ? int.tryParse(args[2]) ?? 168 : 168;
  
  final config = GitActivityConfig(
    rootPath: rootPath,
    userEmail: userEmail,
    hours: hours,
  );
  
  final tracker = GitActivityTracker(config);
  
  try {
    final report = await tracker.generateReport();
    
    // Save to cache
    final cacheFile = 'git_activity_cache.json';
    await tracker.saveReportToCache(report, cacheFile);
    
    // Print summary
    print('\n📊 Git Activity Report');
    print('=' * 50);
    print('User: ${report.userEmail}');
    print('Time window: ${report.hoursAnalyzed} hours');
    print('Analysis time: ${report.analysisTime.inMilliseconds}ms');
    print('');
    print('Summary:');
    print('- Repositories with activity: ${report.summary['total_repositories']}');
    print('- Total commits: ${report.summary['total_commits']}');
    print('- Lines added: ${report.summary['total_insertions']}');
    print('- Lines deleted: ${report.summary['total_deletions']}');
    print('- Most active repo: ${report.summary['most_active_repo'] ?? 'None'}');
    print('- Pattern: ${report.summary['development_pattern']}');
    
    if (report.repositories.isNotEmpty) {
      print('\nTop Active Repositories:');
      for (int i = 0; i < report.repositories.length; i++) {
        final repo = report.repositories[i];
        print('${i + 1}. ${repo.name} (${repo.stats['total_commits']} commits)');
        print('   Path: ${repo.path}');
        print('   Last activity: ${repo.lastActivity}');
        if (repo.recentCommits.isNotEmpty) {
          print('   Latest: ${repo.recentCommits.first.message}');
        }
        print('');
      }
    }
    
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}