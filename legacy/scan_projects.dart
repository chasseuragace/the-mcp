// Scan edited projects grouped by type (Flutter, Next.js, Node.js, Python).
// Each project is a directory that matches a language framework signature.
// A project is considered edited if a relevant source file changed within the time window.
//
// Usage:
//   dart scan_projects.dart [-r <root>] [-t <hours>] [-n <count>] [-v]
// Defaults:
//   root = $HOME, hours = 1440 (~2 months), count = 50

import 'dart:io';
import 'dart:convert';
import 'recent_activity.dart' as ra;

const int _mdTopDefault = 50;

String _basename(String path) {
  final segs = path.split(Platform.pathSeparator);
  for (int i = segs.length - 1; i >= 0; i--) {
    final s = segs[i];
    if (s.isNotEmpty) return s;
  }
  return path;
}

class Options {
  String root;
  int hours;
  int count;
  bool verbose;
  Options({
    required this.root,
    required this.hours,
    required this.count,
    required this.verbose,
  });
}

enum ProjectType { flutter, nestjs, react, nodejs, python }

void _usage() {
  stderr.writeln(
    'Usage: dart scan_projects.dart [-r <root>] [-t <hours>] [-n <count>] [-v]',
  );
}

Options _parseArgs(List<String> args) {
  String root = Platform.environment['HOME'] ?? Directory.current.path;
  int hours = 1440; // ~2 months
  int count = 50;
  bool verbose = false;

  for (int i = 0; i < args.length; i++) {
    final a = args[i];
    switch (a) {
      case '-r':
        if (i + 1 >= args.length) {
          _usage();
          exit(2);
        }
        root = args[++i];
        break;
      case '-t':
        if (i + 1 >= args.length) {
          _usage();
          exit(2);
        }
        hours = int.tryParse(args[++i]) ?? hours;
        break;
      case '-n':
        if (i + 1 >= args.length) {
          _usage();
          exit(2);
        }
        count = int.tryParse(args[++i]) ?? count;
        break;
      case '-v':
        verbose = true;
        break;
      default:
        if (a.startsWith('-')) {
          _usage();
          exit(2);
        }
        break;
    }
  }

  return Options(root: root, hours: hours, count: count, verbose: verbose);
}

Future<ProjectType?> _detectProjectType(Directory dir) async {
  try {
    final sep = Platform.pathSeparator;
    final path = dir.path;
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
        final hasNest =
            content.contains('"@nestjs/') ||
            await File('$path${sep}nest-cli.json').exists();
        if (hasNest) return ProjectType.nestjs;
        // React: react dependency (frontend)
        final hasReact =
            content.contains('"react"') || content.contains('"react-dom"');
        if (hasReact) return ProjectType.react;
      } catch (_) {}
      // Node.js (fallback if package.json present but not matched above)
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

Future<DateTime?> _latestChangeFor(
  Directory projectDir,
  ProjectType type,
) async {
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
      codeDirs.addAll([Directory('${projectDir.path}${sep}src')]);
      exts = {'ts', 'js'};
      break;
    case ProjectType.react:
      codeDirs.addAll([Directory('${projectDir.path}${sep}src')]);
      exts = {'js', 'ts', 'tsx', 'jsx'};
      break;
    case ProjectType.nodejs:
      codeDirs.addAll([Directory('${projectDir.path}${sep}src')]);
      exts = {'js', 'ts'};
      break;
    case ProjectType.python:
      codeDirs.addAll([Directory('${projectDir.path}${sep}src'), projectDir]);
      exts = {'py'};
      break;
  }
  for (final codeDir in codeDirs) {
    if (!await codeDir.exists()) continue;
    try {
      final lister = codeDir.list(recursive: true, followLinks: false);
      await for (final e in lister) {
        if (e is File) {
          final name = e.uri.pathSegments.isNotEmpty
              ? e.uri.pathSegments.last
              : e.path.split(sep).last;
          if (name.length > ra.kMaxBaseNameLength || ra.hasLongSegment(e.path))
            continue;
          final fileExt = e.path.split('.').last.toLowerCase();
          if (!exts.contains(fileExt)) continue;
          try {
            final st = await e.stat();
            final m = st.modified;
            if (latest == null || m.isAfter(latest!)) latest = m;
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
  return latest;
}

Future<String?> _postJson(
  Uri uri,
  Map<String, String> headers,
  Map body,
) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(uri);
    headers.forEach((k, v) => req.headers.set(k, v));
    final payload = utf8.encode(jsonEncode(body));
    req.add(payload);
    final resp = await req.close();
    final text = await resp.transform(utf8.decoder).join();
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return text;
    }
    stderr.writeln('HTTP ${resp.statusCode} from ${uri.toString()}: ' + text);
    return null;
  } catch (e) {
    stderr.writeln('HTTP error posting to ${uri.toString()}: $e');
    return null;
  } finally {
    client.close(force: true);
  }
}

String _ts() {
  final n = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${n.year}${two(n.month)}${two(n.day)}-${two(n.hour)}${two(n.minute)}${two(n.second)}';
}

String _iso(DateTime d) => d.toIso8601String();
String _fileLink(String path) => Uri.file(path).toString();

Future<String?> _humanizeWithGroqModel(String content, String model) async {
  final key = Platform.environment['GROQ_API_KEY'];
  if (key == null || key.isEmpty) return null;
  final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
  final prompt =
      'Context: This is an activity log captured from a tech lead\'s personal workstation. The lead works across multiple projects and languages (Flutter, NestJS, React, Node.js, Python) and keeps notes in Markdown.\n\nTask: Create a concise, executive-level report in Markdown that:\n- Identifies which projects were actively worked on recently (by category).\n- Points out areas or stacks with little/no recent activity (neglected or dormant).\n- Highlights recently created or updated documentation (Markdown), including notable notes.\n- Summarizes key takeaways and trends (e.g., focus areas, shifts, potential risks).\n- Uses clear sections, short paragraphs, and bullet points.\n- Includes a brief action list with next steps (optional but helpful).\n- Present any paths as Markdown links using file:// URIs so they are clickable.\n\nImportant: Base your analysis strictly on the provided log. If something is absent (e.g., Node.js shows none), call that out as a lack of activity.\n\nRAW INPUT:\n"""\n$content\n"""';
  final body = {
    'model': model,
    'temperature': 0.3,
    'messages': [
      {
        'role': 'system',
        'content': 'You are an expert technical report writer.',
      },
      {'role': 'user', 'content': prompt},
    ],
  };
  final res = await _postJson(uri, {
    'Authorization': 'Bearer $key',
    'Content-Type': 'application/json',
  }, body);
  if (res == null) return null;
  try {
    final m = jsonDecode(res);
    final choices = m['choices'];
    if (choices is List && choices.isNotEmpty) {
      final msg = choices[0]['message'];
      final content = msg['content'];
      if (content is String) return content;
    }
  } catch (_) {}
  return null;
}

// Backward-compatible default (unused after per-window models are provided)
Future<String?> _humanizeWithGroq(String content) =>
    _humanizeWithGroqModel(content, 'llama-3.1-8b-instant');

Future<String?> _humanizeWithLmStudio(String content) async {
  final uri = Uri.parse('http://127.0.0.1:1234/v1/chat/completions');
  final prompt =
      'Context: This is an activity log captured from a tech lead\'s personal workstation. The lead works across multiple projects and languages (Flutter, NestJS, React, Node.js, Python) and keeps notes in Markdown.\n\nTask: Create a concise, executive-level report in Markdown that:\n- Identifies which projects were actively worked on recently (by category).\n- Points out areas or stacks with little/no recent activity (neglected or dormant).\n- Highlights recently created or updated documentation (Markdown), including notable notes.\n- Summarizes key takeaways and trends (e.g., focus areas, shifts, potential risks).\n- Uses clear sections, short paragraphs, and bullet points.\n- Includes a brief action list with next steps (optional but helpful).\n- Present any paths as Markdown links using file:// URIs so they are clickable.\n\nImportant: Base your analysis strictly on the provided log. If something is absent (e.g., Node.js shows none), call that out as a lack of activity.\n\nRAW INPUT:\n"""\n$content\n"""';
  final body = {
    'model': 'google/gemma-3-1b',
    'temperature': 0.3,
    'messages': [
      {
        'role': 'system',
        'content': 'You are an expert technical report writer.',
      },
      {'role': 'user', 'content': prompt},
    ],
  };
  final res = await _postJson(uri, {'Content-Type': 'application/json'}, body);
  if (res == null) return null;
  try {
    final m = jsonDecode(res);
    final choices = m['choices'];
    if (choices is List && choices.isNotEmpty) {
      final msg = choices[0]['message'];
      final content = msg['content'];
      if (content is String) return content;
    }
  } catch (_) {}
  return null;
}

Future<void> main(List<String> args) async {
  final opt = _parseArgs(args);
  final rootDir = Directory(opt.root);
  if (!await rootDir.exists()) {
    stderr.writeln('Error: Root directory not found: ${opt.root}');
    exit(1);
  }

  final now = DateTime.now();
  final threshold = now.subtract(Duration(hours: opt.hours));

  // buffer + mirror to stdout
  final buf = StringBuffer();
  void out(String s) {
    print(s);
    buf.writeln(s);
  }

  // top-level excludes
  final topExcludes = <String>{
    '.pub-cache', // Dart/Flutter cache
    '.fvm', // Flutter version manager
    '.dart_tool', // Dart tool artifacts
    '.git', '.idea', '.vscode', // VCS/IDE
    'build', // build output
    // platform folders at top-level roots that aren't projects themselves
    'android', 'ios', 'macos', 'windows', 'linux', 'web',
  };
  if (ra.isHome(opt.root)) topExcludes.addAll(ra.homeDefaultExcludes);
  // Resolve script directory (where this file runs)
  String scriptDirPath = '';
  try {
    scriptDirPath = File.fromUri(Platform.script).parent.path;
    if (scriptDirPath.isNotEmpty) topExcludes.add(scriptDirPath);
  } catch (_) {}

  final groups = <ProjectType, List<MapEntry<DateTime, Directory>>>{
    for (final t in ProjectType.values) t: <MapEntry<DateTime, Directory>>[],
  };

  Future<void> walk(Directory dir, int depth) async {
    const maxDepth = 6;
    if (depth > maxDepth) return;

    final name = dir.uri.pathSegments.isNotEmpty
        ? dir.uri.pathSegments.last
        : dir.path.split(Platform.pathSeparator).last;
    if (name.length > ra.kMaxBaseNameLength || ra.hasLongSegment(dir.path))
      return;
    if ((depth == 0 && ra.matchesExclude(dir.path, name, topExcludes)) ||
        ra.matchesExclude(dir.path, name, ra.recursiveExcludes))
      return;

    // Detect project & capture
    final ptype = await _detectProjectType(dir);
    if (ptype != null) {
      final latest = await _latestChangeFor(dir, ptype);
      if (latest != null && !latest.isBefore(threshold)) {
        groups[ptype]!.add(MapEntry<DateTime, Directory>(latest, dir));
      }
      // Don't descend further
      return;
    }

    // Recurse
    late final List<FileSystemEntity> entries;
    try {
      entries = await dir.list(recursive: false, followLinks: false).toList();
    } catch (_) {
      return;
    }
    for (final e in entries) {
      if (e is Directory) {
        final childName = e.uri.pathSegments.isNotEmpty
            ? e.uri.pathSegments.last
            : e.path.split(Platform.pathSeparator).last;
        if (childName.length > ra.kMaxBaseNameLength ||
            ra.hasLongSegment(e.path))
          continue;
        if (depth == 0 && ra.matchesExclude(e.path, childName, topExcludes))
          continue;
        if (ra.matchesExclude(e.path, childName, ra.recursiveExcludes))
          continue;
        await walk(e, depth + 1);
      }
    }
  }

  // Output header
  out('🔥 Edited Projects by Type (last ${opt.hours}h)');
  out('Root: ${opt.root}');
  out('');

  await walk(rootDir, 0);

  for (final t in ProjectType.values) {
    final list = groups[t]!;
    list.sort((a, b) => b.key.compareTo(a.key));
    final label = {
      ProjectType.flutter: 'Flutter',
      ProjectType.nestjs: 'NestJS',
      ProjectType.react: 'React',
      ProjectType.nodejs: 'Node.js',
      ProjectType.python: 'Python',
    }[t]!;
    out('## $label');
    if (list.isEmpty) {
      out('  — none —');
      out('');
      continue;
    }
    final take = list.take(opt.count);
    for (final p in take) {
      final age = now.difference(p.key);
      final dir = p.value;
      final projName = _basename(dir.path);
      if (opt.verbose) {
        out('${ra.formatAgo(age).padRight(6)} $projName  ->  ${dir.path}');
      } else {
        out(projName);
      }
    }
    out('');
  }

  // Markdown collection section (top 50 by default)
  final mdFiles = <MapEntry<DateTime, String>>[];
  const maxDepth = 6;
  Future<void> walkMd(Directory dir, int depth) async {
    if (depth > maxDepth) return;
    late final List<FileSystemEntity> entries;
    try {
      entries = await dir.list(recursive: false, followLinks: false).toList();
    } catch (_) {
      return;
    }
    for (final e in entries) {
      final name = e.uri.pathSegments.isNotEmpty
          ? e.uri.pathSegments.last
          : e.path.split(Platform.pathSeparator).last;
      if (e is Directory) {
        if (name.length > ra.kMaxBaseNameLength || ra.hasLongSegment(e.path))
          continue;
        if (depth == 0 && ra.matchesExclude(e.path, name, topExcludes))
          continue;
        if (ra.matchesExclude(e.path, name, ra.recursiveExcludes)) continue;
        await walkMd(e, depth + 1);
      } else if (e is File) {
        if (name.length > ra.kMaxBaseNameLength || ra.hasLongSegment(e.path))
          continue;
        final ext = e.path.split('.').last.toLowerCase();
        if (ext != 'md') continue;
        try {
          final st = await e.stat();
          if (!st.modified.isBefore(threshold)) {
            mdFiles.add(MapEntry<DateTime, String>(st.modified, e.path));
          }
        } catch (_) {}
      }
    }
  }

  await walkMd(rootDir, 0);
  mdFiles.sort((a, b) => b.key.compareTo(a.key));
  out('## Markdown');
  if (mdFiles.isEmpty) {
    out('  — none —');
  } else {
    for (final m in mdFiles.take(_mdTopDefault)) {
      if (opt.verbose) {
        out('${ra.formatAgo(now.difference(m.key)).padRight(6)} ${m.value}');
      } else {
        out(m.value);
      }
    }
  }

  // Build windowed reports (weekly, monthly-excl-weekly, abandoned-excl-monthly)
  final ts = _ts();
  // Prefer MCP_REPORT_DIR if provided; otherwise fallback to script dir, then CWD
  String outDir = Platform.environment['MCP_REPORT_DIR'] ?? '';
  if (outDir.isEmpty) {
    outDir = scriptDirPath.isNotEmpty ? scriptDirPath : Directory.current.path;
  }
  final nowIso = _iso(now);
  final weeklyFrom = now.subtract(const Duration(days: 7));
  final monthlyFrom = now.subtract(const Duration(days: 30));
  final sixtyFrom = now.subtract(const Duration(days: 60));

  String buildWindowReport(
    String title,
    DateTime fromExclusive,
    DateTime toInclusive,
  ) {
    final b = StringBuffer();
    b.writeln('# $title');
    b.writeln(
      'Window: ${_iso(fromExclusive)} < t <= ${_iso(toInclusive)} (generated at $nowIso)',
    );
    b.writeln('Root: ${opt.root}');
    b.writeln('');

    for (final t in ProjectType.values) {
      final list = groups[t]!..sort((a, b) => b.key.compareTo(a.key));
      final label = {
        ProjectType.flutter: 'Flutter',
        ProjectType.nestjs: 'NestJS',
        ProjectType.react: 'React',
        ProjectType.nodejs: 'Node.js',
        ProjectType.python: 'Python',
      }[t]!;
      b.writeln('## $label');
      final filtered = list
          .where(
            (e) => e.key.isAfter(fromExclusive) && !e.key.isAfter(toInclusive),
          )
          .toList();
      if (filtered.isEmpty) {
        b.writeln('  — none —');
        b.writeln('');
        continue;
      }
      final take = filtered.take(opt.count);
      for (final p in take) {
        final dir = p.value;
        final projName = _basename(dir.path);
        final age = ra.formatAgo(now.difference(p.key));
        final link = _fileLink(dir.path);
        b.writeln('- $age | $projName -> [${dir.path}]($link)');
      }
      b.writeln('');
    }

    // Markdown section
    final mdFiltered =
        mdFiles
            .where(
              (e) =>
                  e.key.isAfter(fromExclusive) && !e.key.isAfter(toInclusive),
            )
            .toList()
          ..sort((a, b) => b.key.compareTo(a.key));
    b.writeln('## Markdown');
    if (mdFiltered.isEmpty) {
      b.writeln('  — none —');
    } else {
      for (final m in mdFiltered.take(_mdTopDefault)) {
        final age = ra.formatAgo(now.difference(m.key));
        final link = _fileLink(m.value);
        b.writeln('- $age | [${m.value}]($link)');
      }
    }
    return b.toString();
  }

  final weeklyReport = buildWindowReport('Weekly Report', weeklyFrom, now);
  final monthlyReport = buildWindowReport(
    'Monthly Report (excluding last 7 days)',
    monthlyFrom,
    weeklyFrom,
  );
  final abandonedReport = buildWindowReport(
    'Abandoned Report (30–60 days)',
    sixtyFrom,
    monthlyFrom,
  );

  // Save raw reports
  final weeklyPath = '$outDir${Platform.pathSeparator}weekly-report-$ts.md';
  final monthlyPath = '$outDir${Platform.pathSeparator}monthly-report-$ts.md';
  final abandonedPath =
      '$outDir${Platform.pathSeparator}abandoned-report-$ts.md';
  // await File(weeklyPath).writeAsString(weeklyReport);
  // await File(monthlyPath).writeAsString(monthlyReport);
  // await File(abandonedPath).writeAsString(abandonedReport);

  // Humanize each window separately (3 API calls)
  Future<void> humanizeAndSave(
    String raw,
    String suffix, {
    String? groqModel,
  }) async {
    String? human;
    if (groqModel != null) {
      human = await _humanizeWithGroqModel(raw, groqModel);
    } else {
      human = await _humanizeWithGroq(raw);
    }
    human ??= await _humanizeWithLmStudio(raw);
    if (human != null) {
      final humanPath =
          '$outDir${Platform.pathSeparator}humainizedreport-$suffix-$ts.md';
      await File(humanPath).writeAsString(human);
      stderr.writeln('Saved humanized: $humanPath');
    } else {
      stderr.writeln('Humanized report skipped for $suffix.');
    }
  }

  // await humanizeAndSave(weeklyReport, 'weekly', groqModel: 'meta-llama/llama-4-scout-17b-16e-instruct');
  // await humanizeAndSave(monthlyReport, 'monthly', groqModel: 'llama-3.3-70b-versatile');
  // await humanizeAndSave(abandonedReport, 'abandoned', groqModel: 'meta-llama/llama-4-maverick-17b-128e-instruct');

  out('Output reports:');
  out('  $weeklyReport');
  out('  $monthlyReport');
  out('  $abandonedReport');
  // stderr.writeln('Saved reports:');
  // stderr.writeln('  $weeklyPath');
  // stderr.writeln('  $monthlyPath');
  // stderr.writeln('  $abandonedPath');
}
