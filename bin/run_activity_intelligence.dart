// Standalone runner for Activity Intelligence (v4 MCP workspace)
// Usage:
//   dart run bin/run_activity_intelligence.dart \
//     --root /Users/ajaydahal/v4/the_mcp \
//     --hours 168 \
//     --fileCount 50
//
// Prints a JSON report similar to the MCP tool output.

import 'dart:convert';
import 'dart:io';

import '../src/intelligence/activity_intelligence.dart' as ai;
import '../src/intelligence/activity_intelligence_config.dart';

void main(List<String> args) async {
  final parsed = _parseArgs(args);
  final root = parsed['root'] ?? Directory.current.path;
  final hours = int.tryParse(parsed['hours'] ?? '') ?? 72;
  final fileCount = int.tryParse(parsed['fileCount'] ?? '') ?? 50;
  final dirCount = int.tryParse(parsed['dirCount'] ?? '') ?? 20;

  try {
    final config = ActivityIntelligenceConfig(
      root: root,
      hours: hours,
      fileCount: fileCount,
      dirCount: dirCount,
      includeExtensions: const {
        'dart', 'md', 'yaml', 'json', 'js', 'ts', 'py', 'go', 'rs', 'java',
        'kt', 'swift', 'cpp', 'c', 'h', 'hpp', 'cs', 'php', 'rb', 'scala',
        'clj', 'hs', 'elm', 'ex', 'exs', 'erl', 'hrl', 'ml', 'mli', 'fs',
        'fsx', 'fsi', 'r', 'R', 'jl', 'nim', 'cr', 'zig', 'odin', 'v', 'vv', 'vsh',
      },
    );

    final engine = ai.ActivityIntelligence(config);
    final report = await engine.analyzeActivity();

    // Build a JSON similar to the MCP tool output
    final files = report.files.map((f) {
      final now = DateTime.now();
      final diff = now.difference(f.modified);
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
        'path': f.path,
        'name': f.name,
        'size': f.size,
        'extension': f.extension,
      };
    }).toList();

    final directories = report.directories.map((d) {
      final now = DateTime.now();
      final diff = now.difference(d.created);
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
        'path': d.path,
        'name': d.name,
        'extension': '',
      };
    }).toList();

    final result = {
      'analysis_type': 'activity_intelligence',
      'timestamp': report.timestamp.toIso8601String(),
      'root': root,
      'time_window': '${hours}h',
      'files_found': files.length + directories.length,
      'consciousness_level': 'phase_3_emerging',
      'files': [...files, ...directories],
      'consciousness_markers': report.consciousnessMarkers,
      'patterns': report.patterns.map((p) => {
        'type': p.type,
        'description': p.description,
        'confidence': p.confidence,
        'metadata': p.metadata,
      }).toList(),
    };

    if (report.gitActivity != null) {
      // Abridged git activity summary
      result['git_activity'] = {
        'summary': report.gitActivity!.summary,
        'repositories': report.gitActivity!.repositories.map((r) => {
          'name': r.name,
          'path': r.path,
          'lastActivity': r.lastActivity.toIso8601String(),
          'commits': r.recentCommits.length,
        }).toList(),
      };
    }

    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  } catch (e, st) {
    stderr.writeln(json.encode({
      'analysis_type': 'activity_intelligence',
      'error': e.toString(),
      'stack': st.toString(),
      'root': root,
      'time_window': '${hours}h',
    }));
    exitCode = 1;
  }
}

Map<String, String> _parseArgs(List<String> args) {
  final map = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a.startsWith('--')) {
      final key = a.substring(2);
      final next = i + 1 < args.length ? args[i + 1] : null;
      if (next != null && !next.startsWith('--')) {
        map[key] = next;
        i++;
      } else {
        map[key] = 'true';
      }
    }
  }
  return map;
}
