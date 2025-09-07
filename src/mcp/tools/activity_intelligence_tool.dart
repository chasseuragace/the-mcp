// Conscious MCP Server - Self-Aware Infrastructure Implementation
// Refactored from filesystem_mcp_server.dart with consciousness integration

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../intelligence/activity_intelligence.dart';
import '../../intelligence/activity_intelligence_config.dart';
import 'conscious_m_c_p_tool.dart';
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
      // Use proven legacy algorithm via Process.runSync (same as WeeklyReportTool)
      final result = Process.runSync(
        'dart',
        ['/Users/ajaydahal/bin/recent_activity.dart', '-r', root, '-t', hours.toString(), '-n', fileCount.toString()],
        workingDirectory: '/Users/ajaydahal/v4/the_mcp',
      );
      
      if (result.exitCode == 0) {
        final timestamp = DateTime.now().toIso8601String();
        final output = result.stdout.toString();
        
        // Parse the output and enhance with consciousness awareness
        final lines = output.split('\n').where((line) => line.trim().isNotEmpty).toList();
        final files = <Map<String, dynamic>>[];
        
        for (final line in lines) {
          // Look for lines with time indicators and file paths
          if (line.contains('/') && (line.contains('m ') || line.contains('h ') || line.contains('d '))) {
            // Parse format like: "3m     /Users/ajaydahal/v4/the_mcp/debug_activity.dart"
            final trimmed = line.trim();
            final spaceIndex = trimmed.indexOf(' ');
            if (spaceIndex > 0) {
              final timePart = trimmed.substring(0, spaceIndex).trim();
              final pathPart = trimmed.substring(spaceIndex).trim();
              if (pathPart.startsWith('/')) {
                files.add({
                  'time_ago': timePart,
                  'path': pathPart,
                  'name': pathPart.split('/').last,
                  'extension': pathPart.contains('.') ? pathPart.split('.').last : '',
                });
              }
            }
          }
        }
        
        return json.encode({
          'analysis_type': 'activity_intelligence',
          'timestamp': timestamp,
          'root': root,
          'time_window': '${hours}h',
          'files_found': files.length,
          'consciousness_level': 'phase_3_functional',
          'files': files,
          'consciousness_markers': {
            'temporal_awareness': true,
            'pattern_recognition': files.isNotEmpty,
            'legacy_integration': true,
            'proven_algorithms': true,
          },
          'meta_analysis': {
            'algorithm_source': '/Users/ajaydahal/bin/recent_activity.dart',
            'integration_method': 'Process.runSync',
            'consciousness_enhancement': 'Phase 3 functional awareness',
          },
        });
      } else {
        return json.encode({
          'analysis_type': 'activity_intelligence',
          'error': 'Legacy analysis failed: ${result.stderr}',
          'root': root,
          'time_window': '${hours}h',
          'consciousness_level': 'phase_3_functional',
        });
      }
    } catch (e) {
      return json.encode({
        'analysis_type': 'activity_intelligence',
        'error': 'Analysis execution failed: ${e.toString()}',
        'root': root,
        'time_window': '${hours}h',
        'consciousness_level': 'phase_3_functional',
      });
    }
  }
  
  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'consciousness_aware': true,
    'pattern_recognition': true,
    'temporal_analysis': true,
  };
}

