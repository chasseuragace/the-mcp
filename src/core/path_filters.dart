/// Path filtering utilities for activity intelligence.
/// Imported from v8/workspace-scanner shared.dart

// ─── Ignore Patterns (Chunked by Category) ──────────────────────────────────

// Version control systems
final List<RegExp> ignoreVersionControl = [
  RegExp(r'(^|/)\.git($|/)'),
  RegExp(r'(^|/)\.svn($|/)'),
  RegExp(r'(^|/)\.hg($|/)'),
];

// System files and macOS specific
final List<RegExp> ignoreSystemFiles = [
  RegExp(r'(^|/)\.DS_Store'),
  RegExp(r'(^|/)Thumbs\.db'),
  RegExp(r'(^|/)\.Trash/'),
  RegExp(r'(^|/)\.Trashes/'),
  RegExp(r'(^|/)\.TemporaryItems/'),
  RegExp(r'(^|/)\.vol/'),
  RegExp(r'(^|/)\.zsh_sessions/'),
  RegExp(r'(^|/)\.bash_sessions/'),
  RegExp(r'(^|/)\.Spotlight-V100/'),
  RegExp(r'(^|/)\.fseventsd/'),
];

// Generated and temporary files
final List<RegExp> ignoreGenerated = [
  RegExp(r'\.g\.dart'),
  RegExp(r'\.lock'),
  RegExp(r'\.log'),
  RegExp(r'\.tmp'),
];

// IDE and editor caches
final List<RegExp> ignoreIDECaches = [
  RegExp(r'(^|/)\.vscode/'),
  RegExp(r'(^|/)\.idea/'),
  RegExp(r'(^|/)\.cursor/'),
  RegExp(r'(^|/)\.windsurf/'),
  RegExp(r'(^|/)\.codeium/'),
  RegExp(r'(^|/)\.bmad-'),
];

// Package managers and build artifacts (for cleaner scanner)
final List<RegExp> ignorePackageManagers = [
  RegExp(r'(^|/)node_modules/'),
  RegExp(r'(^|/)build/'),
  RegExp(r'(^|/)dist/'),
  RegExp(r'(^|/)venv/'),
  RegExp(r'(^|/)\.venv/'),
  RegExp(r'(^|/)env/'),
  RegExp(r'(^|/)\.env/'),
  RegExp(r'(^|/)fvm/'),
  RegExp(r'(^|/)\.gradle/'),
  RegExp(r'(^|/)\.m2/'),
  RegExp(r'(^|/)\.dart-tool/'),
  RegExp(r'(^|/)\.dart_tool/'),
];

// Package manager caches
final List<RegExp> ignorePackageCaches = [
  RegExp(r'(^|/)\.pub-cache/'),
  RegExp(r'(^|/)\.npm/'),
  RegExp(r'(^|/)\.nvm/'),
  RegExp(r'(^|/)\.gem/'),
  RegExp(r'(^|/)\.gems/'),
  RegExp(r'(^|/)\.cargo/'),
  RegExp(r'(^|/)\.rbenv/'),
  RegExp(r'(^|/)\.pyenv/'),
  RegExp(r'(^|/)\.rustup/'),
];

// User config and sensitive directories
final List<RegExp> ignoreUserConfig = [
  RegExp(r'(^|/)\.ssh/'),
  RegExp(r'(^|/)\.gnupg/'),
  RegExp(r'(^|/)\.config/'),
  RegExp(r'(^|/)\.local/'),
  RegExp(r'(^|/)\.android/'),
  RegExp(r'(^|/)\.cocoapods/'),
  RegExp(r'(^|/)\.antigen/'),
  RegExp(r'(^|/)\.oh-my-zsh/'),
  RegExp(r'(^|/)\.antigravity/'),
];

// Tool-specific caches
final List<RegExp> ignoreToolCaches = [
  RegExp(r'(^|/)\.cache/'),
  RegExp(r'(^|/)\.claude/'),
  RegExp(r'(^|/)\.kiro/'),
  RegExp(r'(^|/)\.dartServer/'),
  RegExp(r'(^|/)\.docker/'),
  RegExp(r'(^|/)\.gemini/'),
];

// Large system folders
final List<RegExp> ignoreLargeSystemFolders = [
  RegExp(r'(^|/)Applications/'),
  RegExp(r'(^|/)Applications \(Parallels\)/'),
  RegExp(r'(^|/)Library/'),
  RegExp(r'(^|/)Movies/'),
  RegExp(r'(^|/)Music/'),
  RegExp(r'(^|/)Pictures/'),
  RegExp(r'(^|/)ActivityWatchSync/'),
  RegExp(r'(^|/)Parallels/'),
];

// Combined ignore patterns for general scanning
final List<RegExp> ignorePatterns = [
  ...ignoreVersionControl,
  ...ignoreSystemFiles,
  ...ignoreGenerated,
  ...ignoreIDECaches,
  ...ignorePackageManagers,
  ...ignorePackageCaches,
  ...ignoreUserConfig,
  ...ignoreToolCaches,
  ...ignoreLargeSystemFolders,
];

// Patterns for cleaner scanner (only package managers and build artifacts)
final List<RegExp> ignorePatternsCleaner = [
  ...ignoreVersionControl,
  ...ignoreSystemFiles,
  ...ignoreIDECaches,
  ...ignorePackageManagers,
  ...ignoreLargeSystemFolders,
];

bool shouldIgnore(String path, {bool forCleaner = false}) {
  // Normalise: ensure directory paths end with / so patterns like (^|/)\.fvm/ match
  final normalised = path.endsWith('/') ? path : '$path/';
  final patterns = forCleaner ? ignorePatternsCleaner : ignorePatterns;
  for (final pattern in patterns) {
    if (pattern.hasMatch(normalised)) return true;
  }
  return false;
}

/// File filtering by mode
/// 'docs': markdown and JSON files
/// 'code': code files (dart, python, typescript)
bool shouldIncludeFile(String path, {String mode = 'docs'}) {
  switch (mode) {
    case 'code':
      return path.endsWith('.dart') ||
             path.endsWith('.py') ||
             path.endsWith('.ts') ||
             path.endsWith('.js') ||
             path.endsWith('.go') ||
             path.endsWith('.rs') ||
             path.endsWith('.java');
    case 'docs':
    default:
      return path.endsWith('.md') || path.endsWith('.json');
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String formatBytes(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
}

String formatDuration(Duration d) {
  if (d.inSeconds < 1) return '${d.inMilliseconds}ms';
  return '${d.inSeconds}s ${d.inMilliseconds % 1000}ms';
}

String timeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).round()}mo ago';
  return '${(diff.inDays / 365).round()}y ago';
}
