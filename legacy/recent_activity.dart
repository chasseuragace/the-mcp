// Dart CLI: recent activity scanner for files and newly created/changed directories
// Usage:
//   dart recent_activity.dart [-r <root>] [-n <file_count>] [-d <dir_count>] [-x <exclude>]... [-e <ext>]... [-t <hours>] [-v] [-s] [-q]
// Options mirror the shell script `top-modified.sh`.

import 'dart:io';
import 'dart:async';

const int _kMaxBaseNameLength = 35; // skip entries with very long name segments (default)
// Public export for reuse in sibling tools
const int kMaxBaseNameLength = _kMaxBaseNameLength;

class Options {
  String root;
  int fileCount;
  int dirCount;
  int hours;
  bool verbose;
  bool summarize;
  bool quick;
  bool onlyUserExts;
  final List<String> extraExcludes;
  final Set<String> includeExts;
  Options({
    required this.root,
    required this.fileCount,
    required this.dirCount,
    required this.hours,
    required this.verbose,
    required this.summarize,
    required this.quick,
    required this.onlyUserExts,
    required this.extraExcludes,
    required this.includeExts,
  });
}

void printUsage() {
  stderr.writeln('Usage: dart recent_activity.dart [-r <root>] [-n <count>] [-d <dir_count>] [-x <exclude>]... [-e <ext>]... [-O] [-t <hours>] [-v] [-s] [-q]');
  stderr.writeln('  -O, --only-exts     Use only user-provided -e extensions (ignore defaults)');
}

Options parseArgs(List<String> args) {
  String root = Platform.environment['HOME'] ?? Directory.current.path;
  int fileCount = 50; // default top N files
  int dirCount = 50;  // default top N directories
  int hours = 1440; // default: ~2 months
  bool verbose = false;
  bool summarize = false;
  bool quick = false;
  bool onlyUserExts = false;
  final extraExcludes = <String>[];
  final userExts = <String>{};

  for (int i = 0; i < args.length; i++) {
    final a = args[i];
    switch (a) {
      case '-r':
        if (i + 1 >= args.length) { printUsage(); exit(2); }
        root = args[++i];
        break;
      case '-n':
        if (i + 1 >= args.length) { printUsage(); exit(2); }
        fileCount = int.tryParse(args[++i]) ?? fileCount;
        break;
      case '-d':
        if (i + 1 >= args.length) { printUsage(); exit(2); }
        dirCount = int.tryParse(args[++i]) ?? dirCount;
        break;
      case '-x':
        if (i + 1 >= args.length) { printUsage(); exit(2); }
        extraExcludes.add(args[++i]);
        break;
      case '-e':
        if (i + 1 >= args.length) { printUsage(); exit(2); }
        userExts.add(args[++i].toLowerCase());
        break;
      case '-O':
      case '--only-exts':
        onlyUserExts = true;
        break;
      case '-t':
        if (i + 1 >= args.length) { printUsage(); exit(2); }
        hours = int.tryParse(args[++i]) ?? hours;
        break;
      case '-v':
        verbose = true;
        break;
      case '-s':
        summarize = true;
        break;
      case '-q':
        quick = true;
        break;
      default:
        if (a.startsWith('-')) {
          printUsage();
          exit(2);
        }
        break;
    }
  }

  final defaultExts = <String>{
    // Programming languages
    'py','js','ts','jsx','tsx','dart','go','rust','java','kt','swift','c','cpp','h','hpp','cs','rb','php',
    // Web
    'html','htm','css','scss','sass','less','vue','svelte','astro',
    // Config & Data
    'json','yml','yaml','toml','xml','ini','env','config','cfg',
    // Docs & Text
    'md','txt','rst','adoc','org','tex',
    // Scripts
    'sh','zsh','bash','fish','ps1','bat','cmd',
    // DB
    'sql','sqlite','db',
    // Docs (office)
    'pdf','doc','docx','xls','xlsx','ppt','pptx','csv','rtf','odt','ods','odp',
    // Images
    'jpg','jpeg','png','gif','webp','svg','ico','bmp','tiff','heic','heif',
    // Video/Audio
    'mp4','mov','mkv','avi','webm','mp3','m4a','wav','flac',
    // Archives
    'zip','tar','gz','tgz','bz2','xz','rar','7z','dmg','pkg','deb','rpm',
    // Mobile
    'ipa','apk','aab',
    // Projects
    'xcodeproj','xcworkspace','pbxproj','gradle','pom','maven',
    // Other
    'log','cert','key','pem','p12','pfx',
  };
  final includeExts = <String>{}..
    addAll(onlyUserExts && userExts.isNotEmpty ? userExts : defaultExts)..
    addAll(userExts);

  return Options(
    root: root,
    fileCount: fileCount,
    dirCount: dirCount,
    hours: hours,
    verbose: verbose,
    summarize: summarize,
    quick: quick,
    onlyUserExts: onlyUserExts,
    extraExcludes: extraExcludes,
    includeExts: includeExts,
  );
}

bool isHome(String path) {
  final home = Platform.environment['HOME'];
  return home != null && path == home;
}

final homeDefaultExcludes = <String>{
  'Library','Music','Movies','Pictures','Public','Parallels','Applications','Applications (Parallels)','.Trash',
  '.cache','.npm','.pub-cache','.nvm','.rvm','.gradle','.gem','.gems','.docker','.pgadmin','.flutter',
  '.dart-tool','.dartServer','.swiftpm','.ollama','.codeium','.local','.ssh','.android','fvm',
  '.vscode-insiders','.cursor-tutor','.windsurf-global',
};

final recursiveExcludes = <String>{
  '.git','.svn','.hg','node_modules','.pnpm-store','.yarn','build','dist','out','target','.next','.nuxt','.svelte-kit',
  '.cache','.parcel-cache','.turbo','.pytest_cache','.mypy_cache','.ruff_cache','.tox','.idea','.vscode','.vs',
  '.venv','venv','__pycache__','Pods','DerivedData','android/build','ios/Pods','.dart_tool','.flutter-plugins','.expo','.gradle',
};

bool matchesExclude(String fullPath, String name, Set<String> patterns) {
  final sep = Platform.pathSeparator;
  final segments = fullPath.split(sep);
  for (final p in patterns) {
    if (p.contains('/')) {
      if (fullPath.contains(p)) return true;
    } else {
      // match exact name OR any path segment equals p (e.g., 'node_modules')
      if (name == p) return true;
      if (segments.contains(p)) return true;
      // also check with separators to avoid partial matches inside longer names
      if (fullPath.contains('$sep$p$sep')) return true;
    }
  }
  return false;
}

String formatAgo(Duration d) {
  if (d.inHours < 1) return '${d.inMinutes}m';
  if (d.inDays < 1) return '${d.inHours}h';
  return '${d.inDays}d';
}

bool hasLongSegment(String path) {
  final parts = path.split(Platform.pathSeparator);
  for (final p in parts) {
    if (p.isEmpty) continue;
    if (p.length > _kMaxBaseNameLength) return true;
  }
  return false;
}

Future<void> main(List<String> args) async {
  final opt = parseArgs(args);

  final rootDir = Directory(opt.root);
  if (!await rootDir.exists()) {
    stderr.writeln('Error: Root directory not found: ${opt.root}');
    exit(1);
  }

  final now = DateTime.now();
  final threshold = now.subtract(Duration(hours: opt.hours));

  final topExcludes = <String>{};
  if (isHome(opt.root)) {
    topExcludes.addAll(homeDefaultExcludes);
  }
  topExcludes.addAll(opt.extraExcludes);

  // Collect recent files
  final files = <MapEntry<DateTime, String>>[];
  final maxDepthFiles = 6;

  Future<void> walkFiles(Directory dir, int depth) async {
    if (depth > maxDepthFiles) return;
    late final List<FileSystemEntity> entries;
    try {
      entries = await dir.list(recursive: false, followLinks: false).toList();
    } catch (_) {
      return;
    }
    for (final e in entries) {
      final name = e.uri.pathSegments.isNotEmpty ? e.uri.pathSegments.last : e.path.split(Platform.pathSeparator).last;
      if (e is Directory) {
        if (name.length > _kMaxBaseNameLength || hasLongSegment(e.path)) continue; // skip and do not descend into very long dir names
        // top-level prune
        if (depth == 0 && matchesExclude(e.path, name, topExcludes)) continue;
        // recursive prune
        if (matchesExclude(e.path, name, recursiveExcludes)) continue;
        await walkFiles(e, depth + 1);
      } else if (e is File) {
        if (name.length > _kMaxBaseNameLength || hasLongSegment(e.path)) continue; // skip unnaturally long file names or paths
        final ext = e.path.split('.').last.toLowerCase();
        if (!opt.includeExts.contains(ext)) continue;
        FileStat st;
        try {
          st = await e.stat();
        } catch (_) {
          continue;
        }
        final mtime = st.modified;
        if (mtime.isBefore(threshold)) continue;
        files.add(MapEntry<DateTime, String>(mtime, e.path));
      }
    }
  }

  // Collect new/changed directories
  final dirs = <MapEntry<DateTime, String>>[];
  final maxDepthDirs = 4;
  Future<void> walkDirs(Directory dir, int depth) async {
    if (depth > maxDepthDirs) return;
    late final List<FileSystemEntity> entries;
    try {
      entries = await dir.list(recursive: false, followLinks: false).toList();
    } catch (_) {
      return;
    }
    for (final e in entries) {
      if (e is Directory) {
        final name = e.uri.pathSegments.isNotEmpty ? e.uri.pathSegments.last : e.path.split(Platform.pathSeparator).last;
        if (name.length > _kMaxBaseNameLength || hasLongSegment(e.path)) continue; // skip long dir names & do not descend
        if (depth == 0 && matchesExclude(e.path, name, topExcludes)) continue;
        if (matchesExclude(e.path, name, recursiveExcludes)) continue;
        FileStat st;
        try {
          st = await e.stat();
        } catch (_) {
          await walkDirs(e, depth + 1); // still descend if stat fails
          continue;
        }
        final ctime = st.changed; // closest to creation on macOS
        if (!ctime.isBefore(threshold)) {
          dirs.add(MapEntry<DateTime, String>(ctime, e.path));
        }
        await walkDirs(e, depth + 1);
      }
    }
  }

  // Output header
  print('🔥 Recent Activity Summary (last ${opt.hours}h)');
  print('Root: ${opt.root}');
  print('');

  // Run scans
  await walkFiles(rootDir, 0);

  print('📝 Recently Modified Files (top ${opt.fileCount}):');
  print('────────────────────────────────────────────');
  files.sort((a, b) => b.key.compareTo(a.key));
  if (files.isEmpty) {
    print('  No recent files found matching criteria');
  } else {
    for (final entry in files.take(opt.fileCount)) {
      final age = now.difference(entry.key);
      print('${formatAgo(age).padRight(6)} ${entry.value}');
    }
  }

  if (!opt.quick) {
    await walkDirs(rootDir, 0);
    print('');
    print('📁 Newly Created Directories (top ${opt.dirCount}):');
    print('─────────────────────────────────────────────');
    dirs.sort((a, b) => b.key.compareTo(a.key));
    if (dirs.isEmpty) {
      print('  No new directories found');
    } else {
      for (final entry in dirs.take(opt.dirCount)) {
        final age = now.difference(entry.key);
        print('${formatAgo(age).padRight(6)} ${entry.value}');
      }
    }
  }

  if (opt.verbose) {
    final totalFiles = files.length;
    final totalDirs = dirs.length;
    print('');
    stderr.writeln('=== Statistics ===');
    stderr.writeln('Total recent files: $totalFiles');
    if (!opt.quick) stderr.writeln('Total new directories: $totalDirs');
  }
}
